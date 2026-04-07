//
//  RecipeIngredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 17/03/26.
//

import Foundation

/// Represents the association between a recipe and an ingredient.
///
/// `RecipeIngredient` is a domain model that connects a recipe to a specific ingredient,
/// along with metadata about that ingredient's role in the recipe. This model enables
/// recipes to include the same ingredient multiple times with different requirements.
///
/// - Note: This model allows tracking whether an ingredient is required or optional
///   in a recipe, which is useful for flexible recipe matching.
///
/// - Example:
/// ```swift
/// let water = Ingredient(name: "water")
/// let sugar = Ingredient(name: "sugar")
/// let requiredWater = RecipeIngredient(ingredient: water, isRequired: true)
/// let optionalSugar = RecipeIngredient(ingredient: sugar, isRequired: false)
/// ```
struct RecipeIngredient: Identifiable, Hashable {
    /// Unique identifier for this recipe-ingredient association
    let id: UUID
    
    /// The ingredient associated with this recipe
    let ingredient: Ingredient
    
    /// Whether this ingredient is required for the recipe
    ///
    /// If `false`, the recipe can be prepared without this ingredient,
    /// though the result may differ from the original recipe.
    let isRequired: Bool

    /// Initializes a new `RecipeIngredient` instance.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this association. Defaults to a newly generated UUID.
    ///   - ingredient: The ingredient associated with the recipe.
    ///   - isRequired: Whether this ingredient is required. Defaults to `true`.
    init(id: UUID = .init(), ingredient: Ingredient, isRequired: Bool = true) {
        self.id = id
        self.ingredient = ingredient
        self.isRequired = isRequired
    }
}
