//
//  RecipeMapperTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 20/03/26.
//

import Testing
@testable import MiCocina

/// Test suite for `RecipeMapper` domain model to view data conversion.
///
/// `RecipeMapperTests` validates the transformation of recipes into view-optimized
/// data objects, including computation of cookability and missing ingredient counts.
@MainActor
struct RecipeMapperTests {

    /// Tests that missing ingredient counts are computed correctly.
    ///
    /// Verifies that the mapper correctly counts ingredients not present in the pantry.
    @Test
    func mapper_computes_correct_missing_count() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let tomato = Ingredient(name: "Tomato")

        let recipe = Recipe(
            name: "Pasta Alfredo",
            ingredients: [
                RecipeIngredient(ingredientName: "pasta"),
                RecipeIngredient(ingredientName: "tomato"),
                RecipeIngredient(ingredientName: "garlic"),
                RecipeIngredient(ingredientName: "olive")
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

    /// Tests that both required and optional missing ingredients are counted.
    ///
    /// Verifies that the missing count includes both required and optional ingredients
    /// not present in the pantry.
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

    /// Tests that canCook flag is based on the recipe matcher result.
    ///
    /// Verifies that the mapper correctly delegates cookability determination to the matcher.
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
    func ingredient_normalizes_name_case_and_diacritics() {
        // Given
        let lower = Ingredient(name: "pasta")
        let upper = Ingredient(name: "PASTA")
        let accented = Ingredient(name: "Páßtã")
        let noisy = Ingredient(name: "   PÁSTA   ")

        // Then
        #expect(lower.name == upper.name)
        #expect(upper.name == noisy.name)
        #expect(accented.name != lower.name) // ß makes them differ — and that's fine
    }

    // ⚠️ DEPRECATED
//    @Test
//    func ingredient_equality_depends_on_id_not_name() {
//        // Given
//        let original = Ingredient(name: "Pasta")
//        let copyDifferentID = Ingredient(name: "PASTA")
//
//        // When
//        let isEqual = (original == copyDifferentID)
//
//        // Then
//        #expect(isEqual == false) // Because IDs differ
//        #expect(original.name == copyDifferentID.name) // But names normalize equal
//    }

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
