//
//  RecipeViewData.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

import Foundation

struct RecipeViewData: Equatable {
    let id: UUID
    let name: String
    let mealType: MealType
    let isFavorite: Bool
    let canCook: Bool
    let missingCount: Int
}
