//
//  RecipeGrouperTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 20/03/26.
//

import Testing
import Foundation
@testable import MiCocina

/// Test suite for `RecipeGrouper` utility.
///
/// `RecipeGrouperTests` validates the recipe grouping and sorting functionality
/// that organizes recipes by meal type and applies intelligent sorting within each group.
@MainActor
struct RecipeGrouperTests {

    /// Tests that recipes are grouped by meal type.
    ///
    /// Verifies that `RecipeGrouper.group()` creates separate groups for each
    /// meal type represented in the input.
    @Test
    func grouper_groups_recipes_by_meal_type() {
        // Given
        let breakfastRecipe = RecipeViewData(
            id: UUID(),
            name: "Eggs",
            mealType: .breakFast,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        let lunchRecipe = RecipeViewData(
            id: UUID(),
            name: "Pasta",
            mealType: .lunch,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        let dinnerRecipe = RecipeViewData(
            id: UUID(),
            name: "Soup",
            mealType: .dinner,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        // When
        let groups = RecipeGrouper.group([breakfastRecipe, lunchRecipe, dinnerRecipe])

        // Then
        #expect(groups.count == 3)
        #expect(groups.contains { $0.mealType == .breakFast })
        #expect(groups.contains { $0.mealType == .lunch })
        #expect(groups.contains { $0.mealType == .dinner })
    }

    /// Tests that groups are sorted by meal type raw value.
    ///
    /// Verifies that the returned groups are sorted alphabetically by
    /// their meal type string representation for consistent display order.
    /// Tests that groups are sorted by meal type raw value.
    ///
    /// Verifies that the returned groups are sorted alphabetically by
    /// their meal type string representation for consistent display order.
    @Test
    func grouper_sorts_groups_by_meal_type_raw_value() {
        // Given
        let dinnerRecipe = RecipeViewData(
            id: UUID(),
            name: "Soup",
            mealType: .dinner,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        let breakfastRecipe = RecipeViewData(
            id: UUID(),
            name: "Eggs",
            mealType: .breakFast,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        let lunchRecipe = RecipeViewData(
            id: UUID(),
            name: "Pasta",
            mealType: .lunch,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        // When - input is not sorted
        let groups = RecipeGrouper.group([dinnerRecipe, breakfastRecipe, lunchRecipe])

        // Then - groups should be sorted by rawValue
        let mealTypes = groups.map { $0.mealType }
        #expect(mealTypes == [.breakFast, .dinner, .lunch])
    }

    /// Tests that favorite recipes appear first within a group.
    ///
    /// Verifies the first sorting criterion: favorite recipes are sorted before non-favorites.
    @Test
    func grouper_sorts_recipes_within_group_favorites_first() {
        // Given
        let favoriteRecipe = RecipeViewData(
            id: UUID(),
            name: "Favorite Pasta",
            mealType: .lunch,
            isFavorite: true,
            canCook: true,
            missingCount: 0
        )

        let nonFavoriteRecipe = RecipeViewData(
            id: UUID(),
            name: "Regular Pasta",
            mealType: .lunch,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        // When
        let groups = RecipeGrouper.group([nonFavoriteRecipe, favoriteRecipe])

        // Then - favorite should come first
        #expect(groups[0].recipes[0].isFavorite == true)
        #expect(groups[0].recipes[1].isFavorite == false)
    }

    @Test
    func grouper_sorts_recipes_within_group_cookable_before_not_cookable() {
        // Given
        let notCookable = RecipeViewData(
            id: UUID(),
            name: "Complex Dish",
            mealType: .lunch,
            isFavorite: false,
            canCook: false,
            missingCount: 5
        )

        let cookable = RecipeViewData(
            id: UUID(),
            name: "Simple Pasta",
            mealType: .lunch,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        // When
        let groups = RecipeGrouper.group([notCookable, cookable])

        // Then - cookable should come before not cookable
        #expect(groups[0].recipes[0].canCook == true)
        #expect(groups[0].recipes[1].canCook == false)
    }

    @Test
    func grouper_sorts_recipes_within_group_by_missing_count() {
        // Given - Both not cookable but with different missing counts
        let moreMissing = RecipeViewData(
            id: UUID(),
            name: "Z Recipe",
            mealType: .lunch,
            isFavorite: false,
            canCook: false,
            missingCount: 5
        )

        let lessMissing = RecipeViewData(
            id: UUID(),
            name: "A Recipe",
            mealType: .lunch,
            isFavorite: false,
            canCook: false,
            missingCount: 2
        )

        // When
        let groups = RecipeGrouper.group([moreMissing, lessMissing])

        // Then - fewer missing ingredients should come first
        #expect(groups[0].recipes[0].missingCount == 2)
        #expect(groups[0].recipes[1].missingCount == 5)
    }

    @Test
    func grouper_sorts_recipes_within_group_alphabetically_by_name() {
        // Given - Same missing count, not cookable
        let zRecipe = RecipeViewData(
            id: UUID(),
            name: "Zebra Stew",
            mealType: .lunch,
            isFavorite: false,
            canCook: false,
            missingCount: 2
        )

        let aRecipe = RecipeViewData(
            id: UUID(),
            name: "Apple Pie",
            mealType: .lunch,
            isFavorite: false,
            canCook: false,
            missingCount: 2
        )

        // When
        let groups = RecipeGrouper.group([zRecipe, aRecipe])

        // Then - alphabetically sorted
        #expect(groups[0].recipes[0].name == "Apple Pie")
        #expect(groups[0].recipes[1].name == "Zebra Stew")
    }

    @Test
    func grouper_applies_complete_sorting_order() {
        // Given
        let recipes = [
            // Non-favorite, not cookable, 3 missing, starts with Z
            RecipeViewData(
                id: UUID(),
                name: "Zebra Stew",
                mealType: .lunch,
                isFavorite: false,
                canCook: false,
                missingCount: 3
            ),
            // Favorite, not cookable, 2 missing
            RecipeViewData(
                id: UUID(),
                name: "Favorite Complex",
                mealType: .lunch,
                isFavorite: true,
                canCook: false,
                missingCount: 2
            ),
            // Non-favorite, cookable, 0 missing, starts with A
            RecipeViewData(
                id: UUID(),
                name: "Apple Pasta",
                mealType: .lunch,
                isFavorite: false,
                canCook: true,
                missingCount: 0
            ),
            // Non-favorite, not cookable, 2 missing, starts with A
            RecipeViewData(
                id: UUID(),
                name: "Apple Stew",
                mealType: .lunch,
                isFavorite: false,
                canCook: false,
                missingCount: 2
            ),
            // Favorite, cookable, 0 missing
            RecipeViewData(
                id: UUID(),
                name: "Favorite Simple",
                mealType: .lunch,
                isFavorite: true,
                canCook: true,
                missingCount: 0
            ),
        ]

        // When
        let groups = RecipeGrouper.group(recipes)

        // Then - order should be:
        // 1. Favorite, cookable
        // 2. Favorite, not cookable
        // 3. Non-favorite, cookable
        // 4. Non-favorite, not cookable (sorted by missing count, then name)
        let recipeNames = groups[0].recipes.map { $0.name }
        #expect(recipeNames == [
            "Favorite Simple",
            "Favorite Complex",
            "Apple Pasta",
            "Apple Stew",
            "Zebra Stew"
        ])
    }

    @Test
    func grouper_handles_empty_recipes() {
        // When
        let groups = RecipeGrouper.group([])

        // Then
        #expect(groups.isEmpty)
    }

    @Test
    func grouper_handles_single_recipe() {
        // Given
        let recipe = RecipeViewData(
            id: UUID(),
            name: "Single Recipe",
            mealType: .lunch,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        // When
        let groups = RecipeGrouper.group([recipe])

        // Then
        #expect(groups.count == 1)
        #expect(groups[0].recipes.count == 1)
        #expect(groups[0].recipes[0].name == "Single Recipe")
    }

    @Test
    func grouper_multiple_groups_are_sorted_correctly() {
        // Given - Mix of meal types in random order
        let otherRecipe = RecipeViewData(
            id: UUID(),
            name: "Other",
            mealType: .other,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        let dinnerRecipe = RecipeViewData(
            id: UUID(),
            name: "Dinner",
            mealType: .dinner,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        let breakfastRecipe = RecipeViewData(
            id: UUID(),
            name: "Breakfast",
            mealType: .breakFast,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        let lunchRecipe = RecipeViewData(
            id: UUID(),
            name: "Lunch",
            mealType: .lunch,
            isFavorite: false,
            canCook: true,
            missingCount: 0
        )

        // When
        let groups = RecipeGrouper.group([otherRecipe, dinnerRecipe, breakfastRecipe, lunchRecipe])

        // Then - should be sorted by meal type raw value
        let expectedOrder: [MealType] = [.breakFast, .dinner, .lunch, .other]
        let actualOrder = groups.map { $0.mealType }
        #expect(actualOrder == expectedOrder)
    }
}
