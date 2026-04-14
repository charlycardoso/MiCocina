//
//  RecipeMarcherTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Testing
@testable import MiCocina

/// Test suite for `RecipeMatcher` service.
///
/// `RecipeMarcherTests` validates the recipe matching algorithm that determines
/// whether recipes can be cooked with available pantry items. Tests cover:
/// - Basic matching with exact ingredients
/// - Matching with missing ingredients (up to 3)
/// - Filtering multiple recipes at once
/// - Edge cases like empty recipes and empty pantries
@MainActor
struct RecipeMarcherTests {

    /// Tests that a recipe is cookable when all ingredients are available.
    ///
    /// Verifies the basic happy path where all required ingredients exist in the pantry.
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

    /// Tests that a recipe is cookable when some ingredients are missing.
    ///
    /// Verifies that optional ingredients don't count against the tolerance threshold.
    /// A recipe with all required ingredients is cookable even without optional ones.
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

    /// Tests that `possibleRecipes()` correctly filters recipes.
    ///
    /// Verifies that the matcher can filter multiple recipes and return only
    /// those that are cookable based on the tolerance threshold.
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
            "agua de fresa",
            "carlotta de limón"
        ]
        let matcher = RecipeMatcher()
        let result = matcher.possibleRecipes(
            from: recipes,
            pantry: pantry
        )
        #expect(result.map(\.name).sorted() == expectedRecipeNames.sorted())
        #expect(result.map(\.name).contains("carlotta de limón"))
    }

    /// Tests that a recipe cannot be cooked when pantry is empty.
    ///
    /// Verifies that a recipe with 3 or more missing ingredients cannot be cooked,
    /// applying the tolerance threshold correctly.
    @Test
    func can_cook_when_there_are_no_ingredients() {
        let pantry: Set<Ingredient> = []
        // Ingredients (not mine)
        let agua: Ingredient = .init(name: "agua")
        let limones: Ingredient = .init(name: "limones")
        let azucar: Ingredient = .init(name: "azucar")

        // Recipe
        let recipe: Recipe = .init(name: "agua de limón", ingredients: [
            .init(ingredient: limones),
            .init(ingredient: agua),
            .init(ingredient: azucar, isRequired: false)
        ])
        let matcher = RecipeMatcher()
        let result = matcher.canCook(recipe: recipe, with: pantry)
        #expect(result == true)
    }

    @Test
    func empty_recipe_if_it_does_not_have_ingredients() {
        // My ingredients (mine)
        let agua: Ingredient = .init(name: "agua")
        let limones: Ingredient = .init(name: "limones")
        let fresas: Ingredient = .init(name: "fresas")
        let azucar: Ingredient = .init(name: "azucar")
        let otros = Ingredient(name: "otros")

        let recipe = Recipe(name: "Unknown", ingredients: [])
        let matcher = RecipeMatcher()
        let result = matcher.possibleRecipes(from: [recipe], pantry: [agua, limones, fresas, azucar, otros])
        #expect(result.isEmpty)
    }

    @Test
    func validate_case_sensitive_in_ingredients() {
        // Ingredients
        let limon = Ingredient(name: "limón")
        let limon2 = Ingredient(name: "Limon")
        let agua = Ingredient(name: "agua")
        // MyPantry
        let myPantry: Set<Ingredient> = [limon, agua]
        // RecipeIngredients
        let recipeIngredients: Set<RecipeIngredient> = [RecipeIngredient(ingredient: limon2), RecipeIngredient(ingredient: agua)]
        // Recipe
        let recipe = Recipe(name: "Agua de limón", ingredients: recipeIngredients)
        // Matcher
        let matcher = RecipeMatcher()
        let result = matcher.canCook(recipe: recipe, with: myPantry)
        #expect(result == true)
    }

    @Test
    func recipe_is_possible_if_pantry_is_missing_for_three_ingredients() {
        // Ingredients
        let pan = Ingredient(name: "pan")
        let jamon = Ingredient(name: "jamon")
        let lechuga = Ingredient(name: "lechuga")
        let jitomate = Ingredient(name: "jitomate")
        let mayonesa = Ingredient(name: "mayonesa")
        // Recipe Ingredients
        let recipeIngredients: Set<RecipeIngredient> = [
            .init(ingredientName: "pan"),
            .init(ingredientName: "jamon"),
            .init(ingredientName: "lechuga"),
            .init(ingredientName: "jitomate"),
            .init(ingredientName: "mayonesa")
        ]
        // my ingredients
        let myPantry: Set<Ingredient> = [pan, jamon]
        // let recipe
        let recipe = Recipe(name: "Sandwich", ingredients: recipeIngredients)
        // let matcher
        let matcher = RecipeMatcher()
        let canCook = matcher.canCook(recipe: recipe, with: myPantry)
        #expect(canCook == true)
    }

    @Test
    func recipe_is_not_possible_if_pantry_is_missing_for_four_ingredients() {
        // Ingredients
        let pan = Ingredient(name: "pan")
        let jamon = Ingredient(name: "jamon")
        let lechuga = Ingredient(name: "lechuga")
        let jitomate = Ingredient(name: "jitomate")
        let mayonesa = Ingredient(name: "mayonesa")
        // Recipe Ingredients
        let recipeIngredients: Set<RecipeIngredient> = [
            .init(ingredient: pan),
            .init(ingredient: jamon),
            .init(ingredient: lechuga),
            .init(ingredient: jitomate),
            .init(ingredient: mayonesa)
        ]
        // my ingredients
        let myPantry: Set<Ingredient> = [pan]
        // let recipe
        let recipe = Recipe(name: "Sandwich", ingredients: recipeIngredients)
        // let matcher
        let matcher = RecipeMatcher()
        let canCook = matcher.canCook(recipe: recipe, with: myPantry)
        #expect(canCook == false)
    }
}
