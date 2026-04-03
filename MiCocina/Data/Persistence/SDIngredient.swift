//
//  SDIngredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import SwiftData
import Foundation

@Model
final class SDIngredient {
    @Attribute(.unique)
    var id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
