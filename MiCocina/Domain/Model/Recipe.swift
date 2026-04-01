//
//  Recipe.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Foundation

struct Recipe: Equatable {
    let id = UUID()
    let name: String
    let ingredients: Set<RecipeIngredient>
    let mealType: MealType
    let isFavorite: Bool

    init(name: String, ingredients: Set<RecipeIngredient>, mealType: MealType = .other, isFavorite: Bool = false) {
        self.name = name
        self.ingredients = ingredients
        self.mealType = mealType
        self.isFavorite = isFavorite
    }
}
