//
//  SDPantryProtocolRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 03/04/26.
//

import SwiftData
import Foundation

/// A concrete implementation of `PantryProtocolRepository` using SwiftData for persistence.
///
/// `SDPantryProtocolRepository` provides persistent storage for pantry ingredients using
/// Apple's SwiftData framework. It manages CRUD operations for ingredients in the local
/// database and provides efficient access to the pantry collection.
///
/// This implementation handles:
/// - Fetching all ingredients from persistent storage
/// - Adding new ingredients with duplicate detection
/// - Removing ingredients by ID
/// - Updating ingredient names
/// - Clearing all ingredients
/// - Checking ingredient existence
///
/// - Important: All operations use the provided `ModelContext` for persistence.
///   The caller is responsible for managing the context lifecycle.
///
/// - Example:
/// ```swift
/// let repository = SDPantryProtocolRepository(context: modelContext)
/// let pantry = repository.getPantry()
/// try repository.add(Ingredient(name: "tomato"))
/// ```
final class SDPantryProtocolRepository: PantryProtocolRepository {
    /// The SwiftData model context used for persistence operations
    let context: ModelContext

    /// Initializes a new pantry repository with a SwiftData model context.
    ///
    /// - Parameter context: The `ModelContext` instance for database operations
    init(context: ModelContext) {
        self.context = context
    }

    /// Retrieves all ingredients currently in the pantry.
    ///
    /// Fetches all `SDIngredient` records from the database and maps them to
    /// domain `Ingredient` models for use in the application.
    ///
    /// - Returns: A set of all ingredients in the pantry. Returns empty set if fetch fails.
    func getPantry() -> Set<Ingredient> {
        let descriptor = FetchDescriptor<SDIngredient>()
        do {
            let ingredients = try context.fetch(descriptor)
            let retrievedIngredients = ingredients.map { DomainMapper.toDomain(ingredient: $0) }
            var pantry: Set<Ingredient> = []
            retrievedIngredients.forEach { pantry.insert($0) }
            return pantry
        } catch {
            // Log the actual RepositoryError for debugging 
            let repositoryError = RepositoryError.fetchFailed(operation: "getPantry", underlyingError: error)
            print("Error in getPantry(): \(repositoryError.debugDescription)")
            return .init()
        }
    }

    /// Adds a new ingredient to the pantry.
    ///
    /// If an ingredient with the same ID already exists, the operation updates
    /// the existing ingredient instead of creating a duplicate.
    ///
    /// - Parameter ingredient: The ingredient to add
    /// - Throws: `RepositoryError` if the operation fails
    func add(_ ingredient: Ingredient) throws {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientUUID }
        )
        
        do {
            let existingIngredient = try context.fetch(descriptor).first
            if existingIngredient != nil {
                try update(ingredient)
                return
            }
        } catch {
            throw RepositoryError.fetchFailed(operation: "add - checking existing ingredient", underlyingError: error)
        }

        _ = StorageMapper.toStorage(with: ingredient, context: context)
        do {
            try context.save()
        } catch {
            throw RepositoryError.saveFailed(operation: "add new ingredient \(ingredient.name)", underlyingError: error)
        }
    }

    /// Removes an ingredient from the pantry by ID.
    ///
    /// - Parameter ingredient: The ingredient to remove
    /// - Throws: `RepositoryError` if the operation fails
    ///
    /// - Note: If the ingredient doesn't exist, the operation completes silently
    func remove(_ ingredient: Ingredient) throws {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientUUID }
        )
        
        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch let error where error is NSError {
            if (error as NSError).domain.contains("delete") || (error as NSError).localizedDescription.lowercased().contains("delete") {
                throw RepositoryError.deleteFailed(operation: "remove ingredient \(ingredient.name)", underlyingError: error)
            } else {
                throw RepositoryError.fetchFailed(operation: "remove - finding ingredient to delete", underlyingError: error)
            }
        } catch {
            throw RepositoryError.fetchFailed(operation: "remove - finding ingredient to delete", underlyingError: error)
        }
    }

    /// Updates an existing ingredient's name in the pantry.
    ///
    /// - Parameter ingredient: The ingredient with updated information
    /// - Throws: `RepositoryError` if the operation fails
    ///
    /// - Note: Only the name is updated; the ID remains unchanged.
    ///         If the ingredient doesn't exist, the operation completes silently.
    func update(_ ingredient: Ingredient) throws {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientUUID }
        )
        
        let existing: SDIngredient?
        do {
            existing = try context.fetch(descriptor).first
        } catch {
            throw RepositoryError.fetchFailed(operation: "update - finding ingredient to update", underlyingError: error)
        }
        
        guard let existing = existing else {
            // Silently succeed if ingredient doesn't exist (original behavior)
            return
        }
        
        existing.name = ingredient.name
        do {
            try context.save()
        } catch {
            throw RepositoryError.updateFailed(operation: "update ingredient \(ingredient.name)", underlyingError: error)
        }
    }

    /// Clears all ingredients from the pantry.
    ///
    /// Removes every ingredient from the database, resulting in an empty pantry.
    ///
    /// - Throws: `RepositoryError` if the operation fails
    ///
    /// - Warning: This operation is not easily reversible
    func clear() throws {
        let descriptor = FetchDescriptor<SDIngredient>()
        do {
            let allIngredients = try context.fetch(descriptor)
            allIngredients.forEach { context.delete($0) }
            try context.save()
        } catch let error where error is NSError && ((error as NSError).domain.contains("delete") || (error as NSError).localizedDescription.lowercased().contains("delete")) {
            throw RepositoryError.deleteFailed(operation: "clear all ingredients from pantry", underlyingError: error)
        } catch {
            throw RepositoryError.fetchFailed(operation: "clear - fetching ingredients to delete", underlyingError: error)
        }
    }

    /// Checks whether a specific ingredient exists in the pantry.
    ///
    /// - Parameter ingredient: The ingredient to check
    /// - Returns: `true` if the ingredient exists, `false` otherwise
    func exists(_ ingredient: Ingredient) -> Bool {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientUUID }
        )
        do {
            let existing = try context.fetch(descriptor).first
            return existing != nil
        } catch {
            // Log the actual RepositoryError for debugging
            let repositoryError = RepositoryError.fetchFailed(operation: "exists - checking ingredient \(ingredient.name)", underlyingError: error)
            print("Error in exists(): \(repositoryError.debugDescription)")
            return false
        }
    }
}
