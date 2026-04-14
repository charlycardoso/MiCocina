//
//  DomainMapper.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import Foundation

/// Converts persistence models to domain models.
///
/// `DomainMapper` is responsible for transforming storage layer models (`SD*` classes)
/// into domain layer models. This mapper enables the application to maintain a clear
/// separation between persistence implementation details and business logic.
///
/// All mappings are static methods for convenience and to emphasize the stateless
/// nature of the mapping operations.
///
/// - Example:
/// ```swift
/// let sdRecipe = sdRecipeFromDatabase
/// let domainRecipe = DomainMapper.toDomain(recipe: sdRecipe)
/// ```
final class DomainMapper {
    
    // MARK: - Recipe Mapping
    
    /// Converts a storage recipe model to a domain recipe model.
    ///
    /// Transforms a `SDRecipe` persistence model into a `Recipe` domain model by:
    /// 1. Converting the meal type string to a `MealType` enum
    /// 2. Recursively converting all storage ingredients to domain ingredients
    /// 3. Preserving all recipe properties and relationships
    ///
    /// - Parameter recipe: The storage recipe model to convert
    /// - Returns: A domain `Recipe` model with all ingredients converted
    static func toDomain(recipe: SDRecipe) -> Recipe {
        var recipeIngredients: Set<RecipeIngredient> = .init()
        recipe.ingredients.forEach { recipe in
            let recipeIngredient = DomainMapper.toDomain(recipeIngredient: recipe)
            recipeIngredients.insert(recipeIngredient)
        }
        return .init(
            id: recipe.id,
            name: recipe.name,
            ingredients: recipeIngredients,
            mealType: MealType.rawValue(recipe.mealType),
            isFavorite: recipe.isFavorite
        )
    }

    // MARK: - Ingredient Mapping
    
    /// Converts a storage ingredient model to a domain ingredient model.
    ///
    /// - Parameter ingredient: The storage ingredient model to convert
    /// - Returns: A domain `Ingredient` model
    static func toDomain(ingredient: SDIngredient) -> Ingredient {
        return .init(id: ingredient.id, name: ingredient.name)
    }

    // MARK: - RecipeIngredient Mapping
    
    /// Converts a storage recipe-ingredient association to a domain recipe-ingredient.
    ///
    /// - Parameter recipeIngredient: The storage recipe-ingredient model to convert
    /// - Returns: A domain `RecipeIngredient` model with the ingredient converted
    static func toDomain(recipeIngredient: SDRecipeIngredient) -> RecipeIngredient {
        let ingredient = DomainMapper.toDomain(ingredient: recipeIngredient.ingredient)
        return .init(ingredient: ingredient, isRequired: recipeIngredient.isRequired)
    }

    static func toDomain(planner: SDPlannerData) -> PlannerData {
        let recipes = planner.recipes.map { toDomain(recipe: $0) }

        return PlannerData(
            id: planner.id,
            day: planner.day,
            recipes: recipes
        )
    }

    // MARK: - ShoppingListItem Mapping
    
    /// Converts a persistence shopping list item to a domain shopping list item.
    ///
    /// - Parameter shoppingListItem: The storage shopping list item to convert
    /// - Returns: A domain `ShoppingListItem` model
    static func toDomain(shoppingListItem: SDShoppingListItem) -> ShoppingListItem {
        let ingredient = toDomain(ingredient: shoppingListItem.ingredient)
        
        return ShoppingListItem(
            id: shoppingListItem.id,
            ingredient: ingredient,
            isBought: shoppingListItem.isBought
        )
    }
}
