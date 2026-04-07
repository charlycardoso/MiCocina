//
//  RecipeViewData.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

import Foundation

/// A data transfer object (DTO) optimized for displaying recipe information in the UI.
///
/// `RecipeViewData` is designed specifically for presentation purposes and contains
/// pre-computed properties that are useful for the user interface, such as whether
/// the recipe can be cooked with available pantry items and how many ingredients are missing.
///
/// This model bridges the gap between the domain `Recipe` model and the UI layer,
/// allowing the view to directly access computed values without performing additional
/// calculations.
///
/// - Note: This model is immutable and should not be modified after creation.
///
/// - Example:
/// ```swift
/// let viewData = RecipeViewData(
///     id: UUID(),
///     name: "Pasta Carbonara",
///     mealType: .lunch,
///     isFavorite: true,
///     canCook: true,
///     missingCount: 0
/// )
/// ```
struct RecipeViewData: Equatable {
    /// Unique identifier for the recipe
    let id: UUID
    
    /// Human-readable name of the recipe
    let name: String
    
    /// The meal type classification of the recipe
    let mealType: MealType
    
    /// Whether the recipe is marked as a user favorite
    let isFavorite: Bool
    
    /// Whether the recipe can be cooked with the current pantry items
    ///
    /// A recipe is cookable if it has 3 or fewer missing ingredients.
    let canCook: Bool
    
    /// The number of ingredients missing from the pantry
    ///
    /// This value represents how many ingredients in the recipe are not currently
    /// available in the user's pantry.
    let missingCount: Int
}
