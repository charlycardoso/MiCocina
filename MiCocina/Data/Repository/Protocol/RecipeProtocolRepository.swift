//
//  RecipeProtocolRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation

/// A protocol defining the data access contract for recipe operations.
///
/// `RecipeProtocolRepository` abstracts the persistence layer for recipe operations,
/// allowing the domain layer to remain independent of specific storage implementations
/// (database, file system, network, etc.).
///
/// This protocol follows the Repository pattern and the Dependency Inversion Principle,
/// enabling easy testing with mock implementations and flexible persistence strategies.
///
/// - Important: Implementations should handle concurrency and error states appropriately.
///
/// - Example:
/// ```swift
/// let repository: RecipeProtocolRepository = SDRecipeProtocolRepository(context: modelContext)
/// let allRecipes = repository.getAll()
/// try repository.save(newRecipe)
/// ```
protocol RecipeProtocolRepository {
    // MARK: - READ Operations
    
    /// Retrieves all recipes from the repository.
    ///
    /// - Returns: An array of all recipes, or an empty array if none exist
    func getAll() -> [Recipe]
    
    /// Retrieves a specific recipe by its unique identifier.
    ///
    /// - Parameter id: The UUID of the recipe to retrieve
    /// - Returns: The recipe if found, or `nil` if no recipe matches the ID
    func getByID(_ id: UUID) -> Recipe?
    
    /// Retrieves a recipe by its name.
    ///
    /// - Parameter name: The name of the recipe to retrieve
    /// - Returns: The recipe if found, or `nil` if no recipe matches the name
    /// - Note: If multiple recipes have the same name, the last one is returned
    func getByName(_ name: String) -> Recipe?
    
    /// Retrieves all recipes of a specific meal type.
    ///
    /// - Parameter mealType: The meal type to filter by
    /// - Returns: An array of recipes matching the meal type, or empty array if none found
    func getByMealType(_ mealType: MealType) -> [Recipe]
    
    /// Retrieves all recipes marked as favorites.
    ///
    /// - Returns: An array of favorite recipes, or empty array if none found
    func getFavorites() -> [Recipe]
    
    // MARK: - WRITE Operations
    
    /// Saves a new recipe to the repository.
    ///
    /// If a recipe with the same ID already exists, the save operation fails silently
    /// or may update the existing recipe depending on the implementation.
    ///
    /// - Parameter recipe: The recipe to save
    /// - Throws: An error if the save operation fails
    ///
    /// - Note: This operation is idempotent when combined with update operations
    func save(_ recipe: Recipe) throws
    
    /// Deletes a recipe from the repository.
    ///
    /// - Parameter recipe: The recipe to delete
    /// - Throws: An error if the delete operation fails
    /// - Note: If the recipe doesn't exist, the operation succeeds silently
    func delete(_ recipe: Recipe) throws
    
    // MARK: - UPDATE Operations
    
    /// Updates an existing recipe in the repository.
    ///
    /// The recipe is identified by its ID. If no recipe with the given ID exists,
    /// the update may fail or create a new recipe depending on the implementation.
    ///
    /// - Parameter recipe: The updated recipe data
    /// - Throws: An error if the update operation fails or the recipe is not found
    func update(_ recipe: Recipe) throws
}
