//
//  MockRecipeRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

import Foundation

final class MockRecipeRepository: RecipeProtocolRepository {
    private(set) var recipes: [Recipe]

    init(recipes: [Recipe] = []) {
        self.recipes = recipes
    }

    func getAll() -> [Recipe] {
        recipes
    }

    func getByID(_ id: UUID) -> Recipe? {
        recipes.first { $0.id == id }
    }
    
    func getByName(_ name: String) -> Recipe? {
        recipes.first { $0.name == name }
    }
    
    func getByMealType(_ mealType: MealType) -> [Recipe] {
        recipes.filter { $0.mealType == mealType }
    }
    
    func getFavorites() -> [Recipe] {
        recipes.filter { $0.isFavorite }
    }
    
    func save(_ recipe: Recipe) throws {
        if !recipes.contains(where: { $0.id == recipe.id }) {
            recipes.append(recipe)
        }
    }
    
    func delete(_ recipe: Recipe) throws {
        recipes.removeAll { $0.id == recipe.id }
    }

    func update(_ recipe: Recipe) throws {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        }
    }
}
