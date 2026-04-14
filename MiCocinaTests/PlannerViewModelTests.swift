//
//  PlannerViewModelTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Testing
import SwiftData
import Foundation
import Combine
@testable import MiCocina

/// Test suite for `PlannerViewModel` presentation layer logic.
///
/// Validates view model behavior including fetching recipe groups, delegating
/// repository operations, and publishing changes. Uses an in-memory SwiftData
/// store for isolated, repeatable tests.
///
/// Tests cover:
/// - Fetching and transforming planner data into recipe groups
/// - Published property updates
/// - Repository delegation (get, save, remove, move)
/// - Edge cases (nil data, empty recipes, errors)
@Suite
struct PlannerViewModelTests {
    private var container: ModelContainer
    private var context: ModelContext
    private var viewModel: PlannerViewModel
    
    /// Initializes a fresh test environment with in-memory storage.
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: SDRecipe.self, 
            SDIngredient.self, 
            SDRecipeIngredient.self, 
            SDPlannerData.self,
            configurations: config
        )
        context = ModelContext(container)
        viewModel = PlannerViewModel(context: context)
    }
    
    // MARK: - Test Helpers
    
    /// Creates a date normalized to the start of the day.
    ///
    /// - Parameter offset: Number of days to offset from today (default: 0)
    /// - Returns: Normalized date at midnight
    private func makeDay(_ offset: Int = 0) -> Date {
        let base = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: offset, to: base)!
    }
    
    /// Creates a test recipe with minimal required properties.
    ///
    /// - Parameters:
    ///   - name: Recipe name (default: "Test Recipe")
    ///   - mealType: Meal type classification (default: .lunch)
    ///   - isFavorite: Whether recipe is marked as favorite (default: false)
    /// - Returns: A new Recipe instance
    private func makeRecipe(
        name: String = "Test Recipe",
        mealType: MealType = .lunch,
        isFavorite: Bool = false
    ) -> Recipe {
        Recipe(
            id: UUID(),
            name: name,
            ingredients: [],
            mealType: mealType,
            isFavorite: isFavorite
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("ViewModel initializes with correct context")
    func initialization_sets_context() {
        // Then
        #expect(viewModel.context === context)
    }
    
    @Test("ViewModel initializes with empty recipe groups")
    func initialization_has_empty_recipe_groups() {
        // Then
        #expect(viewModel.recipeGroups.isEmpty)
    }
    
    // MARK: - fetchRecipeGroups Tests
    
    @Test("fetchRecipeGroups with no planner data leaves groups empty")
    func fetchRecipeGroups_no_data_leaves_empty() {
        // Given
        let day = makeDay()
        
        // When
        viewModel.fetchRecipeGroups(with: day)
        
        // Then
        #expect(viewModel.recipeGroups.isEmpty)
    }
    
    @Test("fetchRecipeGroups with empty recipes produces empty groups")
    func fetchRecipeGroups_empty_recipes_produces_empty_groups() throws {
        // Given
        let day = makeDay()
        let plannerData = PlannerData(day: day, recipes: [])
        try viewModel.save(plannerData)
        
        // When
        viewModel.fetchRecipeGroups(with: day)
        
        // Then
        #expect(viewModel.recipeGroups.isEmpty)
    }
    
    @Test("fetchRecipeGroups populates recipe groups from planner data")
    func fetchRecipeGroups_populates_groups() throws {
        // Given
        let day = makeDay()
        let recipe = makeRecipe(name: "Pasta", mealType: .lunch)
        let plannerData = PlannerData(day: day, recipes: [recipe])
        try viewModel.save(plannerData)
        
        // When
        viewModel.fetchRecipeGroups(with: day)
        
        // Then
        #expect(!viewModel.recipeGroups.isEmpty)
        #expect(viewModel.recipeGroups.count == 1)
        #expect(viewModel.recipeGroups.first?.mealType == .lunch)
    }
    
    @Test("fetchRecipeGroups groups recipes by meal type")
    func fetchRecipeGroups_groups_by_meal_type() throws {
        // Given
        let day = makeDay()
        let breakfastRecipe = makeRecipe(name: "Pancakes", mealType: .breakFast)
        let lunchRecipe = makeRecipe(name: "Sandwich", mealType: .lunch)
        let dinnerRecipe = makeRecipe(name: "Steak", mealType: .dinner)
        
        let plannerData = PlannerData(
            day: day,
            recipes: [breakfastRecipe, lunchRecipe, dinnerRecipe]
        )
        try viewModel.save(plannerData)
        
        // When
        viewModel.fetchRecipeGroups(with: day)
        
        // Then
        #expect(viewModel.recipeGroups.count == 3)
        
        let mealTypes = Set(viewModel.recipeGroups.map { $0.mealType })
        #expect(mealTypes.contains(.breakFast))
        #expect(mealTypes.contains(.lunch))
        #expect(mealTypes.contains(.dinner))
    }
    
    @Test("fetchRecipeGroups with multiple recipes in same meal type")
    func fetchRecipeGroups_multiple_recipes_same_meal_type() throws {
        // Given
        let day = makeDay()
        let recipe1 = makeRecipe(name: "Pasta", mealType: .lunch)
        let recipe2 = makeRecipe(name: "Salad", mealType: .lunch)
        let recipe3 = makeRecipe(name: "Soup", mealType: .lunch)
        
        let plannerData = PlannerData(day: day, recipes: [recipe1, recipe2, recipe3])
        try viewModel.save(plannerData)
        
        // When
        viewModel.fetchRecipeGroups(with: day)
        
        // Then
        #expect(viewModel.recipeGroups.count == 1)
        #expect(viewModel.recipeGroups.first?.recipes.count == 3)
    }
    
    @Test("fetchRecipeGroups updates on different dates")
    func fetchRecipeGroups_updates_for_different_dates() throws {
        // Given
        let day1 = makeDay(0)
        let day2 = makeDay(1)
        
        try viewModel.save(PlannerData(day: day1, recipes: [makeRecipe(name: "Monday")]))
        try viewModel.save(PlannerData(day: day2, recipes: [makeRecipe(name: "Tuesday")]))
        
        // When - fetch day 1
        viewModel.fetchRecipeGroups(with: day1)
        
        // Then
        #expect(viewModel.recipeGroups.first?.recipes.first?.name == "Monday")
        
        // When - fetch day 2
        viewModel.fetchRecipeGroups(with: day2)
        
        // Then
        #expect(viewModel.recipeGroups.first?.recipes.first?.name == "Tuesday")
    }
    
    // MARK: - get(by:) Tests
    
    @Test("get returns nil for non-existent date")
    func get_returns_nil_for_nonexistent_date() {
        // Given
        let day = makeDay()
        
        // When
        let result = viewModel.get(by: day)
        
        // Then
        #expect(result == nil)
    }
    
    @Test("get returns planner data for existing date")
    func get_returns_data_for_existing_date() throws {
        // Given
        let day = makeDay()
        let recipe = makeRecipe(name: "Pasta")
        let plannerData = PlannerData(day: day, recipes: [recipe])
        try viewModel.save(plannerData)
        
        // When
        let result = viewModel.get(by: day)
        
        // Then
        #expect(result != nil)
        #expect(result?.recipes.count == 1)
        #expect(result?.recipes.first?.name == "Pasta")
    }
    
    @Test("get returns correct planner for specific date")
    func get_returns_correct_planner_for_date() throws {
        // Given
        let day1 = makeDay(0)
        let day2 = makeDay(1)
        try viewModel.save(PlannerData(day: day1, recipes: [makeRecipe(name: "Monday")]))
        try viewModel.save(PlannerData(day: day2, recipes: [makeRecipe(name: "Tuesday")]))
        
        // When
        let result = viewModel.get(by: day1)
        
        // Then
        #expect(result?.recipes.first?.name == "Monday")
    }
    
    // MARK: - save(_:) Tests
    
    @Test("save persists planner data successfully")
    func save_persists_data() throws {
        // Given
        let day = makeDay()
        let recipe = makeRecipe(name: "Pizza")
        let plannerData = PlannerData(day: day, recipes: [recipe])
        
        // When
        try viewModel.save(plannerData)
        
        // Then
        let retrieved = viewModel.get(by: day)
        #expect(retrieved != nil)
        #expect(retrieved?.recipes.count == 1)
        #expect(retrieved?.recipes.first?.name == "Pizza")
    }
    
    @Test("save updates existing planner on same day")
    func save_updates_existing_planner() throws {
        // Given
        let day = makeDay()
        try viewModel.save(PlannerData(day: day, recipes: [makeRecipe(name: "Original")]))
        
        // When - save different data for same day
        try viewModel.save(PlannerData(day: day, recipes: [makeRecipe(name: "Updated")]))
        
        // Then
        let result = viewModel.get(by: day)
        #expect(result?.recipes.count == 1)
        #expect(result?.recipes.first?.name == "Updated")
    }
    
    @Test("save handles multiple recipes")
    func save_handles_multiple_recipes() throws {
        // Given
        let day = makeDay()
        let recipes = [
            makeRecipe(name: "Recipe 1", mealType: .breakFast),
            makeRecipe(name: "Recipe 2", mealType: .lunch),
            makeRecipe(name: "Recipe 3", mealType: .dinner)
        ]
        let plannerData = PlannerData(day: day, recipes: recipes)
        
        // When
        try viewModel.save(plannerData)
        
        // Then
        let result = viewModel.get(by: day)
        #expect(result?.recipes.count == 3)
    }
    
    @Test("save preserves planner ID")
    func save_preserves_planner_id() throws {
        // Given
        let day = makeDay()
        let id = UUID()
        let plannerData = PlannerData(id: id, day: day, recipes: [])
        
        // When
        try viewModel.save(plannerData)
        
        // Then
        let result = viewModel.get(by: day)
        #expect(result?.id == id)
    }
    
    @Test("save can store empty recipe list")
    func save_can_store_empty_recipes() throws {
        // Given
        let day = makeDay()
        let plannerData = PlannerData(day: day, recipes: [])
        
        // When
        try viewModel.save(plannerData)
        
        // Then
        let result = viewModel.get(by: day)
        #expect(result != nil)
        #expect(result?.recipes.isEmpty == true)
    }
    
    // MARK: - removePlanner(day:) Tests
    
    @Test("removePlanner deletes existing planner")
    func removePlanner_deletes_existing() throws {
        // Given
        let day = makeDay()
        try viewModel.save(PlannerData(day: day, recipes: [makeRecipe()]))
        #expect(viewModel.get(by: day) != nil)
        
        // When
        try viewModel.removePlanner(day: day)
        
        // Then
        #expect(viewModel.get(by: day) == nil)
    }
    
    @Test("removePlanner does not throw for non-existent planner")
    func removePlanner_nonexistent_does_not_throw() throws {
        // Given
        let day = makeDay()
        
        // When/Then - should not throw
        try viewModel.removePlanner(day: day)
    }
    
    @Test("removePlanner only removes specified day")
    func removePlanner_only_removes_specified_day() throws {
        // Given
        let day1 = makeDay(0)
        let day2 = makeDay(1)
        try viewModel.save(PlannerData(day: day1, recipes: [makeRecipe(name: "Day 1")]))
        try viewModel.save(PlannerData(day: day2, recipes: [makeRecipe(name: "Day 2")]))
        
        // When
        try viewModel.removePlanner(day: day1)
        
        // Then
        #expect(viewModel.get(by: day1) == nil)
        #expect(viewModel.get(by: day2) != nil)
    }
    
    @Test("removePlanner clears recipe groups after deletion")
    func removePlanner_clears_groups_after_deletion() throws {
        // Given
        let day = makeDay()
        try viewModel.save(PlannerData(day: day, recipes: [makeRecipe()]))
        viewModel.fetchRecipeGroups(with: day)
        #expect(!viewModel.recipeGroups.isEmpty)
        
        // When
        try viewModel.removePlanner(day: day)
        viewModel.fetchRecipeGroups(with: day)
        
        // Then
        #expect(viewModel.recipeGroups.isEmpty)
    }
    
    // MARK: - movePlanner Tests
    
    @Test("movePlanner moves recipe to destination day")
    func movePlanner_moves_recipe() throws {
        // Given
        let fromDay = makeDay(0)
        let toDay = makeDay(1)
        let recipe = makeRecipe(name: "Movable Recipe")
        try viewModel.save(PlannerData(day: fromDay, recipes: [recipe]))
        
        // When
        try viewModel.movePlanner(recipeID: recipe.id, from: fromDay, to: toDay)
        
        // Then
        let fromResult = viewModel.get(by: fromDay)
        let toResult = viewModel.get(by: toDay)
        
        #expect(fromResult?.recipes.isEmpty == true)
        #expect(toResult?.recipes.count == 1)
        #expect(toResult?.recipes.first?.name == "Movable Recipe")
    }
    
    @Test("movePlanner creates destination planner if not exists")
    func movePlanner_creates_destination() throws {
        // Given
        let fromDay = makeDay(0)
        let toDay = makeDay(1)
        let recipe = makeRecipe(name: "Recipe")
        try viewModel.save(PlannerData(day: fromDay, recipes: [recipe]))
        #expect(viewModel.get(by: toDay) == nil)
        
        // When
        try viewModel.movePlanner(recipeID: recipe.id, from: fromDay, to: toDay)
        
        // Then
        #expect(viewModel.get(by: toDay) != nil)
    }
    
    @Test("movePlanner appends to existing destination")
    func movePlanner_appends_to_destination() throws {
        // Given
        let fromDay = makeDay(0)
        let toDay = makeDay(1)
        let recipeToMove = makeRecipe(name: "Moving")
        let existingRecipe = makeRecipe(name: "Existing")
        
        try viewModel.save(PlannerData(day: fromDay, recipes: [recipeToMove]))
        try viewModel.save(PlannerData(day: toDay, recipes: [existingRecipe]))
        
        // When
        try viewModel.movePlanner(recipeID: recipeToMove.id, from: fromDay, to: toDay)
        
        // Then
        let toResult = viewModel.get(by: toDay)
        #expect(toResult?.recipes.count == 2)
    }
    
    @Test("movePlanner throws when source planner not found")
    func movePlanner_throws_no_source() {
        // Given - no planner exists
        let fromDay = makeDay(0)
        let toDay = makeDay(1)
        
        // When/Then
        #expect(throws: RepositoryError.self) {
            try viewModel.movePlanner(recipeID: UUID(), from: fromDay, to: toDay)
        }
    }
    
    @Test("movePlanner throws when recipe not in source")
    func movePlanner_throws_recipe_not_found() throws {
        // Given
        let fromDay = makeDay(0)
        let toDay = makeDay(1)
        try viewModel.save(PlannerData(day: fromDay, recipes: [makeRecipe()]))
        
        // When/Then - using non-existent recipe ID
        #expect(throws: RepositoryError.self) {
            try viewModel.movePlanner(recipeID: UUID(), from: fromDay, to: toDay)
        }
    }
    
    @Test("movePlanner only moves specified recipe")
    func movePlanner_only_moves_specified() throws {
        // Given
        let fromDay = makeDay(0)
        let toDay = makeDay(1)
        let recipeToMove = makeRecipe(name: "Move Me")
        let recipeToKeep = makeRecipe(name: "Keep Me")
        
        try viewModel.save(PlannerData(day: fromDay, recipes: [recipeToMove, recipeToKeep]))
        
        // When
        try viewModel.movePlanner(recipeID: recipeToMove.id, from: fromDay, to: toDay)
        
        // Then
        let fromResult = viewModel.get(by: fromDay)
        let toResult = viewModel.get(by: toDay)
        
        #expect(fromResult?.recipes.count == 1)
        #expect(fromResult?.recipes.first?.name == "Keep Me")
        #expect(toResult?.recipes.count == 1)
        #expect(toResult?.recipes.first?.name == "Move Me")
    }
    
    @Test("movePlanner updates recipe groups after move")
    func movePlanner_updates_groups() throws {
        // Given
        let fromDay = makeDay(0)
        let toDay = makeDay(1)
        let recipe = makeRecipe(name: "Recipe", mealType: .lunch)
        try viewModel.save(PlannerData(day: fromDay, recipes: [recipe]))
        
        // When
        try viewModel.movePlanner(recipeID: recipe.id, from: fromDay, to: toDay)
        viewModel.fetchRecipeGroups(with: toDay)
        
        // Then
        #expect(!viewModel.recipeGroups.isEmpty)
        #expect(viewModel.recipeGroups.first?.recipes.first?.name == "Recipe")
    }
    
    // MARK: - Integration Tests
    
    @Test("Complete workflow: save, fetch, move, delete")
    func integration_complete_workflow() throws {
        // Given
        let day1 = makeDay(0)
        let day2 = makeDay(1)
        let recipe1 = makeRecipe(name: "Breakfast", mealType: .breakFast)
        let recipe2 = makeRecipe(name: "Lunch", mealType: .lunch)
        
        // 1. Save initial planner
        try viewModel.save(PlannerData(day: day1, recipes: [recipe1, recipe2]))
        
        // 2. Fetch and verify
        viewModel.fetchRecipeGroups(with: day1)
        #expect(viewModel.recipeGroups.count == 2)
        
        // 3. Move one recipe
        try viewModel.movePlanner(recipeID: recipe1.id, from: day1, to: day2)
        
        // 4. Verify after move
        viewModel.fetchRecipeGroups(with: day1)
        #expect(viewModel.recipeGroups.count == 1)
        
        viewModel.fetchRecipeGroups(with: day2)
        #expect(viewModel.recipeGroups.count == 1)
        #expect(viewModel.recipeGroups.first?.mealType == .breakFast)
        
        // 5. Delete planner
        try viewModel.removePlanner(day: day1)
        
        // 6. Verify deletion
        viewModel.fetchRecipeGroups(with: day1)
        #expect(viewModel.recipeGroups.isEmpty)
    }
    
    @Test("Multiple updates preserve data integrity")
    func integration_multiple_updates() throws {
        // Given
        let day = makeDay()
        
        // Save initial
        try viewModel.save(PlannerData(day: day, recipes: [makeRecipe(name: "Version 1")]))
        
        // Update multiple times
        try viewModel.save(PlannerData(day: day, recipes: [makeRecipe(name: "Version 2")]))
        try viewModel.save(PlannerData(day: day, recipes: [makeRecipe(name: "Version 3")]))
        
        // When
        let result = viewModel.get(by: day)
        
        // Then - only latest version should exist
        #expect(result?.recipes.count == 1)
        #expect(result?.recipes.first?.name == "Version 3")
    }
}
