//
//  StorageMapperTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 02/04/26.
//

import Testing
import SwiftData
@testable import MiCocina

@MainActor
struct StorageMapperTests {
    
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
    
    @Test
    func toStorage_recipeIngredient_maps_correctly() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        let sdRecipe = SDRecipe(name: "Pasta", mealType: "lunch", isFavorite: false)
        let sdIngredient = SDIngredient(name: "Pasta")
        let domainRecipeIngredient = RecipeIngredient(
            ingredient: Ingredient(name: "Pasta"),
            isRequired: true
        )
        
        // When
        let sdRecipeIngredient = StorageMapper.toStorage(
            domainRecipeIngredient,
            recipe: sdRecipe,
            ingredient: sdIngredient,
            context: context
        )
        
        // Then
        #expect(sdRecipeIngredient.isRequired == true)
        #expect(sdRecipeIngredient.recipe === sdRecipe)
        #expect(sdRecipeIngredient.ingredient === sdIngredient)
    }
    
    @Test
    func toStorage_recipeIngredient_respects_isRequired_false() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        let sdRecipe = SDRecipe(name: "Pizza", mealType: "lunch", isFavorite: false)
        let sdIngredient = SDIngredient(name: "Oregano")
        let domainRecipeIngredient = RecipeIngredient(
            ingredient: Ingredient(name: "Oregano"),
            isRequired: false
        )
        
        // When
        let sdRecipeIngredient = StorageMapper.toStorage(
            domainRecipeIngredient,
            recipe: sdRecipe,
            ingredient: sdIngredient,
            context: context
        )
        
        // Then
        #expect(sdRecipeIngredient.isRequired == false)
    }
    
    @Test
    func toStorage_recipe_maps_correctly() async {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, configurations: config)
        let context = container.mainContext
        let pasta = Ingredient(name: "Pasta")
        let eggs = Ingredient(name: "Eggs")
        
        let recipe = Recipe(
            name: "Pasta Carbonara",
            ingredients: [
                RecipeIngredient(ingredient: pasta, isRequired: true),
                RecipeIngredient(ingredient: eggs, isRequired: true)
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
        let ingredients = [
            Ingredient(name: "Lettuce"),
            Ingredient(name: "Tomato"),
            Ingredient(name: "Cucumber")
        ]
        
        let recipe = Recipe(
            name: "Salad",
            ingredients: Set(ingredients.map { RecipeIngredient(ingredient: $0, isRequired: true) }),
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
        let requiredIng = Ingredient(name: "Rice")
        let optionalIng = Ingredient(name: "Pepper")
        
        let recipe = Recipe(
            name: "Flexible Recipe",
            ingredients: [
                RecipeIngredient(ingredient: requiredIng, isRequired: true),
                RecipeIngredient(ingredient: optionalIng, isRequired: false)
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
}
