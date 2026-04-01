//
//  RecipeRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

protocol RecipeRepository {
    func getAll() -> [Recipe]
}

final class MockRecipeRepository: RecipeRepository {
    private let recipes: [Recipe]

    init(recipes: [Recipe]) {
        self.recipes = recipes
    }

    func getAll() -> [Recipe] {
        recipes
    }
}
