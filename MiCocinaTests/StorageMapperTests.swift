//
//  StorageMapperTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 02/04/26.
//

import Testing
import SwiftData
import Foundation
@testable import MiCocina

/// Test suite for `StorageMapper` domain model to persistence model conversion.
///
/// `StorageMapperTests` validates the mapping of domain models to storage layer models.
/// Tests ensure proper persistence of data and correct handling of relationships and deduplication.
@MainActor
struct StorageMapperTests {
    
    /// Tests that domain ingredients are correctly converted to storage ingredients.
    ///
    /// Verifies that the ingredient name is preserved (normalized) during storage mapping.
    @Test
    func toStorage_ingredient_maps_correctly() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        let ingredient = Ingredient(name: "Tomato")
        
        // When
        let sdIngredient = StorageMapper.toStorage(with: ingredient, context: context)
        
        // Then
        #expect(sdIngredient.name == "tomato")
    }
    
    /// Tests that new storage ingredients are created when not yet present.
    ///
    /// Verifies proper insertion of new ingredients into the database.
    /// Tests that new storage ingredients are created when not yet present.
    ///
    /// Verifies proper insertion of new ingredients into the database.
    @Test
    func toStorage_ingredient_creates_new_when_not_exists() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        let ingredient = Ingredient(name: "Basil")
        
        // When
        let sdIngredient = StorageMapper.toStorage(with: ingredient, context: context)
        
        // Then
        #expect(sdIngredient.name == "basil")
        #expect(!sdIngredient.name.isEmpty)
    }
    
    /// Tests that existing ingredients are returned instead of creating duplicates.
    ///
    /// Verifies deduplication by ID when an ingredient already exists.
    @Test
    func toStorage_ingredient_returns_existing_when_present() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        let ingredient = Ingredient(name: "Garlic")
        
        // When
        let sdIngredient1 = StorageMapper.toStorage(with: ingredient, context: context)
        let sdIngredient2 = StorageMapper.toStorage(with: ingredient, context: context)
        
        // Then - Both should have the same name (normalized)
        #expect(sdIngredient1.name == sdIngredient2.name)
        #expect(sdIngredient1.name == "garlic")
    }
    
    /// Tests that recipe ingredients are correctly stored with just their names.
    ///
    /// Verifies that RecipeIngredient stores ingredient names directly without SDIngredient references.
    @Test
    func toStorage_recipe_stores_ingredient_names_not_references() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        
        let recipe = Recipe(
            name: "Pasta",
            ingredients: [
                RecipeIngredient(ingredientName: "Pasta", isRequired: true),
                RecipeIngredient(ingredientName: "Tomato", isRequired: false)
            ],
            mealType: .lunch,
            isFavorite: false
        )
        
        // When
        let sdRecipe = StorageMapper.toStorage(recipe: recipe, context: context)
        
        // Then
        #expect(sdRecipe.ingredients.count == 2)
        
        let pastaIngredient = sdRecipe.ingredients.first { $0.ingredientName == "pasta" }
        let tomatoIngredient = sdRecipe.ingredients.first { $0.ingredientName == "tomato" }
        
        #expect(pastaIngredient != nil)
        #expect(pastaIngredient?.isRequired == true)
        
        #expect(tomatoIngredient != nil)
        #expect(tomatoIngredient?.isRequired == false)
    }
    
    /// Tests that recipe ingredients with isRequired=false are properly stored.
    ///
    /// Verifies that optional ingredients are marked correctly in storage.
    @Test
    func toStorage_recipe_respects_optional_ingredients() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        
        let recipe = Recipe(
            name: "Pizza",
            ingredients: [
                RecipeIngredient(ingredientName: "Dough", isRequired: true),
                RecipeIngredient(ingredientName: "Oregano", isRequired: false)
            ],
            mealType: .lunch,
            isFavorite: false
        )
        
        // When
        let sdRecipe = StorageMapper.toStorage(recipe: recipe, context: context)
        
        // Then
        let oreganoIngredient = sdRecipe.ingredients.first { $0.ingredientName == "oregano" }
        #expect(oreganoIngredient != nil)
        #expect(oreganoIngredient?.isRequired == false)
    }
    
    @Test
    func toStorage_recipe_maps_correctly() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        
        let recipe = Recipe(
            name: "Pasta Carbonara",
            ingredients: [
                RecipeIngredient(ingredientName: "Pasta", isRequired: true),
                RecipeIngredient(ingredientName: "Eggs", isRequired: true)
            ],
            mealType: .lunch,
            isFavorite: true
        )
        
        // When
        let sdRecipe = StorageMapper.toStorage(recipe: recipe, context: context)
        
        // Then
        #expect(sdRecipe.name == "Pasta Carbonara")
        #expect(sdRecipe.mealType == "lunch")
        #expect(sdRecipe.isFavorite == true)
        #expect(sdRecipe.ingredients.count == 2)
    }
    
    @Test
    func toStorage_recipe_maps_all_ingredients() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        
        let recipe = Recipe(
            name: "Salad",
            ingredients: [
                RecipeIngredient(ingredientName: "Lettuce", isRequired: true),
                RecipeIngredient(ingredientName: "Tomato", isRequired: true),
                RecipeIngredient(ingredientName: "Cucumber", isRequired: true)
            ],
            mealType: .lunch,
            isFavorite: false
        )
        
        // When
        let sdRecipe = StorageMapper.toStorage(recipe: recipe, context: context)
        
        // Then
        #expect(sdRecipe.ingredients.count == 3)
    }
    
    @Test
    func toStorage_recipe_respects_mealType() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        let testCases: [(MealType, String)] = [
            (.breakFast, "breakFast"),
            (.lunch, "lunch"),
            (.dinner, "dinner"),
            (.other, "other")
        ]
        
        // When & Then
        for (mealType, expectedRawValue) in testCases {
            let recipe = Recipe(
                name: "Test",
                ingredients: [],
                mealType: mealType,
                isFavorite: false
            )
            let sdRecipe = StorageMapper.toStorage(recipe: recipe, context: context)
            #expect(sdRecipe.mealType == expectedRawValue)
        }
    }
    
    @Test
    func toStorage_recipe_respects_isFavorite_flag() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        let favoriteRecipe = Recipe(
            name: "Favorite",
            ingredients: [],
            mealType: .lunch,
            isFavorite: true
        )
        let nonFavoriteRecipe = Recipe(
            name: "Not Favorite",
            ingredients: [],
            mealType: .lunch,
            isFavorite: false
        )
        
        // When
        let sdFavorite = StorageMapper.toStorage(recipe: favoriteRecipe, context: context)
        let sdNonFavorite = StorageMapper.toStorage(recipe: nonFavoriteRecipe, context: context)
        
        // Then
        #expect(sdFavorite.isFavorite == true)
        #expect(sdNonFavorite.isFavorite == false)
    }
    
    @Test
    func toStorage_recipe_with_mixed_required_ingredients() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        
        let recipe = Recipe(
            name: "Flexible Recipe",
            ingredients: [
                RecipeIngredient(ingredientName: "Rice", isRequired: true),
                RecipeIngredient(ingredientName: "Pepper", isRequired: false)
            ],
            mealType: .dinner,
            isFavorite: false
        )
        
        // When
        let sdRecipe = StorageMapper.toStorage(recipe: recipe, context: context)
        
        // Then
        #expect(sdRecipe.ingredients.count == 2)
        let requiredCount = sdRecipe.ingredients.filter { $0.isRequired }.count
        let optionalCount = sdRecipe.ingredients.filter { !$0.isRequired }.count
        #expect(requiredCount == 1)
        #expect(optionalCount == 1)
    }

    // MARK: - Planner Mapping

    @Test
    func toStorage_planner_maps_id_and_day() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, SDPlannerData.self,
            configurations: config
        )
        let context = container.mainContext
        let id = UUID()
        let day = Date()
        let planner = PlannerData(id: id, day: day, recipes: [])

        // When
        let sdPlanner = StorageMapper.toStorage(planner: planner, context: context)

        // Then
        #expect(sdPlanner.id == id)
        #expect(sdPlanner.day == day)
    }

    @Test
    func toStorage_planner_with_no_recipes_maps_empty_list() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, SDPlannerData.self,
            configurations: config
        )
        let context = container.mainContext
        let planner = PlannerData(day: Date(), recipes: [])

        // When
        let sdPlanner = StorageMapper.toStorage(planner: planner, context: context)

        // Then
        #expect(sdPlanner.recipes.isEmpty)
    }

    @Test
    func toStorage_planner_maps_all_recipes() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, SDPlannerData.self,
            configurations: config
        )
        let context = container.mainContext
        let recipe1 = Recipe(name: "Pasta", ingredients: [], mealType: .lunch, isFavorite: false)
        let recipe2 = Recipe(name: "Pizza", ingredients: [], mealType: .dinner, isFavorite: false)
        let planner = PlannerData(day: Date(), recipes: [recipe1, recipe2])

        // When
        let sdPlanner = StorageMapper.toStorage(planner: planner, context: context)

        // Then
        #expect(sdPlanner.recipes.count == 2)
        #expect(sdPlanner.recipes.contains { $0.name == "Pasta" })
        #expect(sdPlanner.recipes.contains { $0.name == "Pizza" })
    }
}
