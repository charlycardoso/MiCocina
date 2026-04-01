//
//  RecipeUseCasesTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 19/03/26.
//

import Testing
@testable import MiCocina

@MainActor
struct RecipeUseCasesTests {

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
    
    @Test
    func returns_empty_array_when_no_recipes() {
        // given
        let sut: RecipeUseCases = makeSUT(recipes: [])
        
        // when
        let recipeGroups = sut.getAllRecipes()
        
        // then
        #expect(recipeGroups.isEmpty)
    }
    
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
    struct FakeRecipeRepository: RecipeRepository {
        private let recipes: [Recipe]

        init(recipes: [Recipe]) {
            self.recipes = recipes
        }

        func getAll() -> [Recipe] {
            recipes
        }
    }
    
    struct FakePantryRepository: PantryRepository {
        private let pantry: Set<Ingredient>

        init(pantry: Set<Ingredient>) {
            self.pantry = pantry
        }

        func getPantry() -> Set<Ingredient> {
            pantry
        }
    }
    
    func makeSUT(
        recipes: [Recipe] = [],
        pantry: Set<Ingredient> = []
    ) -> RecipeUseCases {
        RecipeUseCasesImpl(
            recipeRepository: FakeRecipeRepository(recipes: recipes),
            pantryRepository: FakePantryRepository(pantry: pantry),
            matcher: RecipeMatcher()
        )
    }
}
