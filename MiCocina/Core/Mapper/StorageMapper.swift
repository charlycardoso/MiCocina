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

        let new = SDIngredient(id: id, name: name)
        context.insert(new)
        return new
    }

    // MARK: - SDPantryItem Mapping

    /// Converts a domain ingredient to a pantry persistence item.
    ///
    /// Creates (or reuses) the underlying `SDIngredient` and wraps it in a new `SDPantryItem`.
    static func toStorage(
        pantryItem ingredient: Ingredient,
        context: ModelContext
    ) -> SDPantryItem {
        let sdIngredient = toStorage(with: ingredient, context: context)
        let sdPantryItem = SDPantryItem(ingredient: sdIngredient)
        context.insert(sdPantryItem)
        return sdPantryItem
    }

    // MARK: - SDRecipe Mapping
    
    /// Converts a domain recipe to a persistence recipe with ingredient names.
    ///
    /// Creates a new storage recipe and stores ingredient names directly in SDRecipeIngredient.
    /// **Important**: This does NOT create SDIngredient entries or affect the pantry.
    /// Recipe ingredients are stored as simple name strings.
    ///
    /// **Architecture**: Recipe ingredients are completely separate from pantry ingredients.
    /// - Recipes store: ingredient names
    /// - Pantry stores: ingredient names + quantities
    /// - RecipeMatcher: compares names between recipes and pantry
    ///
    /// - Parameters:
    ///   - domain: The domain recipe to convert
    ///   - context: The SwiftData model context for database operations
    ///
    /// - Returns: A persistence `SDRecipe` model with ingredient names
    static func toStorage(
        recipe domain: Recipe,
        context: ModelContext
    ) -> SDRecipe {
        // Return the existing record if one with this UUID is already in the store.
        // SDRecipe.id is @Attribute(.unique), so inserting a duplicate UUID causes
        // a SwiftData constraint-violation crash.
        let id = domain.id
        let existingDescriptor = FetchDescriptor<SDRecipe>(predicate: #Predicate { $0.id == id })
        if let existing = try? context.fetch(existingDescriptor).first {
            return existing
        }

        let sdRecipe = SDRecipe(
            id: domain.id,
            name: domain.name,
            mealType: domain.mealType.rawValue,
            isFavorite: domain.isFavorite
        )

        context.insert(sdRecipe)

        // Create recipe-ingredient entries with just the ingredient names
        // NO SDIngredient objects are created or referenced
        domain.ingredients.forEach { recipeIngredient in
            let sdRecipeIngredient = SDRecipeIngredient(
                recipe: sdRecipe,
                ingredientName: recipeIngredient.ingredientName,
                quantity: nil,
                isRequired: recipeIngredient.isRequired
            )

            context.insert(sdRecipeIngredient)
            sdRecipe.ingredients.append(sdRecipeIngredient)
        }

        return sdRecipe
    }

    // MARK: - SDPlannerData Mapping
    
    static func toStorage(
        planner: PlannerData,
        context: ModelContext
    ) -> SDPlannerData {

        let sdRecipes = planner.recipes.map {
            toStorage(recipe: $0, context: context)
        }

        let sdPlanner = SDPlannerData(
            id: planner.id,
            day: planner.day,
            recipes: sdRecipes
        )

        context.insert(sdPlanner)

        return sdPlanner
    }
    
    // MARK: - SDShoppingListItem Mapping
    
    /// Converts a domain shopping list item to a persistence shopping list item.
    ///
    /// Creates a new shopping list item in storage, ensuring the ingredient is properly
    /// stored or reused if it already exists.
    ///
    /// - Parameters:
    ///   - item: The domain shopping list item to convert
    ///   - context: The SwiftData model context for database operations
    ///
    /// - Returns: A persistence `SDShoppingListItem` model
    static func toStorage(
        shoppingListItem item: ShoppingListItem,
        context: ModelContext
    ) -> SDShoppingListItem {
        let sdIngredient = toStorage(with: item.ingredient, context: context)
        
        let sdItem = SDShoppingListItem(
            id: item.id,
            ingredient: sdIngredient,
            isBought: item.isBought
        )
        
        context.insert(sdItem)
        return sdItem
    }
}
