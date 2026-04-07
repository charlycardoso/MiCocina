//
//  RecipeDomainRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation

/// An adapter implementation of `RecipeProtocolRepository` that delegates to another repository.
///
/// `RecipeDomainRepository` serves as a wrapper or adapter around another `RecipeProtocolRepository`
/// implementation. This pattern enables:
/// - Additional cross-cutting concerns without modifying the original implementation
/// - Composition-based extension of functionality
/// - Consistent interface regardless of underlying storage mechanism
///
/// Currently, this implementation acts as a transparent passthrough, but it can be extended
/// to add logging, caching, validation, or other domain-specific recipe logic.
///
/// - Example:
/// ```swift
/// let baseRepository = SDRecipeProtocolRepository(context: modelContext)
/// let domainRepository = RecipeDomainRepository(RecipeProtocolRepository: baseRepository)
/// ```
final class RecipeDomainRepository: RecipeProtocolRepository {
    /// The underlying repository implementation being wrapped
    private let recipeRepository: RecipeProtocolRepository

    /// Initializes a new recipe domain repository wrapping another repository.
    ///
    /// - Parameter RecipeProtocolRepository: The underlying repository to wrap
    init(RecipeProtocolRepository: RecipeProtocolRepository) {
        self.recipeRepository = RecipeProtocolRepository
    }

    /// Retrieves all recipes through the underlying repository.
    ///
    /// - Returns: An array of all recipes
    func getAll() -> [Recipe] {
        recipeRepository.getAll()
    }

    /// Retrieves a recipe by ID through the underlying repository.
    ///
    /// - Parameter id: The UUID of the recipe to retrieve
    /// - Returns: The recipe if found, or `nil` otherwise
    func getByID(_ id: UUID) -> Recipe? {
        recipeRepository.getByID(id)
    }

    /// Retrieves a recipe by name through the underlying repository.
    ///
    /// - Parameter name: The name of the recipe to retrieve
    /// - Returns: The recipe if found, or `nil` otherwise
    func getByName(_ name: String) -> Recipe? {
        recipeRepository.getByName(name)
    }

    /// Retrieves recipes by meal type through the underlying repository.
    ///
    /// - Parameter mealType: The meal type to filter by
    /// - Returns: An array of recipes matching the meal type
    func getByMealType(_ mealType: MealType) -> [Recipe] {
        recipeRepository.getByMealType(mealType)
    }

    /// Retrieves favorite recipes through the underlying repository.
    ///
    /// - Returns: An array of recipes marked as favorites
    func getFavorites() -> [Recipe] {
        recipeRepository.getFavorites()
    }

    /// Saves a recipe through the underlying repository.
    ///
    /// - Parameter recipe: The recipe to save
    /// - Throws: An error from the underlying repository if the operation fails
    func save(_ recipe: Recipe) throws {
        try recipeRepository.save(recipe)
    }

    /// Deletes a recipe through the underlying repository.
    ///
    /// - Parameter recipe: The recipe to delete
    /// - Throws: An error from the underlying repository if the operation fails
    func delete(_ recipe: Recipe) throws {
        try recipeRepository.delete(recipe)
    }

    /// Updates a recipe through the underlying repository.
    ///
    /// - Parameter recipe: The updated recipe
    /// - Throws: An error from the underlying repository if the operation fails
    func update(_ recipe: Recipe) throws {
        try recipeRepository.update(recipe)
    }
}
