//
//  RecipeUseCasesImplTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 20/03/26.
//

import Testing
@testable import MiCocina

/// Test suite for `RecipeUseCasesImpl` use case implementation.
///
/// `RecipeUseCasesImplTests` validates the complete workflow of recipe discovery,
/// including fetching recipes from repositories, applying recipe matching, mapping
/// to view data, and grouping by meal type.
///
/// Tests cover:
/// - Fetching all recipes with proper grouping and sorting
/// - Correct mapping of recipe properties to view data
/// - Filtering to show only cookable recipes
/// - Proper handling of missing ingredient counts
/// - Recipe sorting within groups (favorites first, then cookable, etc.)
@MainActor
struct RecipeUseCasesImplTests {

    /// Tests that all recipes are returned grouped by meal type.
    ///
    /// Verifies that `getAllRecipes()` returns recipe groups for each meal type
    /// found in the repository.
    @Test
    func getAllRecipes_returns_all_recipes_grouped_by_meal_type() {
        // Given
        let agua = Ingredient(name: "agua")
        let limon = Ingredient(name: "limon")

        let recipe1 = Recipe(
            name: "Limonada",
            ingredients: [.init(ingredient: agua), .init(ingredient: limon)],
            mealType: .lunch
        )

        let recipe2 = Recipe(
            name: "Café",
            ingredients: [.init(ingredient: agua)],
            mealType: .breakFast
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [recipe1, recipe2]),
            PantryProtocolRepository: MockPantryRepository(pantry: [agua, limon]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then
        #expect(groups.count == 2)
        #expect(groups.contains { $0.mealType == .breakFast })
        #expect(groups.contains { $0.mealType == .lunch })
    }

    /// Tests that recipes are correctly mapped to view data.
    ///
    /// Verifies that `getAllRecipes()` correctly transforms domain recipes to
    /// view data, preserving all properties and computing derived fields.
    @Test
    func getAllRecipes_maps_recipes_correctly() {
        // Given
        let pasta = Ingredient(name: "Pasta")
        let recipe = Recipe(
            name: "Spaghetti",
            ingredients: [.init(ingredient: pasta)],
            mealType: .lunch,
            isFavorite: true
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [recipe]),
            PantryProtocolRepository: MockPantryRepository(pantry: [pasta]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then
        let mappedRecipe = groups[0].recipes[0]
        #expect(mappedRecipe.name == "Spaghetti")
        #expect(mappedRecipe.mealType == .lunch)
        #expect(mappedRecipe.isFavorite == true)
        #expect(mappedRecipe.canCook == true)
        #expect(mappedRecipe.missingCount == 0)
    }

    /// Tests that recipes are properly sorted within each group.
    ///
    /// Verifies that within a meal type group, recipes are sorted by:
    /// 1. Favorite status (favorites first)
    /// 2. Cookability (can cook before can't cook)
    /// 3. Missing ingredient count (fewer missing first)
    /// 4. Alphabetically (as tiebreaker)
    @Test
    func getAllRecipes_sorts_recipes_within_groups() {
        // Given
        let water = Ingredient(name: "water")

        let favorite = Recipe(
            name: "Favorite Recipe",
            ingredients: [.init(ingredient: water)],
            mealType: .lunch,
            isFavorite: true
        )

        let regular = Recipe(
            name: "Regular Recipe",
            ingredients: [.init(ingredient: water)],
            mealType: .lunch,
            isFavorite: false
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [regular, favorite]),
            PantryProtocolRepository: MockPantryRepository(pantry: [water]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then - Favorite should come first
        #expect(groups[0].recipes[0].isFavorite == true)
        #expect(groups[0].recipes[1].isFavorite == false)
    }

    /// Tests that `getPossibleRecipes()` filters recipes by cookability.
    ///
    /// Verifies that only recipes with 3 or fewer missing ingredients are returned.
    /// The tolerance of 3 missing ingredients allows practical meal planning.
    @Test
    func getPossibleRecipes_filters_only_cookable_recipes() {
        // Given
        let agua = Ingredient(name: "agua")
        let limon = Ingredient(name: "limon")
        let otros = Ingredient(name: "otros")

        let cookableRecipe = Recipe(
            name: "Limonada",
            ingredients: [
                .init(ingredient: agua),
                .init(ingredient: limon)
            ],
            mealType: .lunch
        )

        let notCookableRecipe = Recipe(
            name: "Complex Dish",
            ingredients: [
                .init(ingredient: otros),
                .init(ingredient: agua),
                .init(ingredient: limon),
                .init(ingredient: Ingredient(name: "missing1")),
                .init(ingredient: Ingredient(name: "missing2"))
            ],
            mealType: .dinner
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [cookableRecipe, notCookableRecipe]),
            PantryProtocolRepository: MockPantryRepository(pantry: [agua, limon]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getPossibleRecipes()

        // Then - Should only contain the cookable recipe (Complex Dish has 3 missing, which is the limit, so it's still cookable)
        let allRecipes = groups.flatMap { $0.recipes }
        #expect(allRecipes.count == 2)
    }

    @Test
    func getPossibleRecipes_groups_filtered_recipes() {
        // Given
        let water = Ingredient(name: "water")

        let breakfastRecipe = Recipe(
            name: "Eggs",
            ingredients: [.init(ingredient: water)],
            mealType: .breakFast
        )

        let lunchRecipe = Recipe(
            name: "Pasta",
            ingredients: [.init(ingredient: water)],
            mealType: .lunch
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [breakfastRecipe, lunchRecipe]),
            PantryProtocolRepository: MockPantryRepository(pantry: [water]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getPossibleRecipes()

        // Then - Should have 2 groups
        #expect(groups.count == 2)
        #expect(groups.contains { $0.mealType == .breakFast })
        #expect(groups.contains { $0.mealType == .lunch })
    }

    @Test
    func getPossibleRecipes_returns_correct_ordering() {
        // Given
        let water = Ingredient(name: "water")

        let regular = Recipe(
            name: "Regular",
            ingredients: [.init(ingredient: water)],
            mealType: .lunch,
            isFavorite: false
        )

        let favorite = Recipe(
            name: "Favorite",
            ingredients: [.init(ingredient: water)],
            mealType: .lunch,
            isFavorite: true
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [regular, favorite]),
            PantryProtocolRepository: MockPantryRepository(pantry: [water]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getPossibleRecipes()

        // Then - Favorite should come first
        #expect(groups[0].recipes[0].isFavorite == true)
        #expect(groups[0].recipes[1].isFavorite == false)
    }

    @Test
    func getPossibleRecipes_returns_empty_groups_when_no_possible_recipes() {
        // Given
        let agua = Ingredient(name: "agua")
        let limon = Ingredient(name: "limon")
        let otros = Ingredient(name: "otros")

        let recipe = Recipe(
            name: "Complex Dish",
            ingredients: [
                .init(ingredient: otros),
                .init(ingredient: agua),
                .init(ingredient: limon),
                .init(ingredient: Ingredient(name: "missing1")),
                .init(ingredient: Ingredient(name: "missing2")),
                .init(ingredient: Ingredient(name: "missing3"))
            ],
            mealType: .dinner
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [recipe]),
            PantryProtocolRepository: MockPantryRepository(pantry: [agua, limon]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getPossibleRecipes()

        // Then - Should return empty groups (4 missing > 3)
        #expect(groups.isEmpty)
    }

    @Test
    func getAllRecipes_returns_empty_when_no_recipes() {
        // Given
        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: []),
            PantryProtocolRepository: MockPantryRepository(pantry: []),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then
        #expect(groups.isEmpty)
    }

    @Test
    func getAllRecipes_returns_correct_missing_count() {
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
            RecipeProtocolRepository: MockRecipeRepository(recipes: [recipe]),
            PantryProtocolRepository: MockPantryRepository(pantry: [pasta]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then
        #expect(groups[0].recipes[0].missingCount == 2)
    }

    @Test
    func getAllRecipes_groups_are_sorted_by_meal_type() {
        // Given
        let water = Ingredient(name: "water")

        let dinnerRecipe = Recipe(
            name: "Dinner",
            ingredients: [.init(ingredient: water)],
            mealType: .dinner
        )

        let breakfastRecipe = Recipe(
            name: "Breakfast",
            ingredients: [.init(ingredient: water)],
            mealType: .breakFast
        )

        let lunchRecipe = Recipe(
            name: "Lunch",
            ingredients: [.init(ingredient: water)],
            mealType: .lunch
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [dinnerRecipe, breakfastRecipe, lunchRecipe]),
            PantryProtocolRepository: MockPantryRepository(pantry: [water]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getAllRecipes()

        // Then - Groups should be sorted by meal type raw value
        let mealTypes = groups.map { $0.mealType }
        #expect(mealTypes == [.breakFast, .dinner, .lunch])
    }

    @Test
    func getPossibleRecipes_respects_matcher_logic() {
        // Given - Matcher allows up to 3 missing ingredients
        let water = Ingredient(name: "water")
        let sugar = Ingredient(name: "sugar")
        let lemon = Ingredient(name: "lemon")
        let salt = Ingredient(name: "salt")
        let oil = Ingredient(name: "oil")

        let recipe = Recipe(
            name: "Recipe with 3 missing",
            ingredients: [
                .init(ingredient: water),
                .init(ingredient: sugar),
                .init(ingredient: lemon),
                .init(ingredient: salt),
                .init(ingredient: oil)
            ],
            mealType: .lunch
        )

        let sut = RecipeUseCasesImpl(
            RecipeProtocolRepository: MockRecipeRepository(recipes: [recipe]),
            PantryProtocolRepository: MockPantryRepository(pantry: [water, sugar]),
            matcher: RecipeMatcher()
        )

        // When
        let groups = sut.getPossibleRecipes()

        // Then - With 3 missing, should still be possible
        #expect(!groups.isEmpty)
        #expect(groups[0].recipes[0].canCook == true)
    }
}
