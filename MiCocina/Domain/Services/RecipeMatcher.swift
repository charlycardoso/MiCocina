//
//  RecipeMatcher.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Foundation

struct RecipeMatcher {
    func canCook(recipe: Recipe, with pantry: Set<Ingredient>) -> Bool {
        guard !recipe.ingredients.isEmpty else { return false }

        let allIngredients = recipe.ingredients.map { $0.ingredient }
        let missingIngredients = Set(allIngredients).subtracting(pantry)

        return missingIngredients.count <= 3
    }

    func possibleRecipes(from recipes: [Recipe], pantry: Set<Ingredient>) -> [Recipe] {
        let possibleRecipes = recipes.filter { canCook(recipe: $0, with: pantry) }
        return possibleRecipes
    }
}
