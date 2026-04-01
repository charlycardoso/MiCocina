//
//  RecipeIngredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 17/03/26.
//

struct RecipeIngredient: Hashable {
    let ingredient: Ingredient
    let isRequired: Bool

    init(ingredient: Ingredient, isRequired: Bool = true) {
        self.ingredient = ingredient
        self.isRequired = isRequired
    }
}
