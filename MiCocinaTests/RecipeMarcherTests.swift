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
        // My Ingredients
        let eggs = Ingredient(name: "eggs")
        // Recipe ingredients
        let recipeEggs = RecipeIngredient(ingredient: eggs)
        // Recipe
        let tortilla = Recipe(name: "Tortilla", ingredients: [recipeEggs])
        // Matcher
        let matcher = RecipeMatcher()
        // Result
        let result = matcher.canCook(recipe: tortilla, with: [eggs])
        #expect(result == true)
    }

    @Test
    func recipe_is_not_possible_when_an_ingredient_is_missing() {
        // My ingredients
        let chocolate = Ingredient(name: "chocolate")
        let myIngredients: Set<Ingredient> = [chocolate]
        // Recipe ingredients
        let recipeChocolate = RecipeIngredient(ingredient: chocolate)
        let milk = Ingredient(name: "milk")
        let recipeMilk = RecipeIngredient(ingredient: milk)
        // Recipe
        let milkyChocolate = Recipe(name: "Milky chocolate", ingredients: [recipeChocolate, recipeChocolate, recipeMilk])
        // Matcher
        let matcher = RecipeMatcher()
        let result = matcher.canCook(recipe: milkyChocolate, with: myIngredients)
         
        #expect(result == false)
    }

    @Test
    func recipe_is_possible_when_all_ingredients_do_not_exists() {
        // My ingredients
        let strawberry = Ingredient(name: "strawberry")
        let water = Ingredient(name: "water")
        let myIngredients: Set<Ingredient> = [strawberry, water]
        // Recipe ingredients
        let recipeStrawberry = RecipeIngredient(ingredient: strawberry)
        let recipeWater = RecipeIngredient(ingredient: water)
        let sugar = Ingredient(name: "sugar")
        let recipeSugar = RecipeIngredient(ingredient: sugar, isRequired: false)
        // Recipe
        let waterOfStrawBerry = Recipe(name: "Water of Strawberry", ingredients: [recipeStrawberry, recipeWater, recipeSugar])
        // Matcher
        let matcher = RecipeMatcher()
        let result = matcher.canCook(recipe: waterOfStrawBerry, with: myIngredients)
        // Result
        #expect(result == true)
    }

    @Test
    func filters_only_possible_recipes() {
        // Ingredients
        let agua: Ingredient = .init(name: "agua")
        let limones: Ingredient = .init(name: "limones")
        let fresas: Ingredient = .init(name: "fresas")
        let azucar: Ingredient = .init(name: "azucar")
        let otros = Ingredient(name: "otros")
        
        let recipes: [Recipe] = [
            .init(name: "agua de limón", ingredients: [
                .init(ingredient: limones),
                .init(ingredient: agua),
                .init(ingredient: azucar, isRequired: false)
            ]),
            .init(name: "carlotta de limón", ingredients: [
                .init(ingredient: limones),
                .init(ingredient: otros)
            ]),
            .init(name: "agua de fresa", ingredients: [
                .init(ingredient: fresas),
                .init(ingredient: agua),
                .init(ingredient: azucar, isRequired: false)
            ])
        ]
        let pantry: Set<Ingredient> = [ agua, limones, fresas ]
        let expectedRecipeNames = [
            "agua de limón",
            "agua de fresa"
        ]
        let matcher = RecipeMatcher()
        let result = matcher.possibleRecipes(
            from: recipes,
            pantry: pantry
        )
        #expect(result.map(\.name).sorted() == expectedRecipeNames.sorted())
        #expect(!result.map(\.name).contains("carlotta de limón"))
    }
}
