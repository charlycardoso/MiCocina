//
//  StorageMapper.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import SwiftData
import Foundation

/// Converts domain models to persistence models for storage.
///
/// `StorageMapper` is responsible for transforming domain layer models into storage
/// layer models (`SD*` classes) for persistence. This mapper maintains database integrity
/// by handling relationships, deduplication, and context management.
///
/// All mappings require a `ModelContext` for database operations such as fetching
/// existing entities and inserting new records.
///
/// - Important: The caller is responsible for managing the `ModelContext` lifecycle
///   and calling `context.save()` after using the mapper.
///
/// - Example:
/// ```swift
/// let domainRecipe = Recipe(...)
/// let sdRecipe = StorageMapper.toStorage(recipe: domainRecipe, context: modelContext)
/// try modelContext.save()
/// ```
final class StorageMapper {

    // MARK: - SDIngredient Mapping
    
    /// Converts a domain ingredient to a persistence ingredient, reusing existing entries.
    ///
    /// If an ingredient with the same ID already exists in the database, the existing
    /// instance is returned to maintain data integrity. Otherwise, a new ingredient is
    /// created and inserted into the context.
    ///
    /// - Parameters:
    ///   - ingredient: The domain ingredient to convert
    ///   - context: The SwiftData model context for database operations
    ///
    /// - Returns: A persistence `SDIngredient` model (either new or existing)
    static func toStorage(
        with ingredient: Ingredient,
        context: ModelContext
    ) -> SDIngredient {
        let name = ingredient.name
        let id = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == id }
        )

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        // Create new if it doesn't exist
        let new = SDIngredient(id: ingredient.id, name: name)
        context.insert(new)
        return new
    }

    // MARK: - SDRecipe Mapping
    
    /// Converts a domain recipe to a persistence recipe with all ingredients.
    ///
    /// Creates a new storage recipe and automatically converts and saves all associated
    /// recipe-ingredient relationships. Uses deduplication to avoid creating duplicate
    /// ingredient entries.
    ///
    /// - Parameters:
    ///   - domain: The domain recipe to convert
    ///   - context: The SwiftData model context for database operations
    ///
    /// - Returns: A persistence `SDRecipe` model with ingredients
    static func toStorage(
        recipe domain: Recipe,
        context: ModelContext
    ) -> SDRecipe {
        let sdRecipe = SDRecipe(
            id: domain.id,
            name: domain.name,
            mealType: domain.mealType.rawValue,
            isFavorite: domain.isFavorite
        )

        context.insert(sdRecipe)

        domain.ingredients.forEach { recipeIngredient in
            let sdIngredient = StorageMapper.toStorage(
                with: recipeIngredient.ingredient,
                context: context
            )

            let sdRecipeIngredient = SDRecipeIngredient(
                recipe: sdRecipe,
                ingredient: sdIngredient,
                quantity: nil,
                isRequired: recipeIngredient.isRequired
            )

            context.insert(sdRecipeIngredient)
            sdRecipe.ingredients.append(sdRecipeIngredient)
        }

        return sdRecipe
    }

    // MARK: - SDRecipeIngredient Mapping
    
    /// Converts a domain recipe-ingredient to a persistence recipe-ingredient.
    ///
    /// Creates a new association between a recipe and an ingredient, ensuring both
    /// are properly inserted into the context before creating the relationship.
    ///
    /// - Parameters:
    ///   - domain: The domain recipe-ingredient to convert
    ///   - recipe: The persistence recipe entity
    ///   - ingredient: The persistence ingredient entity
    ///   - context: The SwiftData model context for database operations
    ///
    /// - Returns: A persistence `SDRecipeIngredient` model
    static func toStorage(
        _ domain: RecipeIngredient,
        recipe: SDRecipe,
        ingredient: SDIngredient,
        context: ModelContext
    ) -> SDRecipeIngredient {

        // Ensure the SDIngredient exists in the context
        if ingredient.persistentModelID.storeIdentifier == nil {
            context.insert(ingredient)
        }

        // Ensure the SDRecipe is inserted
        if recipe.persistentModelID.storeIdentifier == nil {
            context.insert(recipe)
        }

        // Now create the RecipeIngredient
        let new = SDRecipeIngredient(
            recipe: recipe,
            ingredient: ingredient,
            quantity: nil,
            isRequired: domain.isRequired
        )

        context.insert(new)
        return new
    }
}
