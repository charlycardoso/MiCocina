//
//  RecipeIngredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 17/03/26.
//

import Foundation

/// Represents an ingredient needed for a recipe.
///
/// `RecipeIngredient` is a domain model that specifies what ingredients a recipe requires.
/// It stores only the ingredient name and metadata about its role in the recipe.
///
/// **Architecture Note**: This is separate from `Ingredient` (pantry items).
/// - `RecipeIngredient`: What a recipe **needs** (just names)
/// - `Ingredient`: What you **have** (names + quantities in your pantry)
///
/// This separation ensures that adding recipes doesn't affect your pantry inventory.
///
/// - Example:
/// ```swift
/// let requiredWater = RecipeIngredient(ingredientName: "water", isRequired: true)
/// let optionalSugar = RecipeIngredient(ingredientName: "sugar", isRequired: false)
/// ```
struct RecipeIngredient: Identifiable, Hashable {
    /// Unique identifier for this recipe-ingredient association
    let id: UUID
    
    /// The name of the ingredient needed for this recipe
    ///
    /// This is just a string reference, not tied to pantry inventory.
    /// The name is normalized (lowercase, trimmed) for consistent matching.
    let ingredientName: String
    
    /// Whether this ingredient is required for the recipe
    ///
    /// If `false`, the recipe can be prepared without this ingredient,
    /// though the result may differ from the original recipe.
    let isRequired: Bool

    /// Initializes a new `RecipeIngredient` instance.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this association. Defaults to a newly generated UUID.
    ///   - ingredientName: The name of the ingredient needed.
    ///   - isRequired: Whether this ingredient is required. Defaults to `true`.
    init(id: UUID = .init(), ingredientName: String, isRequired: Bool = true) {
        self.id = id
        self.ingredientName = ingredientName.normalize()
        self.isRequired = isRequired
    }
    
    /// Convenience initializer for backwards compatibility during migration.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this association. Defaults to a newly generated UUID.
    ///   - ingredient: The ingredient to extract the name from.
    ///   - isRequired: Whether this ingredient is required. Defaults to `true`.
    @available(*, deprecated, message: "Use init(ingredientName:isRequired:) instead")
    init(id: UUID = .init(), ingredient: Ingredient, isRequired: Bool = true) {
        self.id = id
        self.ingredientName = ingredient.name
        self.isRequired = isRequired
    }
}
