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
    /// - Returns: A set of all ingredients in the pantry
    func getPantry() -> Set<Ingredient> {
        let descriptor = FetchDescriptor<SDIngredient>()
        guard let ingredients = try? context.fetch(descriptor) else { return .init() }
        let retrievedIngredients = ingredients.map { DomainMapper.toDomain(ingredient: $0) }
        var pantry: Set<Ingredient> = []
        retrievedIngredients.forEach { pantry.insert($0) }
        return pantry
    }

    /// Adds a new ingredient to the pantry.
    ///
    /// If an ingredient with the same ID already exists, the operation updates
    /// the existing ingredient instead of creating a duplicate.
    ///
    /// - Parameter ingredient: The ingredient to add
    /// - Throws: A SwiftData error if the persistence operation fails
    func add(_ ingredient: Ingredient) throws {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientUUID }
        )
        let existingIngredient = try context.fetch(descriptor).first
        if existingIngredient != nil {
            try update(ingredient)
            return
        }

        _ = StorageMapper.toStorage(with: ingredient, context: context)
        try context.save()
    }

    /// Removes an ingredient from the pantry by ID.
    ///
    /// - Parameter ingredient: The ingredient to remove
    /// - Throws: A SwiftData error if the persistence operation fails
    ///
    /// - Note: If the ingredient doesn't exist, the operation completes silently
    func remove(_ ingredient: Ingredient) throws {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientUUID }
        )
        if let existing = try context.fetch(descriptor).first {
            context.delete(existing)
            try context.save()
        }
    }

    /// Updates an existing ingredient's name in the pantry.
    ///
    /// - Parameter ingredient: The ingredient with updated information
    /// - Throws: A SwiftData error if the persistence operation fails
    ///
    /// - Note: Only the name is updated; the ID remains unchanged
    func update(_ ingredient: Ingredient) throws {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientUUID }
        )
        guard let existing = try context.fetch(descriptor).first else { return }
        existing.name = ingredient.name
        try context.save()
    }

    /// Clears all ingredients from the pantry.
    ///
    /// Removes every ingredient from the database, resulting in an empty pantry.
    ///
    /// - Throws: A SwiftData error if the persistence operation fails
    ///
    /// - Warning: This operation is not easily reversible
    func clear() throws {
        let descriptor = FetchDescriptor<SDIngredient>()
        let allIngredients = try context.fetch(descriptor)
        allIngredients.forEach { context.delete($0) }
        try context.save()
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
        let existing = try? context.fetch(descriptor).first
        return existing != nil
    }
}
