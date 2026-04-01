//
//  RecipeMapperTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 20/03/26.
//

import Testing
@testable import MiCocina

@MainActor
struct RecipeMapperTests {

    @Test
    func mapper_computes_correct_missing_count() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let tomato = Ingredient(name: "Tomate")
        let garlic = Ingredient(name: "Ajo")
        let olive = Ingredient(name: "Oliva")

        let recipe = Recipe(
            name: "Pasta",
            ingredients: [
                RecipeIngredient(ingredient: pasta),
                RecipeIngredient(ingredient: tomato),
                RecipeIngredient(ingredient: garlic),
                RecipeIngredient(ingredient: olive)
            ]
        )

        let pantry: Set<Ingredient> = [pasta, tomato]
        let matcher = RecipeMatcher()
        let mapper = RecipeMapper()

        // When
        let result = mapper.map(recipe, pantry: pantry, matcher: matcher)

        // Then
        #expect(result.missingCount == 2)
    }

    @Test
    func mapper_counts_missing_ingredients_regardless_of_required_status() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let tomato = Ingredient(name: "Tomate")
        let garlic = Ingredient(name: "Ajo")
        let salt = Ingredient(name: "Sal")

        let recipe = Recipe(
            name: "Pasta",
            ingredients: [
                RecipeIngredient(ingredient: pasta),
                RecipeIngredient(ingredient: tomato),
                RecipeIngredient(ingredient: garlic, isRequired: false),
                RecipeIngredient(ingredient: salt, isRequired: false)
            ]
        )

        let pantry: Set<Ingredient> = [pasta, tomato]
        let matcher = RecipeMatcher()
        let mapper = RecipeMapper()

        // When
        let result = mapper.map(recipe, pantry: pantry, matcher: matcher)

        // Then - Both required and optional missing ingredients are counted
        #expect(result.missingCount == 2)
    }

    @Test
    func mapper_sets_canCook_based_on_matcher() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let tomato = Ingredient(name: "Tomate")
        let garlic = Ingredient(name: "Ajo")

        let recipe = Recipe(
            name: "Pasta",
            ingredients: [
                RecipeIngredient(ingredient: pasta),
                RecipeIngredient(ingredient: tomato),
                RecipeIngredient(ingredient: garlic)
            ]
        )

        let pantry: Set<Ingredient> = [pasta, tomato, garlic]
        let matcher = RecipeMatcher()
        let mapper = RecipeMapper()

        // When
        let result = mapper.map(recipe, pantry: pantry, matcher: matcher)

        // Then - All ingredients present, missing count <= 3, so canCook is true
        #expect(result.canCook == true)
        #expect(result.missingCount == 0)
    }

    @Test
    func mapper_sets_canCook_false_when_too_many_missing() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let tomato = Ingredient(name: "Tomate")
        let garlic = Ingredient(name: "Ajo")
        let olive = Ingredient(name: "Oliva")
        let basil = Ingredient(name: "Basil")

        let recipe = Recipe(
            name: "Pasta",
            ingredients: [
                RecipeIngredient(ingredient: pasta),
                RecipeIngredient(ingredient: tomato),
                RecipeIngredient(ingredient: garlic),
                RecipeIngredient(ingredient: olive),
                RecipeIngredient(ingredient: basil)
            ]
        )

        let pantry: Set<Ingredient> = [pasta]
        let matcher = RecipeMatcher()
        let mapper = RecipeMapper()

        // When
        let result = mapper.map(recipe, pantry: pantry, matcher: matcher)

        // Then - 4 missing ingredients > 3, so canCook is false
        #expect(result.canCook == false)
        #expect(result.missingCount == 4)
    }

    @Test
    func mapper_preserves_recipe_id() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let recipe = Recipe(
            name: "Pasta",
            ingredients: [RecipeIngredient(ingredient: pasta)]
        )

        let pantry: Set<Ingredient> = [pasta]
        let matcher = RecipeMatcher()
        let mapper = RecipeMapper()

        // When
        let result = mapper.map(recipe, pantry: pantry, matcher: matcher)

        // Then
        #expect(result.id == recipe.id)
    }

    @Test
    func mapper_preserves_recipe_name() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let recipe = Recipe(
            name: "Spaghetti Carbonara",
            ingredients: [RecipeIngredient(ingredient: pasta)]
        )

        let pantry: Set<Ingredient> = [pasta]
        let matcher = RecipeMatcher()
        let mapper = RecipeMapper()

        // When
        let result = mapper.map(recipe, pantry: pantry, matcher: matcher)

        // Then
        #expect(result.name == "Spaghetti Carbonara")
    }

    @Test
    func mapper_preserves_meal_type() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let recipe = Recipe(
            name: "Pasta",
            ingredients: [RecipeIngredient(ingredient: pasta)],
            mealType: .lunch
        )

        let pantry: Set<Ingredient> = [pasta]
        let matcher = RecipeMatcher()
        let mapper = RecipeMapper()

        // When
        let result = mapper.map(recipe, pantry: pantry, matcher: matcher)

        // Then
        #expect(result.mealType == .lunch)
    }

    @Test
    func mapper_preserves_favorite_status() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let recipe = Recipe(
            name: "Pasta",
            ingredients: [RecipeIngredient(ingredient: pasta)],
            mealType: .lunch,
            isFavorite: true
        )

        let pantry: Set<Ingredient> = [pasta]
        let matcher = RecipeMatcher()
        let mapper = RecipeMapper()

        // When
        let result = mapper.map(recipe, pantry: pantry, matcher: matcher)

        // Then
        #expect(result.isFavorite == true)
    }

    @Test
    func mapper_handles_case_insensitive_ingredient_comparison() {
        // Given - Ingredients are normalized in the Ingredient init
        let pastaLowercase = Ingredient(name: "pasta")
        let pastaUppercase = Ingredient(name: "PASTA")

        let recipe = Recipe(
            name: "Pasta",
            ingredients: [RecipeIngredient(ingredient: pastaUppercase)]
        )

        let pantry: Set<Ingredient> = [pastaLowercase]
        let matcher = RecipeMatcher()
        let mapper = RecipeMapper()

        // When
        let result = mapper.map(recipe, pantry: pantry, matcher: matcher)

        // Then - They should match due to normalization
        #expect(result.missingCount == 0)
    }

    @Test
    func mapper_handles_empty_ingredients() {
        // Given
        let recipe = Recipe(
            name: "Empty",
            ingredients: []
        )

        let pantry: Set<Ingredient> = []
        let matcher = RecipeMatcher()
        let mapper = RecipeMapper()

        // When
        let result = mapper.map(recipe, pantry: pantry, matcher: matcher)

        // Then
        #expect(result.missingCount == 0)
        #expect(result.canCook == false) // Empty recipes cannot be cooked (matcher logic)
    }
}
