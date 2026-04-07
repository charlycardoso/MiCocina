//
//  RecipeProtocolRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation

protocol RecipeProtocolRepository {
    // READ
    func getAll() -> [Recipe]
    func getByID(_ id: UUID) -> Recipe?
    func getByName(_ name: String) -> Recipe?
    func getByMealType(_ mealType: MealType) -> [Recipe]
    func getFavorites() -> [Recipe]
    // WRITE
    func save(_ recipe: Recipe) throws
    func delete(_ recipe: Recipe) throws
    // UPDATE
    func update(_ recipe: Recipe) throws
}
