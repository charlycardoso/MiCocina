//
//  PlannerViewModel.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 10/04/26.
//

import Foundation
import Combine
import SwiftData

final class PlannerViewModel: ObservableObject {
    let context: ModelContext
    var repo: PlannerDomainRepository {
        return .init(repo: SDPlannerDomainRepository(context: context))
    }
    @Published var recipeGroups = [RecipeGroup]()
    @Published var isLoading: Bool = false

    init(context: ModelContext) {
        self.context = context
    }

    /// Fetches and populates recipe groups for the specified date.
    ///
    /// Retrieves planner data for the given date and transforms it into
    /// grouped recipes suitable for display. If no planner data exists for
    /// the date, the recipe groups are cleared.
    ///
    /// - Parameter date: The date to fetch recipes for
    func fetchRecipeGroups(with date: Date) {
        isLoading = recipeGroups.isEmpty
        Task { @MainActor [weak self] in
            guard let self else { return }
            let calendar = Calendar.current
            let normalizedDate = calendar.startOfDay(for: date)
            let descriptor = FetchDescriptor<SDPlannerData>(
                predicate: #Predicate<SDPlannerData> { $0.day == normalizedDate }
            )
            do {
                let planners = try self.context.fetch(descriptor)
                if let planner = planners.first {
                    let plannerData = DomainMapper.toDomain(planner: planner)
                    let pantry = SDPantryProtocolRepository(context: self.context).getPantry()
                    let mapper = RecipeMapper()
                    let matcher = RecipeMatcher()
                    let mapped = plannerData.recipes.map { mapper.map($0, pantry: pantry, matcher: matcher) }
                    self.recipeGroups = RecipeGrouper.group(mapped)
                } else {
                    self.recipeGroups = []
                }
            } catch {
                print("Error fetching planner data: \(error)")
                self.recipeGroups = []
            }
            self.isLoading = false
        }
    }

    func getRecipes(by mealType: MealType) -> [RecipeViewData] {
        let recipeProtocol = SDRecipeProtocolRepository(context: context)
        let pantryProtocol = SDPantryProtocolRepository(context: context)
        let matcher = RecipeUseCasesImpl(RecipeProtocolRepository: recipeProtocol, PantryProtocolRepository: pantryProtocol, matcher: .init())
        let recipes = matcher.getAllRecipes()
        let recipesForMealType = recipes
            .first(where: { $0.mealType == mealType })?
            .recipes ?? []
        return recipesForMealType
    }
}

extension PlannerViewModel: PlannerProtocolRepository {
    func get(by day: Date) -> PlannerData? {
        repo.get(by: day)
    }
    
    func save(_ planner: PlannerData) throws {
        try repo.save(planner)
    }
    
    func removePlanner(day: Date) throws {
        try repo.removePlanner(day: day)
    }
    
    func movePlanner(recipeID: UUID, from date: Date, to: Date) throws {
        try repo.movePlanner(recipeID: recipeID, from: date, to: to)
    }
}

extension PlannerViewModel {
    /// Generates mock recipe groups for SwiftUI previews.
    ///
    /// Creates sample data covering multiple meal types with varied
    /// recipe states (favorite, cookable, missing ingredients) for
    /// realistic preview rendering.
    ///
    /// - Returns: Array of recipe groups with sample data
    static func mockForPreview() -> [RecipeGroup] {
        [
            RecipeGroup(mealType: .breakFast, recipes: [
                .init(id: UUID(), name: "Avocado Toast", mealType: .breakFast, isFavorite: true, canCook: true, missingCount: 0),
                .init(id: UUID(), name: "Scrambled Eggs", mealType: .breakFast, isFavorite: true, canCook: true, missingCount: 0),
                .init(id: UUID(), name: "Pancakes", mealType: .breakFast, isFavorite: false, canCook: true, missingCount: 1),
                .init(id: UUID(), name: "Fruit Smoothie", mealType: .breakFast, isFavorite: false, canCook: false, missingCount: 3)
            ]),
            RecipeGroup(mealType: .lunch, recipes: [
                .init(id: UUID(), name: "Caesar Salad", mealType: .lunch, isFavorite: true, canCook: true, missingCount: 0),
                .init(id: UUID(), name: "Chicken Sandwich", mealType: .lunch, isFavorite: false, canCook: true, missingCount: 2),
                .init(id: UUID(), name: "Tomato Soup", mealType: .lunch, isFavorite: false, canCook: false, missingCount: 4)
            ]),
            RecipeGroup(mealType: .dinner, recipes: [
                .init(id: UUID(), name: "Pasta Carbonara", mealType: .dinner, isFavorite: true, canCook: true, missingCount: 0),
                .init(id: UUID(), name: "Grilled Salmon", mealType: .dinner, isFavorite: true, canCook: true, missingCount: 1),
                .init(id: UUID(), name: "Beef Tacos", mealType: .dinner, isFavorite: false, canCook: true, missingCount: 2),
                .init(id: UUID(), name: "Vegetable Stir Fry", mealType: .dinner, isFavorite: false, canCook: false, missingCount: 5)
            ])
        ]
    }
}
