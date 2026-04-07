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
    /// - Returns: An array of `Recipe` domain objects. Returns empty array if fetch fails.
    func getAll() -> [Recipe] {
        let descriptor = FetchDescriptor<SDRecipe>()
        do {
            let sdRecipes = try context.fetch(descriptor)
            return sdRecipes.map { DomainMapper.toDomain(recipe: $0) }
        } catch {
            // Log the error for debugging but return empty array to match protocol
            print("RepositoryError.fetchFailed(operation: \"getAll\", underlyingError: \(error))")
            return []
        }
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
        do {
            let sdRecipe = try context.fetch(descriptor).first
            return sdRecipe.map { DomainMapper.toDomain(recipe: $0) }
        } catch {
            // Log the error for debugging but return nil to match protocol
            print("RepositoryError.fetchFailed(operation: \"getByID(\(id))\", underlyingError: \(error))")
            return nil
        }
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
        do {
            let sdRecipe = try context.fetch(descriptor).last
            return sdRecipe.map { DomainMapper.toDomain(recipe: $0) }
        } catch {
            // Log the error for debugging but return nil to match protocol
            print("RepositoryError.fetchFailed(operation: \"getByName(\(name))\", underlyingError: \(error))")
            return nil
        }
    }
    
    /// Retrieves all recipes that match a specific meal type.
    ///
    /// - Parameter mealType: The `MealType` to filter recipes by.
    /// - Returns: An array of `Recipe` domain objects that match the specified meal type.
    func getByMealType(_ mealType: MealType) -> [Recipe] {
        let mealTypeString: String = mealType.rawValue
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.mealType == mealTypeString }
        )
        do {
            let sdRecipes = try context.fetch(descriptor)
            return sdRecipes.map { DomainMapper.toDomain(recipe: $0) }
        } catch {
            // Log the error for debugging but return empty array to match protocol
            print("RepositoryError.fetchFailed(operation: \"getByMealType(\(mealType))\", underlyingError: \(error))")
            return []
        }
    }
    
    /// Retrieves all recipes marked as favorites.
    ///
    /// - Returns: An array of `Recipe` domain objects that are marked as favorites.
    func getFavorites() -> [Recipe] {
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.isFavorite }
        )
        do {
            let sdRecipes = try context.fetch(descriptor)
            return sdRecipes.map { DomainMapper.toDomain(recipe: $0) }
        } catch {
            // Log the error for debugging but return empty array to match protocol
            print("RepositoryError.fetchFailed(operation: \"getFavorites\", underlyingError: \(error))")
            return []
        }
    }
    
    /// Saves a recipe to the database.
    ///
    /// If a recipe with the same ID already exists, this method will update the existing
    /// recipe instead of creating a new one.
    ///
    /// - Parameter recipe: The `Recipe` domain object to save.
    /// - Throws: `RepositoryError` if the operation fails.
    func save(_ recipe: Recipe) throws {
        let recipeUUID: UUID = recipe.id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        
        do {
            if let _ = try context.fetch(descriptor).first {
                try update(recipe)
                return
            }
        } catch {
            throw RepositoryError.fetchFailed(operation: "save - checking existing recipe", underlyingError: error)
        }
        
        let sdRecipe = StorageMapper.toStorage(recipe: recipe, context: context)
        do {
            try context.save()
        } catch {
            throw RepositoryError.saveFailed(operation: "save new recipe", underlyingError: error)
        }
    }
    
    /// Deletes a recipe from the database.
    ///
    /// This method removes the recipe with the matching ID from the database.
    /// If no recipe with the specified ID exists, the method completes without error.
    ///
    /// - Parameter recipe: The `Recipe` domain object to delete. Only the ID is used for identification.
    /// - Throws: `RepositoryError` if the operation fails.
    func delete(_ recipe: Recipe) throws {
        let recipeUUID: UUID = recipe.id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        
        do {
            if let sdRecipe = try context.fetch(descriptor).first {
                context.delete(sdRecipe)
                try context.save()
            }
        } catch let error where error is NSError {
            if (error as NSError).domain.contains("delete") || (error as NSError).localizedDescription.lowercased().contains("delete") {
                throw RepositoryError.deleteFailed(operation: "delete recipe \(recipe.id)", underlyingError: error)
            } else {
                throw RepositoryError.fetchFailed(operation: "delete - finding recipe to delete", underlyingError: error)
            }
        } catch {
            throw RepositoryError.fetchFailed(operation: "delete - finding recipe to delete", underlyingError: error)
        }
    }

    /// Updates an existing recipe in the database.
    ///
    /// This method updates all properties of the recipe, including its ingredients.
    /// All existing ingredients are removed and replaced with the new ones from the domain object.
    ///
    /// - Parameter recipe: The `Recipe` domain object containing the updated data.
    /// - Throws: `RepositoryError` if the operation fails.
    /// - Important: This method completely replaces the ingredients collection. Any existing
    ///   ingredient relationships will be deleted and recreated.
    func update(_ recipe: Recipe) throws {
        let recipeUUID: UUID = recipe.id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        
        let sdRecipe: SDRecipe
        do {
            guard let foundRecipe = try context.fetch(descriptor).first else {
                throw RepositoryError.entityNotFound(entityType: "Recipe", identifier: recipe.id.uuidString)
            }
            sdRecipe = foundRecipe
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.fetchFailed(operation: "update - finding recipe to update", underlyingError: error)
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
        
        do {
            try context.save()
        } catch {
            throw RepositoryError.updateFailed(operation: "update recipe \(recipe.id)", underlyingError: error)
        }
    }
}
