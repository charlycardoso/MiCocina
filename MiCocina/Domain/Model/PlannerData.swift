//
//  PlannerData.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 10/04/26.
//

import Foundation

/// A domain model representing a meal plan for a single day.
///
/// `PlannerData` associates a calendar date with a list of recipes planned for that day.
/// It is the central model of the Planner module, used across the domain and presentation layers.
///
/// - Note: The `day` stored in persistence is always normalized to the start of the day
///   (midnight) by the repository layer. Consumers should not assume sub-day precision.
///
/// - Example:
/// ```swift
/// let plan = PlannerData(day: Date(), recipes: [pastaRecipe, saladRecipe])
/// print(plan.groupedRecipes) // grouped by meal type
/// ```
struct PlannerData: Identifiable {

    /// Unique identifier for this planner entry.
    let id: UUID

    /// The calendar day this plan belongs to.
    let day: Date

    /// The recipes planned for this day.
    let recipes: [Recipe]

    /// Creates a new planner entry.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a newly generated UUID.
    ///   - day: The calendar day for this plan.
    ///   - recipes: The recipes planned for this day.
    init(id: UUID = .init(), day: Date, recipes: [Recipe]) {
        self.id = id
        self.day = day
        self.recipes = recipes
    }

    /// The planned recipes grouped by meal type and sorted for display.
    ///
    /// Uses `RecipeGrouper` to organise the recipes, applying pantry-matching
    /// with an empty pantry. This is suitable for displaying a read-only daily plan
    /// without pantry context.
    var groupedRecipes: [RecipeGroup] {
        RecipeGrouper.group(recipes.map { RecipeMapper().map($0, pantry: [], matcher: .init()) })
    }
}
