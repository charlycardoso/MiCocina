//
//  RecipeIntegrationTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 20/03/26.
//

import Testing
import SwiftData
@testable import MiCocina

/// Integration test suite validating the entire recipe pipeline.
///
/// `RecipeIntegrationTests` validates the complete flow from matching recipes,
/// through mapping to view data, and finally grouping by meal type. These tests
/// ensure all components work together correctly in real-world scenarios.
@MainActor
struct RecipeIntegrationTests {
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        // 1. Setup in-memory configuration
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([
            SDPantryItem.self,
            SDShoppingListItem.self,
            SDPlannerData.self,
            SDRecipe.self,
            SDIngredient.self,
            SDRecipeIngredient.self,
        ])
        
        // 2. Create the container with your @Model types
        container = try ModelContainer(for: schema, configurations: config)
        
        // 3. Get the main context
        context = container.mainContext
    }

    /// Tests the complete pipeline from recipe matching to final grouped output.
    ///
    /// Verifies that the matcher, mapper, and grouper components work together
    /// to produce correctly organized and sorted recipe groups.
    @Test
    func full_pipeline_matcher_mapper_grouper_produces_correct_output() {
        // Given - Complete scenario with multiple recipes and ingredients
        let agua = Ingredient(name: "agua")
        let limon = Ingredient(name: "limon")
        let fresas = Ingredient(name: "fresas")

        let recipes: [Recipe] = [
            Recipe(
                name: "agua de limón",
                ingredients: [
                    .init(ingredientName: "limon"),
                    .init(ingredientName: "agua"),
                    .init(ingredientName: "azucar", isRequired: false)
                ],
                mealType: .lunch,
                isFavorite: true
            ),
            Recipe(
                name: "carlotta de limón",
                ingredients: [
                    .init(ingredientName: "limon"),
                    .init(ingredientName: "otros")
                ],
                mealType: .lunch,
                isFavorite: false
            ),
            Recipe(
                name: "agua de fresa",
                ingredients: [
                    .init(ingredientName: "fresas"),
                    .init(ingredientName: "agua"),
                    .init(ingredientName: "azucar", isRequired: false)
                ],
                mealType: .breakFast,
                isFavorite: false
            )
        ]

        let pantry: Set<Ingredient> = [agua, limon, fresas]

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: recipes),
            PantryProtocolRepository: MockPantryRepository(pantry: pantry),
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
        let pasta = Ingredient(name: "Pasta", quantity: 1)
        let tomato = Ingredient(name: "Tomate", quantity: 1)  // Not in pantry

        let recipe = Recipe(
            name: "Pasta",
            ingredients: [
                .init(ingredientName: "Pasta"),
                .init(ingredientName: "Tomate"),
                .init(ingredientName: "Ajo"),
                .init(ingredientName: "Basil")
            ],
            mealType: .lunch
        )

        let pantry: Set<Ingredient> = [pasta, tomato]

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [recipe]),
            PantryProtocolRepository: MockPantryRepository(pantry: pantry),
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
        let water = Ingredient(name: "water", quantity: 1)
        let sugar = Ingredient(name: "sugar", quantity: 0)
        let salt = Ingredient(name: "salt", quantity: 1)
        let oil = Ingredient(name: "oil", quantity: 0)
        let vinegar = Ingredient(name: "vinegar", quantity: 0)

        // Recipe 1: 0 missing (should be in possible)
        let recipe1 = Recipe(
            name: "Simple Water",
            ingredients: [.init(ingredientName: "water")],
            mealType: .lunch,
            isFavorite: false
        )

        // Recipe 2: 2 missing (should be in possible)
        let recipe2 = Recipe(
            name: "Salad",
            ingredients: [
                .init(ingredientName: "water"),
                .init(ingredientName: "salt"),
                .init(ingredientName: "oil"),
                .init(ingredientName: "sugar")
            ],
            mealType: .lunch,
            isFavorite: false
        )

        // Recipe 3: 4 missing (should NOT be in possible)
        let recipe3 = Recipe(
            name: "Complex Dish",
            ingredients: [
                .init(ingredientName: "water"),
                .init(ingredientName: "salt"),
                .init(ingredientName: "oil"),
                .init(ingredientName: "sugar"),
                .init(ingredientName: "vinegar"),
                .init(ingredientName: "missing")
            ],
            mealType: .dinner,
            isFavorite: false
        )

        let pantry: Set<Ingredient> = [water, salt]

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [recipe1, recipe2, recipe3]),
            PantryProtocolRepository: MockPantryRepository(pantry: pantry),
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
        let water = Ingredient(name: "water", quantity: 1)
        let recipe = Recipe(
            name: "Water",
            ingredients: [.init(ingredientName: "water")],
            mealType: .lunch
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [recipe]),
            PantryProtocolRepository: MockPantryRepository(pantry: [water]),
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
        let water = Ingredient(name: "water", quantity: 1)

        let recipes: [Recipe] = [
            Recipe(
                name: "Other Dish",
                ingredients: [.init(ingredientName: "water")],
                mealType: .other,
                isFavorite: false
            ),
            Recipe(
                name: "Dinner",
                ingredients: [.init(ingredientName: "water")],
                mealType: .dinner,
                isFavorite: true
            ),
            Recipe(
                name: "Breakfast",
                ingredients: [.init(ingredientName: "water")],
                mealType: .breakFast,
                isFavorite: false
            ),
            Recipe(
                name: "Lunch",
                ingredients: [.init(ingredientName: "water")],
                mealType: .lunch,
                isFavorite: false
            ),
        ]

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: recipes),
            PantryProtocolRepository: MockPantryRepository(pantry: [water]),
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
        let recipe = Recipe(
            name: "Pasta",
            ingredients: [
                .init(ingredientName: "Pasta"),
                .init(ingredientName: "Tomate"),
                .init(ingredientName: "Ajo")
            ],
            mealType: .lunch
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [recipe]),
            PantryProtocolRepository: MockPantryRepository(pantry: []),
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
        let water = Ingredient(name: "water", quantity: 1)

        let recipes: [Recipe] = [
            Recipe(
                name: "Z Non-Cookable Non-Favorite",
                ingredients: [
                    .init(ingredientName: "water"),
                    .init(ingredientName: "missing1"),
                    .init(ingredientName: "missing2"),
                    .init(ingredientName: "missing3"),
                    .init(ingredientName: "missing4")
                ],
                mealType: .lunch,
                isFavorite: false
            ),
            Recipe(
                name: "Favorite Cookable",
                ingredients: [.init(ingredientName: "water")],
                mealType: .lunch,
                isFavorite: true
            ),
            Recipe(
                name: "A Non-Cookable Favorite",
                ingredients: [
                    .init(ingredientName: "water"),
                    .init(ingredientName: "missing1"),
                    .init(ingredientName: "missing2")
                ],
                mealType: .lunch,
                isFavorite: true
            ),
            Recipe(
                name: "Non-Favorite Cookable",
                ingredients: [.init(ingredientName: "water")],
                mealType: .lunch,
                isFavorite: false
            ),
        ]

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: recipes),
            PantryProtocolRepository: MockPantryRepository(pantry: [water]),
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

    @Test
    func any_ingredient_is_saved_when_adding_a_new_recipe() throws {
        // Given
        let ingredients: Set<RecipeIngredient> = [
            .init(ingredientName: "Agua"),
            .init(ingredientName: "Limones"),
            .init(ingredientName: "Azucar")
        ]
        let newRecipe = Recipe(name: "Agua de limón", ingredients: ingredients)
        
        let pantryRepository = SDPantryProtocolRepository(context: context)
        let recipeRepository = SDRecipeProtocolRepository(context: context)
        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: recipeRepository,
            PantryProtocolRepository: pantryRepository,
            matcher: .init()
        )

        // When
        try recipeRepository.save(newRecipe)

        // Then
        /// Verify that any ingredient was added to my pantry
        let pantry = pantryRepository.getPantry()
        #expect(sut.getAllRecipes().count == 1)
        #expect(pantry.isEmpty == true, "The pantry should be empty, but has: \(pantry.count) ingredients.")
    }
}
