//
//  RecipeIngredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 17/03/26.
//

import Foundation

struct RecipeIngredient: Identifiable, Hashable {
    let id: UUID
    let ingredient: Ingredient
    let isRequired: Bool

    init(id: UUID = .init(), ingredient: Ingredient, isRequired: Bool = true) {
        self.id = id
        self.ingredient = ingredient
        self.isRequired = isRequired
    }
}
