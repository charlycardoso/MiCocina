//
//  SDRecipeIngredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import SwiftData
import Foundation

@Model
final class SDRecipeIngredient {
    @Attribute(.unique)
    var id: UUID
    
    // Relación hacia la receta a la que pertenece
    var recipe: SDRecipe
    
    // Relación hacia el ingrediente crudo
    var ingredient: SDIngredient
    
    // Ahorita no usas quantity, pero lo dejamos opcional para el futuro
    var quantity: Double?
    
    // Lo tienes en tu dominio
    var isRequired: Bool
    
    init(
        id: UUID = UUID(),
        recipe: SDRecipe,
        ingredient: SDIngredient,
        quantity: Double? = nil,
        isRequired: Bool
    ) {
        self.id = id
        self.recipe = recipe
        self.ingredient = ingredient
        self.quantity = quantity
        self.isRequired = isRequired
    }
}
