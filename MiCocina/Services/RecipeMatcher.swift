//
//  RecipeMatcher.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Foundation

struct RecipeMatcher {
    func canCook(recipe: Recipe, with pantry: Set<Ingredient>) -> Bool {
        let requiredIngredients = recipe.ingredients
            .filter { $0.isRequired }
            .map { $0.ingredient }

        return Set(requiredIngredients).isSubset(of: pantry)
    }

    func possibleRecipes(from recipes: [Recipe], pantry: Set<Ingredient>) -> [Recipe] {
        let possibleRecipes = recipes.filter { canCook(recipe: $0, with: pantry) }
        return possibleRecipes
    }
}
