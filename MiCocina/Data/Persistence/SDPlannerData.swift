//
//  SDPlannerData.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 10/04/26.
//

import Foundation
import SwiftData

/// A SwiftData persistence model representing a daily meal plan.
///
/// `SDPlannerData` is the storage layer counterpart of the domain `PlannerData` model.
/// Each instance represents the set of recipes planned for a specific calendar day.
///
/// - Important: This model is an implementation detail of the data layer. Use the domain
///   `PlannerData` model for all application logic. Use `DomainMapper` and `StorageMapper`
///   to convert between layers.
///
/// - Note: The `day` property is always stored as the start of the day (midnight) to enable
///   reliable date-equality lookups via SwiftData predicates.
@Model
final class SDPlannerData {

    /// Unique identifier for this planner entry.
    @Attribute
    var id: UUID

    /// The calendar day this plan belongs to, normalised to midnight.
    var day: Date

    /// The recipes planned for this day.
    @Relationship
    var recipes: [SDRecipe]

    /// Creates a new persistence planner entry.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a newly generated UUID.
    ///   - day: The calendar day for this plan.
    ///   - recipes: The `SDRecipe` objects planned for this day.
    init(id: UUID = .init(), day: Date, recipes: [SDRecipe]) {
        self.id = id
        self.day = day
        self.recipes = recipes
    }
}
