//
//  RecipeUseCasesTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 19/03/26.
//

import Testing
import Foundation
@testable import MiCocina

/// Test suite for `RecipeUseCases` protocol behavior.
///
/// `RecipeUseCasesTests` validates the core functionality of the recipe use case interface
/// using fake repository implementations. Tests focus on high-level behavior such as
/// grouping, filtering, and data mapping.
///
/// This test suite uses local fake implementations of the repositories to isolate
/// testing of the use case logic from specific repository implementations.
@MainActor
struct RecipeUseCasesTests {

    /// Tests that recipes are grouped by meal type.
    ///
    /// Verifies that `getAllRecipes()` correctly organizes recipes into groups
    /// based on their meal type classification.
    @Test
    func groups_recipes_by_meal_type() {
        // ingredients
        let agua = Ingredient(name: "agua")
        let limon = Ingredient(name: "limon")

        // sample recipes
        let r1 = Recipe(
            name: "Limonada",
            ingredients: [.init(ingredient: agua), .init(ingredient: limon)], mealType: .lunch
        )

        let r2 = Recipe(
            name: "Café",
            ingredients: [.init(ingredient: agua)], mealType: .breakFast
        )

        let sut = makeSUT(
            recipes: [r1, r2],
            pantry: [agua, limon]
        )

        let groups = sut.getAllRecipes()

        // assertions
        #expect(groups.count == 2)
        #expect(groups.first(where: { $0.mealType == .breakFast })?.recipes.map(\.name) == ["Café"])
        #expect(groups.first(where: { $0.mealType == .lunch })?.recipes.map(\.name) == ["Limonada"])
    }
    
    /// Tests that an empty array is returned when no recipes exist.
    ///
    /// Verifies proper handling of the empty state.
    @Test
    func returns_empty_array_when_no_recipes() {
        // given
        let sut: RecipeUseCases = makeSUT(recipes: [])
        
        // when
        let recipeGroups = sut.getAllRecipes()
        
        // then
        #expect(recipeGroups.isEmpty)
    }
    
    /// Tests that missing ingredient counts are computed correctly.
    ///
    /// Verifies that the `missingCount` property correctly reflects the number
    /// of ingredients not available in the pantry.
    @Test
    func all_recipes_have_correct_missing_count() {
        // given
        let pasta = Recipe(name: "Pasta", ingredients: [
            RecipeIngredient(ingredient: .init(name: "Pasta")),
            RecipeIngredient(ingredient: .init(name: "Tomate")),
            RecipeIngredient(ingredient: .init(name: "Ajo"))
        ], mealType: .lunch)
        
        let sut: RecipeUseCases = makeSUT(recipes: [pasta])
        
        // when
        let recipeGroups = sut.getAllRecipes()
        
        // then
        #expect(recipeGroups.count == 1)
        #expect(recipeGroups.first?.recipes.first?.missingCount == 3)
    }
}

extension RecipeUseCasesTests {
    /// A fake recipe repository for testing purposes.
    ///
    /// Provides a minimal in-memory implementation of `RecipeProtocolRepository`
    /// that stores recipes and returns them without any persistence layer.
    struct FakeRecipeProtocolRepository: RecipeProtocolRepository {
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
    
    /// A fake pantry repository for testing purposes.
    ///
    /// Provides a minimal in-memory implementation of `PantryProtocolRepository`
    /// that stores ingredients in a set without any persistence layer.
    struct FakePantryProtocolRepository: PantryProtocolRepository {
        private let pantry: Set<Ingredient>

        init(pantry: Set<Ingredient>) {
            self.pantry = pantry
        }

        func getPantry() -> Set<Ingredient> {
            pantry
        }

        func add(_ ingredient: Ingredient) throws {
        }

        func remove(_ ingredient: Ingredient) throws {
        }

        func update(_ ingredient: Ingredient) throws {
        }

        func clear() throws {
        }

        func exists(_ ingredient: Ingredient) -> Bool {
            false
        }
    }
    
    /// Creates a subject under test (SUT) with configurable fake repositories.
    ///
    /// This helper method simplifies test setup by providing a pre-configured
    /// `RecipeUseCasesImpl` with fake repositories.
    ///
    /// - Parameters:
    ///   - recipes: The recipes to populate in the fake recipe repository
    ///   - pantry: The ingredients to populate in the fake pantry repository
    /// - Returns: A configured `RecipeUseCases` instance ready for testing
    func makeSUT(
        recipes: [Recipe] = [],
        pantry: Set<Ingredient> = []
    ) -> RecipeUseCases {
        RecipeUseCasesImpl(
            RecipeProtocolRepository: FakeRecipeProtocolRepository(recipes: recipes),
            PantryProtocolRepository: FakePantryProtocolRepository(pantry: pantry),
            matcher: RecipeMatcher()
        )
    }
}
