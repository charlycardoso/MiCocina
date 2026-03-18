//
//  Ingredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Foundation

struct Ingredient: Equatable, Hashable {
    let id = UUID()
    let name: String
    let quantity: Int = 0

    init(name: String) {
        self.name = name.normalize()
    }

    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
