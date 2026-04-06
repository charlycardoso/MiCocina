//
//  DomainMapper.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import Foundation

final class DomainMapper {
    // MARK: Recipe
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

    // MARK: Ingredient
    static func toDomain(ingredient: SDIngredient) -> Ingredient {
        return .init(id: ingredient.id, name: ingredient.name)
    }

    // MARK: RecipeIngredient
    static func toDomain(recipeIngredient: SDRecipeIngredient) -> RecipeIngredient {
        let ingredient = DomainMapper.toDomain(ingredient: recipeIngredient.ingredient)
        return .init(ingredient: ingredient, isRequired: recipeIngredient.isRequired)
    }
}
