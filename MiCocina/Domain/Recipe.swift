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
    let ingredients: Set<Ingredient>
}
