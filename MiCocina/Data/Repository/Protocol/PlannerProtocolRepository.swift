//
//  PlannerProtocolRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 10/04/26.
//

import Foundation

/// Defines the data-access contract for the Planner module.
///
/// `PlannerProtocolRepository` abstracts all persistence operations for daily meal plans,
/// allowing the domain and presentation layers to remain independent of any specific
/// storage implementation (SwiftData, in-memory mock, etc.).
///
/// Conforming types are responsible for day normalisation, upsert semantics, and
/// relationship management between planners and recipes.
///
/// - Example:
/// ```swift
/// let repo: PlannerProtocolRepository = SDPlannerDomainRepository(context: ctx)
/// try repo.save(PlannerData(day: Date(), recipes: [pasta]))
/// let plan = repo.get(by: Date())
/// ```
protocol PlannerProtocolRepository {

    /// Returns the meal plan for the given day, or `nil` if none exists.
    ///
    /// - Parameter day: The calendar day to look up. The implementation matches by
    ///   exact date equality, so callers should pass a normalised (midnight) date.
    /// - Returns: The `PlannerData` for that day, or `nil` if not found.
    func get(by day: Date) -> PlannerData?

    /// Persists a meal plan for its day, creating or updating the existing entry.
    ///
    /// The day is normalised to midnight before storage. If a plan already exists
    /// for that day, its recipes are replaced with the provided ones.
    ///
    /// - Parameter planner: The meal plan to save.
    /// - Throws: `RepositoryError.saveFailed` if the operation cannot be completed.
    func save(_ planner: PlannerData) throws

    /// Deletes the meal plan for the given day, if one exists.
    ///
    /// Silently succeeds if no plan is found for the specified day.
    ///
    /// - Parameter day: The calendar day whose plan should be removed.
    /// - Throws: `RepositoryError.saveFailed` if the deletion cannot be completed.
    func removePlanner(day: Date) throws

    /// Moves a recipe from one day's plan to another.
    ///
    /// If no plan exists for the destination day, one is created automatically.
    /// The recipe is not duplicated if it is already present at the destination.
    ///
    /// - Parameters:
    ///   - recipeID: The unique identifier of the recipe to move.
    ///   - date: The source day containing the recipe.
    ///   - to: The destination day to move the recipe to.
    /// - Throws: `RepositoryError.entityNotFound` if the source plan or recipe does not exist.
    ///           `RepositoryError.saveFailed` if the operation cannot be persisted.
    func movePlanner(recipeID: UUID, from date: Date, to: Date) throws
}
