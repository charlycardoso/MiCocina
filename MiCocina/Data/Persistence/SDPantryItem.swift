//
//  SDPantryItem.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 15/04/26.
//

import Foundation
import SwiftData

@Model
final class SDPantryItem {
    @Attribute
    var id: UUID
    
    var ingredient: SDIngredient
    
    init(id: UUID = .init(), ingredient: SDIngredient) {
        self.id = id
        self.ingredient = ingredient
    }
}
