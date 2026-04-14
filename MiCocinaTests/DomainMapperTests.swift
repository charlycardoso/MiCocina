//
//  DomainMapperTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 02/04/26.
//

import Testing
import Foundation
@testable import MiCocina

/// Test suite for `DomainMapper` persistence model to domain model conversion.
///
/// `DomainMapperTests` validates the mapping of storage layer models (`SD*` classes)
/// to domain models. Tests ensure proper transformation of data including normalization
/// of ingredient names and preservation of relationships.
struct DomainMapperTests {

    /// Tests that storage ingredients are correctly converted to domain ingredients.
    ///
    /// Verifies that the ingredient name is normalized (lowercase) during conversion.
    @Test
    func toDomain_ingredient_maps_correctly() {
        // Given
        let sdIngredient = SDIngredient(name: "Tomato")

        // When
        let ingredient = DomainMapper.toDomain(ingredient: sdIngredient)

        // Then
        #expect(ingredient.name == "tomato")
    }

    /// Tests that ingredient names are preserved (not empty) after conversion.
    ///
    /// Verifies that the mapping handles various ingredient name formats correctly.
    @Test
    func toDomain_ingredient_preserves_name() {
        // Given
        let testNames = ["Pasta", "Olive Oil", "GARLIC", "Salt"]

        // When & Then
        for name in testNames {
            let sdIngredient = SDIngredient(name: name)
            let ingredient = DomainMapper.toDomain(ingredient: sdIngredient)
            #expect(!ingredient.name.isEmpty)
        }
    }

    /// Tests that recipe ingredients are correctly converted from storage to domain.
    ///
    /// Verifies that both the ingredient and the isRequired flag are preserved during conversion.
    @Test
    func toDomain_recipeIngredient_maps_correctly() {
        // Given
        let sdIngredient = SDIngredient(name: "Basil")
        let sdRecipeIngredient = SDRecipeIngredient(
            recipe: SDRecipe(name: "Pasta", mealType: "lunch", isFavorite: false),
            ingredientName: sdIngredient.name,
            isRequired: true
        )

        // When
        let recipeIngredient = DomainMapper.toDomain(recipeIngredient: sdRecipeIngredient)

        // Then
        #expect(recipeIngredient.ingredientName == "basil")
        #expect(recipeIngredient.isRequired == true)
    }

    /// Tests that optional recipe ingredients are handled correctly.
    ///
    /// Verifies that the isRequired flag is properly preserved when false.
    @Test
    func toDomain_recipeIngredient_respects_isRequired_false() {
        // Given
        let sdIngredient = SDIngredient(name: "Oregano")
        let sdRecipeIngredient = SDRecipeIngredient(
            recipe: SDRecipe(name: "Pizza", mealType: "lunch", isFavorite: false),
            ingredientName: sdIngredient.name,
            isRequired: false
        )

        // When
        let recipeIngredient = DomainMapper.toDomain(recipeIngredient: sdRecipeIngredient)

        // Then
        #expect(recipeIngredient.isRequired == false)
    }

    /// Tests that storage recipes are correctly converted to domain recipes.
    ///
    /// Verifies that recipe properties and ingredients are properly mapped.
    @Test
    func toDomain_recipe_maps_correctly() {
        // Given
        let sdRecipe = SDRecipe(name: "Pasta Carbonara", mealType: "lunch", isFavorite: true)
        let ingredient1 = SDIngredient(name: "Pasta")
        let ingredient2 = SDIngredient(name: "Eggs")
        
        let sdRecipeIng1 = SDRecipeIngredient(
            recipe: sdRecipe,
            ingredientName: ingredient1.name,
            isRequired: true
        )
        let sdRecipeIng2 = SDRecipeIngredient(
            recipe: sdRecipe,
            ingredientName: ingredient2.name,
            isRequired: true
        )
        
        sdRecipe.ingredients = [sdRecipeIng1, sdRecipeIng2]

        // When
        let recipe = DomainMapper.toDomain(recipe: sdRecipe)

        // Then
        #expect(recipe.name == "Pasta Carbonara")
        #expect(recipe.mealType == .lunch)
        #expect(recipe.isFavorite == true)
        #expect(recipe.ingredients.count == 2)
    }

    /// Tests that all ingredients are correctly mapped from storage recipe to domain recipe.
    ///
    /// Verifies that multiple ingredients are all properly converted and included.
    @Test
    func toDomain_recipe_maps_all_ingredients() {
        // Given
        let sdRecipe = SDRecipe(name: "Salad", mealType: "lunch", isFavorite: false)
        let ingredients = [
            SDIngredient(name: "Lettuce"),
            SDIngredient(name: "Tomato"),
            SDIngredient(name: "Cucumber"),
            SDIngredient(name: "Olive Oil")
        ]
        
        let recipeIngredients = ingredients.map { ing in
            SDRecipeIngredient(recipe: sdRecipe, ingredientName: ing.name, isRequired: true)
        }
        
        sdRecipe.ingredients = recipeIngredients

        // When
        let recipe = DomainMapper.toDomain(recipe: sdRecipe)

        // Then
        #expect(recipe.ingredients.count == 4)
        let ingredientNames = recipe.ingredients.map { $0.ingredientName }
        #expect(ingredientNames.contains("lettuce"))
        #expect(ingredientNames.contains("tomato"))
        #expect(ingredientNames.contains("cucumber"))
        #expect(ingredientNames.contains("olive oil"))
    }

    /// Tests that meal type strings are correctly converted to MealType enums.
    ///
    /// Verifies proper conversion of all meal type values.
    @Test
    func toDomain_recipe_respects_mealType() {
        // Given
        let testCases: [(String, MealType)] = [
            ("breakFast", .breakFast),
            ("lunch", .lunch),
            ("dinner", .dinner),
            ("other", .other)
        ]

        // When & Then
        for (mealTypeString, expectedMealType) in testCases {
            let sdRecipe = SDRecipe(name: "Test", mealType: mealTypeString, isFavorite: false)
            let recipe = DomainMapper.toDomain(recipe: sdRecipe)
            #expect(recipe.mealType == expectedMealType)
        }
    }

    /// Tests that the isFavorite flag is correctly preserved during conversion.
    ///
    /// Verifies that both true and false values are properly maintained.
    @Test
    func toDomain_recipe_respects_isFavorite_flag() {
        // Given
        let favoriteRecipe = SDRecipe(name: "Favorite", mealType: "lunch", isFavorite: true)
        let nonFavoriteRecipe = SDRecipe(name: "Not Favorite", mealType: "lunch", isFavorite: false)

        // When
        let domainFavorite = DomainMapper.toDomain(recipe: favoriteRecipe)
        let domainNonFavorite = DomainMapper.toDomain(recipe: nonFavoriteRecipe)

        // Then
        #expect(domainFavorite.isFavorite == true)
        #expect(domainNonFavorite.isFavorite == false)
    }

    /// Tests that recipes with both required and optional ingredients are handled correctly.
    ///
    /// Verifies that the isRequired flag is properly preserved for multiple ingredients.
    @Test
    func toDomain_recipe_with_mixed_required_ingredients() {
        // Given
        let sdRecipe = SDRecipe(name: "Flexible Recipe", mealType: "dinner", isFavorite: false)
        let requiredIng = SDIngredient(name: "Rice")
        let optionalIng = SDIngredient(name: "Pepper")
        
        let sdRecipeIng1 = SDRecipeIngredient(
            recipe: sdRecipe,
            ingredientName: requiredIng.name,
            isRequired: true
        )
        let sdRecipeIng2 = SDRecipeIngredient(
            recipe: sdRecipe,
            ingredientName: optionalIng.name,
            isRequired: false
        )
        
        sdRecipe.ingredients = [sdRecipeIng1, sdRecipeIng2]

        // When
        let recipe = DomainMapper.toDomain(recipe: sdRecipe)

        // Then
        #expect(recipe.ingredients.count == 2)
        let requiredCount = recipe.ingredients.filter { $0.isRequired }.count
        let optionalCount = recipe.ingredients.filter { !$0.isRequired }.count
        #expect(requiredCount == 1)
        #expect(optionalCount == 1)
    }

    /// Tests that ingredient names with spaces are correctly normalized.
    ///
    /// Verifies that multi-word ingredient names (like "Olive Oil") preserve spacing
    /// during normalization, distinguishing them from single-word variants.
    @Test
    func toDomain_ingredient_preserves_spaces() {
        // Given - Two ingredients with similar names but different spacing
        let sdOliveOil = SDIngredient(name: "Olive Oil")
        let sdOliveOilNoSpace = SDIngredient(name: "OliveOil")

        // When
        let oliveOil = DomainMapper.toDomain(ingredient: sdOliveOil)
        let oliveOilNoSpace = DomainMapper.toDomain(ingredient: sdOliveOilNoSpace)

        // Then - Spaces should be preserved after normalization
        #expect(oliveOil.name == "olive oil")
        #expect(oliveOilNoSpace.name == "oliveoil")
        #expect(oliveOil.name != oliveOilNoSpace.name)
    }

    // MARK: - Planner Mapping

    @Test
    func toDomain_planner_maps_id_and_day() {
        // Given
        let id = UUID()
        let day = Date()
        let sdPlanner = SDPlannerData(id: id, day: day, recipes: [])

        // When
        let planner = DomainMapper.toDomain(planner: sdPlanner)

        // Then
        #expect(planner.id == id)
        #expect(planner.day == day)
    }

    @Test
    func toDomain_planner_with_no_recipes_returns_empty_list() {
        // Given
        let sdPlanner = SDPlannerData(day: Date(), recipes: [])

        // When
        let planner = DomainMapper.toDomain(planner: sdPlanner)

        // Then
        #expect(planner.recipes.isEmpty)
    }

    @Test
    func toDomain_planner_maps_all_recipes() {
        // Given
        let recipe1 = SDRecipe(name: "Pasta", mealType: "lunch", isFavorite: false)
        let recipe2 = SDRecipe(name: "Pizza", mealType: "dinner", isFavorite: true)
        let sdPlanner = SDPlannerData(day: Date(), recipes: [recipe1, recipe2])

        // When
        let planner = DomainMapper.toDomain(planner: sdPlanner)

        // Then
        #expect(planner.recipes.count == 2)
        #expect(planner.recipes.contains { $0.name == "Pasta" })
        #expect(planner.recipes.contains { $0.name == "Pizza" })
    }
}
