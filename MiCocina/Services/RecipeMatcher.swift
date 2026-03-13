//
//  RecipeMatcher.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Foundation

struct RecipeMatcher {
    func canCook(recipe: Recipe, with pantry: Set<Ingredient>) -> Bool {
        recipe.ingredients.isSubset(of: pantry)
    }
}
