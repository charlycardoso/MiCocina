//
//  DomainMapperTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 02/04/26.
//

import Testing
@testable import MiCocina

struct DomainMapperTests {

    @Test
    func toDomain_ingredient_maps_correctly() {
        // Given
        let sdIngredient = SDIngredient(name: "Tomato")

        // When
        let ingredient = DomainMapper.toDomain(ingredient: sdIngredient)

        // Then
        #expect(ingredient.name == "tomato")
    }

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

    @Test
    func toDomain_recipeIngredient_maps_correctly() {
        // Given
        let sdIngredient = SDIngredient(name: "Basil")
        let sdRecipeIngredient = SDRecipeIngredient(
            recipe: SDRecipe(name: "Pasta", mealType: "lunch", isFavorite: false),
            ingredient: sdIngredient,
            isRequired: true
        )

        // When
        let recipeIngredient = DomainMapper.toDomain(recipeIngredient: sdRecipeIngredient)

        // Then
        #expect(recipeIngredient.ingredient.name == "basil")
        #expect(recipeIngredient.isRequired == true)
    }

    @Test
    func toDomain_recipeIngredient_respects_isRequired_false() {
        // Given
        let sdIngredient = SDIngredient(name: "Oregano")
        let sdRecipeIngredient = SDRecipeIngredient(
            recipe: SDRecipe(name: "Pizza", mealType: "lunch", isFavorite: false),
            ingredient: sdIngredient,
            isRequired: false
        )

        // When
        let recipeIngredient = DomainMapper.toDomain(recipeIngredient: sdRecipeIngredient)

        // Then
        #expect(recipeIngredient.isRequired == false)
    }

    @Test
    func toDomain_recipe_maps_correctly() {
        // Given
        let sdRecipe = SDRecipe(name: "Pasta Carbonara", mealType: "lunch", isFavorite: true)
        let ingredient1 = SDIngredient(name: "Pasta")
        let ingredient2 = SDIngredient(name: "Eggs")
        
        let sdRecipeIng1 = SDRecipeIngredient(
            recipe: sdRecipe,
            ingredient: ingredient1,
            isRequired: true
        )
        let sdRecipeIng2 = SDRecipeIngredient(
            recipe: sdRecipe,
            ingredient: ingredient2,
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
            SDRecipeIngredient(recipe: sdRecipe, ingredient: ing, isRequired: true)
        }
        
        sdRecipe.ingredients = recipeIngredients

        // When
        let recipe = DomainMapper.toDomain(recipe: sdRecipe)

        // Then
        #expect(recipe.ingredients.count == 4)
        let ingredientNames = recipe.ingredients.map { $0.ingredient.name }
        #expect(ingredientNames.contains("lettuce"))
        #expect(ingredientNames.contains("tomato"))
        #expect(ingredientNames.contains("cucumber"))
        #expect(ingredientNames.contains("olive oil"))
    }

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

    @Test
    func toDomain_recipe_with_mixed_required_ingredients() {
        // Given
        let sdRecipe = SDRecipe(name: "Flexible Recipe", mealType: "dinner", isFavorite: false)
        let requiredIng = SDIngredient(name: "Rice")
        let optionalIng = SDIngredient(name: "Pepper")
        
        let sdRecipeIng1 = SDRecipeIngredient(
            recipe: sdRecipe,
            ingredient: requiredIng,
            isRequired: true
        )
        let sdRecipeIng2 = SDRecipeIngredient(
            recipe: sdRecipe,
            ingredient: optionalIng,
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
}
