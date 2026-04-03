//
//  SDRecipe.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import SwiftData
import Foundation

@Model
final class SDRecipe {
    @Attribute(.unique)
    var id: UUID

    var name: String
    var mealType: String
    var isFavorite: Bool

    @Relationship(deleteRule: .cascade, inverse: \SDRecipeIngredient.recipe)
    var ingredients: [SDRecipeIngredient] = []

    init(id: UUID = UUID(), name: String, mealType: String, isFavorite: Bool) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.isFavorite = isFavorite
    }
}
