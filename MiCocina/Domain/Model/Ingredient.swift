//
//  Ingredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Foundation

struct Ingredient: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let quantity: Int = 0

    init(id: UUID = .init(), name: String) {
        self.id = id
        self.name = name.normalize()
    }
}
