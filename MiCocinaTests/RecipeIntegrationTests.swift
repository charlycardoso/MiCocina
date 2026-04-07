//
//  RecipeIntegrationTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 20/03/26.
//

import Testing
@testable import MiCocina

@MainActor
struct RecipeIntegrationTests {

    @Test
    func full_pipeline_matcher_mapper_grouper_produces_correct_output() {
        // Given - Complete scenario with multiple recipes and ingredients
        let agua = Ingredient(name: "agua")
        let limon = Ingredient(name: "limon")
        let fresas = Ingredient(name: "fresas")
        let azucar = Ingredient(name: "azucar")
        let otros = Ingredient(name: "otros")

        let recipes: [Recipe] = [
            Recipe(
                name: "agua de limón",
                ingredients: [
                    .init(ingredient: limon),
                    .init(ingredient: agua),
                    .init(ingredient: azucar, isRequired: false)
                ],
                mealType: .lunch,
                isFavorite: true
            ),
            Recipe(
                name: "carlotta de limón",
                ingredients: [
                    .init(ingredient: limon),
                    .init(ingredient: otros)
                ],
                mealType: .lunch,
                isFavorite: false
            ),
            Recipe(
                name: "agua de fresa",
                ingredients: [
                    .init(ingredient: fresas),
                    .init(ingredient: agua),
                    .init(ingredient: azucar, isRequired: false)
                ],
                mealType: .breakFast,
                isFavorite: false
            )
        ]

        let pantry: Set<Ingredient> = [agua, limon, fresas]

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeProtocolRepository(recipes: recipes),
            PantryProtocolRepository: MockPantryProtocolRepository(pantry: pantry),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then - Verify complete pipeline
        #expect(groups.count == 2)

        // Breakfast group
        let breakfastGroup = groups.first { $0.mealType == .breakFast }
        #expect(breakfastGroup != nil)
        #expect(breakfastGroup?.recipes.count == 1)
        #expect(breakfastGroup?.recipes[0].name == "agua de fresa")
        #expect(breakfastGroup?.recipes[0].canCook == true)
        #expect(breakfastGroup?.recipes[0].missingCount == 1)

        // Lunch group
        let lunchGroup = groups.first { $0.mealType == .lunch }
        #expect(lunchGroup != nil)
        #expect(lunchGroup?.recipes.count == 2)

        // In lunch group, favorite should come first, and cookable before not cookable
        #expect(lunchGroup?.recipes[0].name == "agua de limón")
        #expect(lunchGroup?.recipes[0].isFavorite == true)
        #expect(lunchGroup?.recipes[0].canCook == true)

        #expect(lunchGroup?.recipes[1].name == "carlotta de limón")
        #expect(lunchGroup?.recipes[1].isFavorite == false)
        #expect(lunchGroup?.recipes[1].canCook == true)
        #expect(lunchGroup?.recipes[1].missingCount == 1)
    }

    @Test
    func missing_count_and_canCook_propagate_correctly_through_pipeline() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let tomato = Ingredient(name: "Tomate")
        let garlic = Ingredient(name: "Ajo")
        let basil = Ingredient(name: "Basil")

        let recipe = Recipe(
            name: "Pasta",
            ingredients: [
                .init(ingredient: pasta),
                .init(ingredient: tomato),
                .init(ingredient: garlic),
                .init(ingredient: basil)
            ],
            mealType: .lunch
        )

        let pantry: Set<Ingredient> = [pasta, tomato]

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeProtocolRepository(recipes: [recipe]),
            PantryProtocolRepository: MockPantryProtocolRepository(pantry: pantry),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then - Verify missing count and canCook are correct
        let recipeData = groups[0].recipes[0]
        #expect(recipeData.missingCount == 2)
        #expect(recipeData.canCook == true) // 2 missing <= 3
    }

    @Test
    func getPossibleRecipes_filters_correctly_through_matcher_mapper_grouper_pipeline() {
        // Given
        let water = Ingredient(name: "water")
        let sugar = Ingredient(name: "sugar")
        let salt = Ingredient(name: "salt")
        let oil = Ingredient(name: "oil")
        let vinegar = Ingredient(name: "vinegar")

        // Recipe 1: 0 missing (should be in possible)
        let recipe1 = Recipe(
            name: "Simple Water",
            ingredients: [.init(ingredient: water)],
            mealType: .lunch,
            isFavorite: false
        )

        // Recipe 2: 2 missing (should be in possible)
        let recipe2 = Recipe(
            name: "Salad",
            ingredients: [
                .init(ingredient: water),
                .init(ingredient: salt),
                .init(ingredient: oil),
                .init(ingredient: sugar)
            ],
            mealType: .lunch,
            isFavorite: false
        )

        // Recipe 3: 4 missing (should NOT be in possible)
        let recipe3 = Recipe(
            name: "Complex Dish",
            ingredients: [
                .init(ingredient: water),
                .init(ingredient: salt),
                .init(ingredient: oil),
                .init(ingredient: sugar),
                .init(ingredient: vinegar),
                .init(ingredient: Ingredient(name: "missing"))
            ],
            mealType: .dinner,
            isFavorite: false
        )

        let pantry: Set<Ingredient> = [water, salt]

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeProtocolRepository(recipes: [recipe1, recipe2, recipe3]),
            PantryProtocolRepository: MockPantryProtocolRepository(pantry: pantry),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getPossibleRecipes()

        // Then
        let allRecipes = groups.flatMap { $0.recipes }
        #expect(allRecipes.count == 2)
        #expect(allRecipes.contains { $0.name == "Simple Water" })
        #expect(allRecipes.contains { $0.name == "Salad" })
        #expect(!allRecipes.contains { $0.name == "Complex Dish" })
    }

    @Test
    func pipeline_preserves_recipe_ids_through_mapping() {
        // Given
        let water = Ingredient(name: "water")
        let recipe = Recipe(
            name: "Water",
            ingredients: [.init(ingredient: water)],
            mealType: .lunch
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeProtocolRepository(recipes: [recipe]),
            PantryProtocolRepository: MockPantryProtocolRepository(pantry: [water]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then
        #expect(groups[0].recipes[0].id == recipe.id)
    }

    @Test
    func pipeline_handles_multiple_meal_types_with_correct_grouping_and_sorting() {
        // Given
        let water = Ingredient(name: "water")

        let recipes: [Recipe] = [
            Recipe(
                name: "Other Dish",
                ingredients: [.init(ingredient: water)],
                mealType: .other,
                isFavorite: false
            ),
            Recipe(
                name: "Dinner",
                ingredients: [.init(ingredient: water)],
                mealType: .dinner,
                isFavorite: true
            ),
            Recipe(
                name: "Breakfast",
                ingredients: [.init(ingredient: water)],
                mealType: .breakFast,
                isFavorite: false
            ),
            Recipe(
                name: "Lunch",
                ingredients: [.init(ingredient: water)],
                mealType: .lunch,
                isFavorite: false
            ),
        ]

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeProtocolRepository(recipes: recipes),
            PantryProtocolRepository: MockPantryProtocolRepository(pantry: [water]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then - Groups should be sorted by meal type raw value
        let mealTypes = groups.map { $0.mealType }
        #expect(mealTypes == [.breakFast, .dinner, .lunch, .other])
    }

    @Test
    func pipeline_with_no_pantry_items_computes_missing_count_correctly() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let tomato = Ingredient(name: "Tomate")
        let garlic = Ingredient(name: "Ajo")

        let recipe = Recipe(
            name: "Pasta",
            ingredients: [
                .init(ingredient: pasta),
                .init(ingredient: tomato),
                .init(ingredient: garlic)
            ],
            mealType: .lunch
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeProtocolRepository(recipes: [recipe]),
            PantryProtocolRepository: MockPantryProtocolRepository(pantry: []),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then
        #expect(groups[0].recipes[0].missingCount == 3)
        #expect(groups[0].recipes[0].canCook == true) // 3 missing <= 3 (allowed limit)
    }

    @Test
    func pipeline_complex_scenario_with_favorites_and_cookability() {
        // Given
        let water = Ingredient(name: "water")

        let recipes: [Recipe] = [
            Recipe(
                name: "Z Non-Cookable Non-Favorite",
                ingredients: [
                    .init(ingredient: water),
                    .init(ingredient: Ingredient(name: "missing1")),
                    .init(ingredient: Ingredient(name: "missing2")),
                    .init(ingredient: Ingredient(name: "missing3")),
                    .init(ingredient: Ingredient(name: "missing4"))
                ],
                mealType: .lunch,
                isFavorite: false
            ),
            Recipe(
                name: "Favorite Cookable",
                ingredients: [.init(ingredient: water)],
                mealType: .lunch,
                isFavorite: true
            ),
            Recipe(
                name: "A Non-Cookable Favorite",
                ingredients: [
                    .init(ingredient: water),
                    .init(ingredient: Ingredient(name: "missing1")),
                    .init(ingredient: Ingredient(name: "missing2"))
                ],
                mealType: .lunch,
                isFavorite: true
            ),
            Recipe(
                name: "Non-Favorite Cookable",
                ingredients: [.init(ingredient: water)],
                mealType: .lunch,
                isFavorite: false
            ),
        ]

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeProtocolRepository(recipes: recipes),
            PantryProtocolRepository: MockPantryProtocolRepository(pantry: [water]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then - Verify the complete sort order
        let sortedRecipes = groups[0].recipes
        let expectedOrder = [
            "Favorite Cookable",
            "A Non-Cookable Favorite",
            "Non-Favorite Cookable",
            "Z Non-Cookable Non-Favorite"
        ]
        let actualOrder = sortedRecipes.map { $0.name }
        #expect(actualOrder == expectedOrder)
    }
}
