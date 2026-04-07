//
//  RecipeDomainRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation

final class RecipeDomainRepository: RecipeProtocolRepository {
    private let recipeRepository: RecipeProtocolRepository

    init(RecipeProtocolRepository: RecipeProtocolRepository) {
        self.recipeRepository = RecipeProtocolRepository
    }

    func getAll() -> [Recipe] {
        recipeRepository.getAll()
    }

    func getByID(_ id: UUID) -> Recipe? {
        recipeRepository.getByID(id)
    }

    func getByName(_ name: String) -> Recipe? {
        recipeRepository.getByName(name)
    }

    func getByMealType(_ mealType: MealType) -> [Recipe] {
        recipeRepository.getByMealType(mealType)
    }

    func getFavorites() -> [Recipe] {
        recipeRepository.getFavorites()
    }

    func save(_ recipe: Recipe) throws {
        try recipeRepository.save(recipe)
    }

    func delete(_ recipe: Recipe) throws {
        try recipeRepository.delete(recipe)
    }

    func update(_ recipe: Recipe) throws {
        try recipeRepository.update(recipe)
    }
}
