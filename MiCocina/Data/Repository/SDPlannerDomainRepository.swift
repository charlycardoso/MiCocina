//
//  SDPlannerDomainRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 10/04/26.
//

import Foundation
import SwiftData

/// A SwiftData-backed implementation of `PlannerProtocolRepository`.
///
/// `SDPlannerDomainRepository` handles all persistence operations for daily meal plans
/// using a SwiftData `ModelContext`. It provides upsert semantics for `save`, date
/// normalisation to midnight for reliable predicate matching, and a two-phase save
/// strategy for `movePlanner` to work around a SwiftData limitation where relationship
/// mutations on a newly inserted object are discarded if combined with a removal in the
/// same `context.save()` call.
///
/// - Important: The caller is responsible for managing the `ModelContext` lifecycle.
///
/// - Example:
/// ```swift
/// let repo = SDPlannerDomainRepository(context: modelContext)
/// try repo.save(PlannerData(day: Date(), recipes: [pasta]))
/// ```
final class SDPlannerDomainRepository: PlannerProtocolRepository {

    /// The SwiftData context used for all fetch, insert, and save operations.
    let context: ModelContext

    /// Creates a repository backed by the given SwiftData model context.
    ///
    /// - Parameter context: The `ModelContext` to use for persistence operations.
    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - get(by:)

    /// Returns the meal plan for the given day, or `nil` if none exists or a fetch error occurs.
    ///
    /// Fetches using an exact date equality predicate. The `day` parameter should be a
    /// normalised (midnight) date to guarantee a match against stored records.
    ///
    /// - Parameter day: The calendar day to look up.
    /// - Returns: The matching `PlannerData`, or `nil`.
    func get(by day: Date) -> PlannerData? {
        let descriptor = FetchDescriptor<SDPlannerData>(
            predicate: #Predicate { $0.day == day }
        )
        do {
            let sdPlannerDay = try context.fetch(descriptor).first
            return sdPlannerDay.map { DomainMapper.toDomain(planner: $0) }
        } catch {
            return nil
        }
    }

    // MARK: - save(_:)

    /// Persists a meal plan, creating a new entry or replacing an existing one for the same day.
    ///
    /// The day is normalised to midnight before storage. If a plan already exists for that
    /// day, its recipes are replaced with the ones provided. Otherwise a new `SDPlannerData`
    /// record is inserted.
    ///
    /// - Parameter planner: The meal plan to persist.
    /// - Throws: `RepositoryError.saveFailed` if the context cannot be saved.
    func save(_ planner: PlannerData) throws {
        let calendar = Calendar.current
        let normalizedDay = calendar.startOfDay(for: planner.day)

        let descriptor = FetchDescriptor<SDPlannerData>(
            predicate: #Predicate { $0.day == normalizedDay }
        )

        do {
            if let existing = try context.fetch(descriptor).first {
                let recipes = planner.recipes.map {
                    StorageMapper.toStorage(recipe: $0, context: context)
                }
                existing.recipes = recipes
            } else {
                let newPlanner = StorageMapper.toStorage(planner: planner, context: context)
                newPlanner.day = normalizedDay
                context.insert(newPlanner)
            }

            try context.save()

        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.saveFailed(
                operation: "save planner day",
                underlyingError: error
            )
        }
    }

    // MARK: - removePlanner(day:)

    /// Deletes the meal plan for the given day.
    ///
    /// Silently succeeds if no plan is found for the specified day.
    ///
    /// - Parameter day: The calendar day whose plan should be deleted.
    /// - Throws: `RepositoryError.saveFailed` if the deletion cannot be persisted.
    func removePlanner(day: Date) throws {
        let descriptor = FetchDescriptor<SDPlannerData>(
            predicate: #Predicate { $0.day == day }
        )

        do {
            let planners = try context.fetch(descriptor)
            planners.forEach { context.delete($0) }
            try context.save()
        } catch {
            throw RepositoryError.saveFailed(operation: "delete planner day", underlyingError: error)
        }
    }

    // MARK: - movePlanner(recipeID:from:to:)

    /// Moves a recipe from one day's plan to another.
    ///
    /// Both dates are normalised to midnight before use. If the destination plan does not
    /// exist, it is created. The recipe is not duplicated if it is already present at the
    /// destination.
    ///
    /// - Important: This method uses two sequential `context.save()` calls. SwiftData discards
    ///   relationship mutations on a newly inserted object when they are combined with a removal
    ///   in the same save. Saving the "add to destination" first guarantees the relationship
    ///   is persisted before the "remove from source" is committed.
    ///
    /// - Parameters:
    ///   - recipeID: The unique identifier of the recipe to move.
    ///   - from: The source day containing the recipe.
    ///   - to: The destination day to move the recipe to.
    /// - Throws: `RepositoryError.entityNotFound` if the source plan or recipe does not exist.
    ///           `RepositoryError.saveFailed` if either save operation fails.
    func movePlanner(recipeID: UUID, from: Date, to: Date) throws {

        let calendar = Calendar.current
        let fromDay = calendar.startOfDay(for: from)
        let toDay = calendar.startOfDay(for: to)

        let fromDescriptor = FetchDescriptor<SDPlannerData>(
            predicate: #Predicate { $0.day == fromDay }
        )

        let toDescriptor = FetchDescriptor<SDPlannerData>(
            predicate: #Predicate { $0.day == toDay }
        )

        do {
            // 1. Obtener planner origen
            guard let fromPlanner = try context.fetch(fromDescriptor).first else {
                throw RepositoryError.entityNotFound(
                    entityType: "Planner(from)",
                    identifier: fromDay.description
                )
            }

            // 2. Obtener receta a mover
            guard let recipe = fromPlanner.recipes.first(where: { $0.id == recipeID }) else {
                throw RepositoryError.entityNotFound(
                    entityType: "Recipe",
                    identifier: recipeID.uuidString
                )
            }

            // 3. Añadir al destino y guardar ANTES de remover del origen.
            //    SwiftData descarta la relación si ambas operaciones se combinan en un solo save
            //    cuando el planner destino es recién insertado.
            if let existing = try context.fetch(toDescriptor).first {
                if !existing.recipes.contains(where: { $0.id == recipeID }) {
                    existing.recipes.append(recipe)
                }
            } else {
                let toPlanner = SDPlannerData(day: toDay, recipes: [])
                context.insert(toPlanner)
                toPlanner.recipes.append(recipe)
            }
            try context.save()

            // 4. Remover del origen y guardar
            fromPlanner.recipes.removeAll { $0.id == recipeID }
            try context.save()

        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.saveFailed(
                operation: "move planner between days",
                underlyingError: error
            )
        }
    }
}
