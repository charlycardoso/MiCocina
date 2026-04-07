//
//  MockRecipeRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

import Foundation

/// A mock implementation of `RecipeProtocolRepository` for testing purposes.
///
/// `MockRecipeRepository` provides an in-memory implementation of the recipe repository
/// protocol, storing recipes in a simple array. This implementation is designed for:
/// - Unit testing recipe-related functionality
/// - Integration testing without database dependencies
/// - Prototyping and development
///
/// All operations are performed in-memory and data is not persisted across instances.
///
/// - Example:
/// ```swift
/// let recipes = [recipe1, recipe2]
/// let mockRepository = MockRecipeRepository(recipes: recipes)
/// XCTAssertEqual(mockRepository.getAll().count, 2)
/// ```
final class MockRecipeRepository: RecipeProtocolRepository {
    /// The in-memory collection of recipes
    private(set) var recipes: [Recipe]

    /// Initializes a mock recipe repository with an optional set of recipes.
    ///
    /// - Parameter recipes: An array of recipes to initialize the repository with.
    ///                     Defaults to an empty array.
    init(recipes: [Recipe] = []) {
        self.recipes = recipes
    }

    /// Returns all recipes in the repository.
    ///
    /// - Returns: An array of all recipes
    func getAll() -> [Recipe] {
        recipes
    }

    /// Finds a recipe by its unique identifier.
    ///
    /// - Parameter id: The UUID of the recipe to find
    /// - Returns: The recipe if found, or `nil` otherwise
    func getByID(_ id: UUID) -> Recipe? {
        recipes.first { $0.id == id }
    }
    
    /// Finds a recipe by its name.
    ///
    /// - Parameter name: The name of the recipe to find
    /// - Returns: The recipe if found, or `nil` otherwise
    func getByName(_ name: String) -> Recipe? {
        recipes.first { $0.name == name }
    }
    
    /// Retrieves all recipes of a specific meal type.
    ///
    /// - Parameter mealType: The meal type to filter by
    /// - Returns: An array of recipes matching the meal type
    func getByMealType(_ mealType: MealType) -> [Recipe] {
        recipes.filter { $0.mealType == mealType }
    }
    
    /// Retrieves all favorite recipes.
    ///
    /// - Returns: An array of recipes marked as favorites
    func getFavorites() -> [Recipe] {
        recipes.filter { $0.isFavorite }
    }
    
    /// Saves a new recipe to the mock repository.
    ///
    /// - Parameter recipe: The recipe to save
    /// - Throws: Never throws
    ///
    /// - Note: Duplicate IDs are not added to the collection
    func save(_ recipe: Recipe) throws {
        if !recipes.contains(where: { $0.id == recipe.id }) {
            recipes.append(recipe)
        }
    }
    
    /// Deletes a recipe from the mock repository.
    ///
    /// - Parameter recipe: The recipe to delete
    /// - Throws: Never throws
    ///
    /// - Note: Silently succeeds if the recipe doesn't exist
    func delete(_ recipe: Recipe) throws {
        recipes.removeAll { $0.id == recipe.id }
    }

    /// Updates an existing recipe in the mock repository.
    ///
    /// - Parameter recipe: The updated recipe
    /// - Throws: Never throws
    ///
    /// - Note: Only updates if a recipe with the same ID exists
    func update(_ recipe: Recipe) throws {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        }
    }
}
