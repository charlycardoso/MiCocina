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
}
