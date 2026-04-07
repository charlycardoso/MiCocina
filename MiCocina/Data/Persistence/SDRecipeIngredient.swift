//
//  SDRecipeIngredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import SwiftData
import Foundation

/// A SwiftData persistence model representing the association between a recipe and an ingredient.
///
/// `SDRecipeIngredient` is a join model that represents the many-to-many relationship
/// between recipes and ingredients. It stores metadata about each ingredient's role
/// in a specific recipe (required/optional) and reserved properties for future use (quantity).
///
/// - Important: This model is an implementation detail of the data layer. Use the domain
///   `RecipeIngredient` model for all application logic. Use `DomainMapper` to convert between layers.
///
/// - Note: Quantity is currently unused but reserved for future enhancements
///   like "add 2 tablespoons of salt" instead of just "salt".
@Model
final class SDRecipeIngredient {
    /// Unique identifier for this recipe-ingredient association (database primary key)
    @Attribute(.unique)
    var id: UUID
    
    /// The recipe this ingredient belongs to
    var recipe: SDRecipe
    
    /// The ingredient associated with this recipe
    var ingredient: SDIngredient
    
    /// Optional quantity value (reserved for future use)
    var quantity: Double?
    
    /// Whether this ingredient is required for the recipe
    var isRequired: Bool
    
    /// Initializes a new storage recipe-ingredient association.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a newly generated UUID.
    ///   - recipe: The recipe this ingredient is associated with
    ///   - ingredient: The ingredient associated with the recipe
    ///   - quantity: Optional quantity of the ingredient (for future use). Defaults to `nil`.
    ///   - isRequired: Whether the ingredient is required. Defaults to `true`.
    init(
        id: UUID = UUID(),
        recipe: SDRecipe,
        ingredient: SDIngredient,
        quantity: Double? = nil,
        isRequired: Bool
    ) {
        self.id = id
        self.recipe = recipe
        self.ingredient = ingredient
        self.quantity = quantity
        self.isRequired = isRequired
    }
}
