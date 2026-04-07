//
//  RecipeDomainRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation

final class RecipeDomainRepository: RecipeProtocolRepository {
    private let RecipeProtocolRepository: RecipeProtocolRepository

    init(RecipeProtocolRepository: RecipeProtocolRepository) {
        self.RecipeProtocolRepository = RecipeProtocolRepository
    }

    func getAll() -> [Recipe] {
        RecipeProtocolRepository.getAll()
    }

    func getByID(_ id: UUID) -> Recipe? {
        RecipeProtocolRepository.getByID(id)
    }

    func getByName(_ name: String) -> Recipe? {
        RecipeProtocolRepository.getByName(name)
    }

    func getByMealType(_ mealType: MealType) -> [Recipe] {
        RecipeProtocolRepository.getByMealType(mealType)
    }

    func getFavorites() -> [Recipe] {
        RecipeProtocolRepository.getFavorites()
    }

    func save(_ recipe: Recipe) throws {
        try RecipeProtocolRepository.save(recipe)
    }

    func delete(_ recipe: Recipe) throws {
        try RecipeProtocolRepository.delete(recipe)
    }

    func update(_ recipe: Recipe) throws {
        try RecipeProtocolRepository.update(recipe)
    }
}
