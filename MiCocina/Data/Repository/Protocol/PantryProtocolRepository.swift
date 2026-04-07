//
//  PantryProtocolRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation

/// A protocol defining the data access contract for pantry (ingredient) operations.
///
/// `PantryProtocolRepository` abstracts the persistence layer for managing a user's pantry—
/// the collection of ingredients they have available. This protocol enables the domain layer
/// to work with any storage implementation without direct dependencies.
///
/// The pantry is represented as a `Set<Ingredient>` for efficient lookups and uniqueness
/// guarantees during recipe matching operations.
///
/// - Important: Implementations should handle persistence errors gracefully and ensure
///   thread-safe access to the pantry data.
///
/// - Example:
/// ```swift
/// let repository: PantryProtocolRepository = SDPantryProtocolRepository(context: modelContext)
/// var pantry = repository.getPantry()
/// try repository.add(Ingredient(name: "tomato"))
/// ```
protocol PantryProtocolRepository {
    
    /// Retrieves the current pantry contents.
    ///
    /// Returns all ingredients currently stored in the pantry as a set,
    /// enabling efficient membership testing during recipe matching.
    ///
    /// - Returns: A set of all ingredients in the pantry
    func getPantry() -> Set<Ingredient>

    /// Adds a new ingredient to the pantry.
    ///
    /// If the ingredient already exists (same ID), the implementation may update it
    /// or ignore the operation depending on the implementation strategy.
    ///
    /// - Parameter ingredient: The ingredient to add
    /// - Throws: An error if the add operation fails
    ///
    /// - Note: Changes are persisted immediately
    func add(_ ingredient: Ingredient) throws

    /// Removes an ingredient from the pantry.
    ///
    /// - Parameter ingredient: The ingredient to remove
    /// - Throws: An error if the remove operation fails
    /// - Note: If the ingredient doesn't exist, the operation succeeds silently
    func remove(_ ingredient: Ingredient) throws

    /// Updates an existing ingredient in the pantry.
    ///
    /// The ingredient is identified by its ID. Updates the ingredient's properties
    /// (typically the name) while maintaining its identity.
    ///
    /// - Parameter ingredient: The updated ingredient data
    /// - Throws: An error if the update operation fails or ingredient not found
    func update(_ ingredient: Ingredient) throws

    /// Clears all ingredients from the pantry.
    ///
    /// Removes all ingredients from the pantry, resulting in an empty set.
    /// This operation is irreversible and should be used carefully.
    ///
    /// - Throws: An error if the clear operation fails
    ///
    /// - Warning: This operation removes all pantry data
    func clear() throws

    /// Checks whether a specific ingredient exists in the pantry.
    ///
    /// Efficiently checks for the existence of an ingredient by ID without
    /// retrieving the entire pantry.
    ///
    /// - Parameter ingredient: The ingredient to check
    /// - Returns: `true` if the ingredient exists in the pantry, `false` otherwise
    func exists(_ ingredient: Ingredient) -> Bool
}
