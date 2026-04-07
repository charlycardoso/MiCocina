//
//  SDRecipeProtocolRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 03/04/26.
//

import SwiftData
import Foundation

/// A SwiftData implementation of the `RecipeProtocolRepository` protocol.
///
/// This repository manages recipe data persistence using SwiftData's `ModelContext`.
/// It provides methods to perform CRUD operations on recipes, including fetching,
/// saving, updating, and deleting recipe data. The repository handles the conversion
/// between domain objects (`Recipe`) and SwiftData models (`SDRecipe`).
///
/// - Important: All operations that modify data (save, update, delete) can throw errors
///   and should be handled appropriately by the caller.
final class SDRecipeProtocolRepository: RecipeProtocolRepository {
    /// The SwiftData model context used for database operations.
    let context: ModelContext

    /// Initializes the repository with a SwiftData model context.
    ///
    /// - Parameter context: The SwiftData `ModelContext` to use for all database operations.
    init(context: ModelContext) {
        self.context = context
    }

    /// Retrieves all recipes from the database.
    ///
    /// - Returns: An array of `Recipe` domain objects. Returns an empty array if no recipes
    ///   are found or if an error occurs during the fetch operation.
    func getAll() -> [Recipe] {
        let descriptor = FetchDescriptor<SDRecipe>()
        guard let sdRecipes = try? context.fetch(descriptor) else { return [] }
        return sdRecipes.map { DomainMapper.toDomain(recipe: $0) }
    }

    /// Retrieves a recipe by its unique identifier.
    ///
    /// - Parameter id: The UUID of the recipe to fetch.
    /// - Returns: The `Recipe` domain object if found, otherwise `nil`.
    func getByID(_ id: UUID) -> Recipe? {
        let recipeUUID: UUID = id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        guard let sdRecipe = try? context.fetch(descriptor).first else { return nil }
        return DomainMapper.toDomain(recipe: sdRecipe)
    }
    
    /// Retrieves a recipe by its name.
    ///
    /// - Parameter name: The name of the recipe to search for.
    /// - Returns: The most recently found `Recipe` domain object with the matching name,
    ///   or `nil` if no recipe with that name exists.
    /// - Note: If multiple recipes have the same name, this method returns the last one found.
    func getByName(_ name: String) -> Recipe? {
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.name == name }
        )
        guard let sdRecipe = try? context.fetch(descriptor).last else { return nil }
        return DomainMapper.toDomain(recipe: sdRecipe)
    }
    
    /// Retrieves all recipes that match a specific meal type.
    ///
    /// - Parameter mealType: The `MealType` to filter recipes by.
    /// - Returns: An array of `Recipe` domain objects that match the specified meal type.
    ///   Returns an empty array if no matching recipes are found or if an error occurs.
    func getByMealType(_ mealType: MealType) -> [Recipe] {
        let mealTypeString: String = mealType.rawValue
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.mealType == mealTypeString }
        )
        guard let sdRecipes = try? context.fetch(descriptor) else { return [] }
        return sdRecipes.map { DomainMapper.toDomain(recipe: $0) }
    }
    
    /// Retrieves all recipes marked as favorites.
    ///
    /// - Returns: An array of `Recipe` domain objects that are marked as favorites.
    ///   Returns an empty array if no favorite recipes exist or if an error occurs.
    func getFavorites() -> [Recipe] {
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.isFavorite }
        )
        guard let sdRecipes = try? context.fetch(descriptor) else { return [] }
        return sdRecipes.map { DomainMapper.toDomain(recipe: $0) }
    }
    
    /// Saves a recipe to the database.
    ///
    /// If a recipe with the same ID already exists, this method will update the existing
    /// recipe instead of creating a new one.
    ///
    /// - Parameter recipe: The `Recipe` domain object to save.
    /// - Throws: An error if the save operation fails or if the update operation fails.
    func save(_ recipe: Recipe) throws {
        let recipeUUID: UUID = recipe.id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        if let _ = try? context.fetch(descriptor).first {
            try update(recipe)
            return
        }
        let sdRecipe = StorageMapper.toStorage(recipe: recipe, context: context)
        try context.save()
    }
    
    /// Deletes a recipe from the database.
    ///
    /// This method removes the recipe with the matching ID from the database.
    /// If no recipe with the specified ID exists, the method completes without error.
    ///
    /// - Parameter recipe: The `Recipe` domain object to delete. Only the ID is used for identification.
    /// - Throws: An error if the delete operation fails or if saving the context fails.
    func delete(_ recipe: Recipe) throws {
        let recipeUUID: UUID = recipe.id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        if let sdRecipe = try? context.fetch(descriptor).first {
            context.delete(sdRecipe)
            try context.save()
        }
    }

    /// Updates an existing recipe in the database.
    ///
    /// This method updates all properties of the recipe, including its ingredients.
    /// All existing ingredients are removed and replaced with the new ones from the domain object.
    ///
    /// - Parameter recipe: The `Recipe` domain object containing the updated data.
    /// - Throws: An `NSError` with code 404 if the recipe is not found in the database,
    ///   or any other error that occurs during the fetch or save operations.
    /// - Important: This method completely replaces the ingredients collection. Any existing
    ///   ingredient relationships will be deleted and recreated.
    func update(_ recipe: Recipe) throws {
        let recipeUUID: UUID = recipe.id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        guard let sdRecipe = try context.fetch(descriptor).first else {
            throw NSError(domain: "RecipeProtocolRepository", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Recipe not found"
            ])
        }
        sdRecipe.name = recipe.name
        sdRecipe.mealType = recipe.mealType.rawValue
        sdRecipe.isFavorite = recipe.isFavorite
        for old in sdRecipe.ingredients {
            context.delete(old)
        }
        sdRecipe.ingredients.removeAll()
        for ingredient in recipe.ingredients {
            let sdIngredient = StorageMapper.toStorage(
                with: ingredient.ingredient,
                context: context
            )
            let sdRecipeIngredient = SDRecipeIngredient(
                recipe: sdRecipe,
                ingredient: sdIngredient,
                quantity: nil,
                isRequired: ingredient.isRequired
            )
            sdRecipe.ingredients.append(sdRecipeIngredient)
        }
        try context.save()
    }
}
