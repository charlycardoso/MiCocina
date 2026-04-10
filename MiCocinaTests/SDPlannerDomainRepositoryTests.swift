//
//  SDPlannerDomainRepositoryTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 10/04/26.
//

import Testing
import SwiftData
import Foundation
@testable import MiCocina

/// Test suite for `SDPlannerDomainRepository` SwiftData-based planner persistence.
///
/// Validates all CRUD operations including fetching by day, saving (with normalization),
/// removing, and moving recipes between days.
@Suite
struct SDPlannerDomainRepositoryTests {
    private var container: ModelContainer
    private var context: ModelContext
    private var repository: SDPlannerDomainRepository

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self, SDPlannerData.self,
            configurations: config
        )
        context = ModelContext(container)
        repository = SDPlannerDomainRepository(context: context)
    }

    private func makeDay(_ offset: Int = 0) -> Date {
        let base = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: offset, to: base)!
    }

    private func makeRecipe(name: String = "Test Recipe") -> Recipe {
        Recipe(id: .init(), name: name, ingredients: [], mealType: .other, isFavorite: false)
    }

    // MARK: - get(by:) Tests

    @Test
    func get_nonexistent_day_returns_nil() {
        let result = repository.get(by: makeDay())
        #expect(result == nil)
    }

    @Test
    func get_existing_day_returns_planner() throws {
        // Given
        let day = makeDay()
        try repository.save(PlannerData(day: day, recipes: []))

        // When
        let result = repository.get(by: day)

        // Then
        #expect(result != nil)
    }

    @Test
    func get_returns_planner_with_correct_recipes() throws {
        // Given
        let day = makeDay()
        let recipe = makeRecipe(name: "Pasta")
        try repository.save(PlannerData(day: day, recipes: [recipe]))

        // When
        let result = repository.get(by: day)

        // Then
        #expect(result?.recipes.count == 1)
        #expect(result?.recipes.first?.name == "Pasta")
    }

    @Test
    func get_different_day_returns_nil() throws {
        // Given
        let day1 = makeDay(0)
        let day2 = makeDay(1)
        try repository.save(PlannerData(day: day1, recipes: []))

        // When
        let result = repository.get(by: day2)

        // Then
        #expect(result == nil)
    }

    // MARK: - save Tests

    @Test
    func save_new_planner_persists_successfully() throws {
        // Given
        let day = makeDay()

        // When
        try repository.save(PlannerData(day: day, recipes: []))

        // Then
        #expect(repository.get(by: day) != nil)
    }

    @Test
    func save_normalizes_day_to_start_of_day() throws {
        // Given - date with a time component
        let rawDate = Date()
        let normalizedDay = Calendar.current.startOfDay(for: rawDate)

        // When
        try repository.save(PlannerData(day: rawDate, recipes: []))

        // Then - fetching by normalized day should find it
        let result = repository.get(by: normalizedDay)
        #expect(result != nil)
    }

    @Test
    func save_updates_existing_planner_on_same_day() throws {
        // Given
        let day = makeDay()
        try repository.save(PlannerData(day: day, recipes: [makeRecipe(name: "Pasta")]))

        // When - overwrite with a different recipe
        try repository.save(PlannerData(day: day, recipes: [makeRecipe(name: "Pizza")]))

        // Then - only the latest recipes should remain
        let result = repository.get(by: day)
        #expect(result?.recipes.count == 1)
        #expect(result?.recipes.first?.name == "Pizza")
    }

    @Test
    func save_preserves_planner_id() throws {
        // Given
        let day = makeDay()
        let planner = PlannerData(id: UUID(), day: day, recipes: [])

        // When
        try repository.save(planner)

        // Then
        let result = repository.get(by: day)
        #expect(result?.id == planner.id)
    }

    @Test
    func save_multiple_days_are_independent() throws {
        // Given
        let day1 = makeDay(0)
        let day2 = makeDay(1)

        // When
        try repository.save(PlannerData(day: day1, recipes: [makeRecipe(name: "Monday Meal")]))
        try repository.save(PlannerData(day: day2, recipes: [makeRecipe(name: "Tuesday Meal")]))

        // Then
        #expect(repository.get(by: day1)?.recipes.first?.name == "Monday Meal")
        #expect(repository.get(by: day2)?.recipes.first?.name == "Tuesday Meal")
    }

    // MARK: - removePlanner Tests

    @Test
    func removePlanner_removes_existing_planner() throws {
        // Given
        let day = makeDay()
        try repository.save(PlannerData(day: day, recipes: []))

        // When
        try repository.removePlanner(day: day)

        // Then
        #expect(repository.get(by: day) == nil)
    }

    @Test
    func removePlanner_nonexistent_does_not_throw() throws {
        // When/Then - should not throw when nothing to delete
        try repository.removePlanner(day: makeDay())
    }

    @Test
    func removePlanner_does_not_affect_other_days() throws {
        // Given
        let day1 = makeDay(0)
        let day2 = makeDay(1)
        try repository.save(PlannerData(day: day1, recipes: []))
        try repository.save(PlannerData(day: day2, recipes: []))

        // When
        try repository.removePlanner(day: day1)

        // Then
        #expect(repository.get(by: day1) == nil)
        #expect(repository.get(by: day2) != nil)
    }

    // MARK: - movePlanner Tests

    @Test
    func movePlanner_moves_recipe_to_destination_day() throws {
        // Given
        let fromDay = makeDay(0)
        let toDay = makeDay(1)
        let recipe = makeRecipe(name: "Pasta")
        try repository.save(PlannerData(day: fromDay, recipes: [recipe]))

        // When
        try repository.movePlanner(recipeID: recipe.id, from: fromDay, to: toDay)

        // Then
        #expect(repository.get(by: fromDay)?.recipes.isEmpty == true)
        #expect(repository.get(by: toDay)?.recipes.count == 1)
        #expect(repository.get(by: toDay)?.recipes.first?.name == "Pasta")
    }

    @Test
    func movePlanner_creates_destination_planner_if_not_exists() throws {
        // Given
        let fromDay = makeDay(0)
        let toDay = makeDay(1)
        let recipe = makeRecipe(name: "Soup")
        try repository.save(PlannerData(day: fromDay, recipes: [recipe]))
        #expect(repository.get(by: toDay) == nil)

        // When
        try repository.movePlanner(recipeID: recipe.id, from: fromDay, to: toDay)

        // Then
        #expect(repository.get(by: toDay) != nil)
        #expect(repository.get(by: toDay)?.recipes.count == 1)
    }

    @Test
    func movePlanner_appends_to_existing_destination() throws {
        // Given
        let fromDay = makeDay(0)
        let toDay = makeDay(1)
        let recipeToMove = makeRecipe(name: "Pasta")
        let existingRecipe = makeRecipe(name: "Salad")
        try repository.save(PlannerData(day: fromDay, recipes: [recipeToMove]))
        try repository.save(PlannerData(day: toDay, recipes: [existingRecipe]))

        // When
        try repository.movePlanner(recipeID: recipeToMove.id, from: fromDay, to: toDay)

        // Then
        #expect(repository.get(by: toDay)?.recipes.count == 2)
    }

    @Test
    func movePlanner_throws_when_source_planner_not_found() {
        // Given - no planner saved for fromDay
        #expect(throws: RepositoryError.self) {
            try repository.movePlanner(recipeID: UUID(), from: makeDay(0), to: makeDay(1))
        }
    }

    @Test
    func movePlanner_throws_when_recipe_not_in_source() throws {
        // Given
        let fromDay = makeDay(0)
        try repository.save(PlannerData(day: fromDay, recipes: [makeRecipe(name: "Pasta")]))

        // When/Then - non-existent recipe ID
        #expect(throws: RepositoryError.self) {
            try repository.movePlanner(recipeID: UUID(), from: fromDay, to: makeDay(1))
        }
    }

    @Test
    func movePlanner_only_moves_specified_recipe() throws {
        // Given - fromDay has two recipes
        let fromDay = makeDay(0)
        let toDay = makeDay(1)
        let recipeToMove = makeRecipe(name: "Pasta")
        let recipeToKeep = makeRecipe(name: "Salad")
        try repository.save(PlannerData(day: fromDay, recipes: [recipeToMove, recipeToKeep]))

        // When - only move Pasta
        try repository.movePlanner(recipeID: recipeToMove.id, from: fromDay, to: toDay)

        // Then - fromDay still has Salad, toDay has only Pasta
        let fromResult = repository.get(by: fromDay)
        let toResult = repository.get(by: toDay)
        #expect(fromResult?.recipes.count == 1)
        #expect(fromResult?.recipes.first?.name == "Salad")
        #expect(toResult?.recipes.count == 1)
        #expect(toResult?.recipes.first?.name == "Pasta")
    }
}
