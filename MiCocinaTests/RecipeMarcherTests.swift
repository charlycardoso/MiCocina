//
//  RecipeMarcherTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Testing
@testable import MiCocina

@MainActor
struct RecipeMarcherTests {

    @Test
    func recipe_is_possible_when_all_ingredients_exists() {
        let eggs = Ingredient(name: "eggs")
        let tortilla = Recipe(name: "Tortilla", ingredients: [eggs])
        let matcher = RecipeMatcher()
        let result = matcher.canCook(recipe: tortilla, with: [eggs])

        #expect(result == true)
    }

}
