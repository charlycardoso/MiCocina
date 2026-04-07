//
//  MockRecipeProtocolRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

import Foundation

final class MockRecipeProtocolRepository: RecipeProtocolRepository {
    private let recipes: [Recipe]

    init(recipes: [Recipe]) {
        self.recipes = recipes
    }

    func getAll() -> [Recipe] {
        recipes
    }

    func getByID(_ id: UUID) -> Recipe? {
        nil
    }
    
    func getByName(_ name: String) -> Recipe? {
        nil
    }
    
    func getByMealType(_ mealType: MealType) -> [Recipe] {
        []
    }
    
    func getFavorites() -> [Recipe] {
        []
    }
    
    func save(_ recipe: Recipe) throws {
        
    }
    
    func delete(_ recipe: Recipe) throws {
        
    }

    func update(_ recipe: Recipe) throws {
        
    }
}
