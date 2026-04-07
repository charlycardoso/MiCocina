//
//  PantryDomainRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation

/// An adapter implementation of `PantryProtocolRepository` that delegates to another repository.
///
/// `PantryDomainRepository` serves as a wrapper or adapter around another `PantryProtocolRepository`
/// implementation. This pattern allows for:
/// - Additional cross-cutting concerns to be added without modifying the original implementation
/// - Composition-based extension of functionality
/// - Test doubles and dependency injection patterns
///
/// Currently, this implementation acts as a transparent passthrough, but it can be extended
/// to add logging, caching, validation, or other domain-specific logic.
///
/// - Example:
/// ```swift
/// let baseRepository = SDPantryProtocolRepository(context: modelContext)
/// let domainRepository = PantryDomainRepository(PantryProtocolRepository: baseRepository)
/// // Now use domainRepository as a PantryProtocolRepository
/// ```
final class PantryDomainRepository: PantryProtocolRepository {
    /// The underlying repository implementation being wrapped
    private let pantryRepository: PantryProtocolRepository

    /// Initializes a new pantry domain repository wrapping another repository.
    ///
    /// - Parameter PantryProtocolRepository: The underlying repository to wrap
    init(PantryProtocolRepository: PantryProtocolRepository) {
        self.pantryRepository = PantryProtocolRepository
    }

    /// Retrieves the pantry from the underlying repository.
    ///
    /// - Returns: A set of all ingredients in the pantry
    func getPantry() -> Set<Ingredient> {
        pantryRepository.getPantry()
    }

    /// Adds an ingredient through the underlying repository.
    ///
    /// - Parameter ingredient: The ingredient to add
    /// - Throws: An error from the underlying repository if the operation fails
    func add(_ ingredient: Ingredient) throws {
        try pantryRepository.add(ingredient)
    }

    /// Removes an ingredient through the underlying repository.
    ///
    /// - Parameter ingredient: The ingredient to remove
    /// - Throws: An error from the underlying repository if the operation fails
    func remove(_ ingredient: Ingredient) throws {
        try pantryRepository.remove(ingredient)
    }

    /// Updates an ingredient through the underlying repository.
    ///
    /// - Parameter ingredient: The ingredient with updated information
    /// - Throws: An error from the underlying repository if the operation fails
    func update(_ ingredient: Ingredient) throws {
        try pantryRepository.update(ingredient)
    }

    /// Clears the pantry through the underlying repository.
    ///
    /// - Throws: An error from the underlying repository if the operation fails
    func clear() throws {
        try pantryRepository.clear()
    }

    /// Checks ingredient existence through the underlying repository.
    ///
    /// - Parameter ingredient: The ingredient to check
    /// - Returns: `true` if the ingredient exists, `false` otherwise
    func exists(_ ingredient: Ingredient) -> Bool {
        pantryRepository.exists(ingredient)
    }
}
