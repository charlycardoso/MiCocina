//
//  SDRecipeIngredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import SwiftData
import Foundation

/// A SwiftData persistence model representing an ingredient needed for a recipe.
///
/// `SDRecipeIngredient` stores the ingredient name directly, without referencing
/// the pantry's `SDIngredient` model. This ensures proper separation between:
/// - Recipe ingredients (what recipes need)
/// - Pantry ingredients (what you actually have)
///
/// **Architecture**: Recipe ingredients are just names and metadata.
/// The RecipeMatcher compares these names against pantry ingredient names.
///
/// - Important: This model is an implementation detail of the data layer. Use the domain
///   `RecipeIngredient` model for all application logic. Use `DomainMapper` to convert between layers.
@Model
final class SDRecipeIngredient {
    /// Unique identifier for this recipe-ingredient association (database primary key)
    @Attribute(.unique)
    var id: UUID
    
    /// The recipe this ingredient belongs to
    var recipe: SDRecipe
    
    /// The name of the ingredient needed for this recipe
    var ingredientName: String
    
    /// Optional quantity value (reserved for future use, e.g., "2 cups")
    var quantity: String?
    
    /// Whether this ingredient is required for the recipe
    var isRequired: Bool
    
    /// Initializes a new storage recipe-ingredient association.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a newly generated UUID.
    ///   - recipe: The recipe this ingredient is associated with
    ///   - ingredientName: The name of the ingredient needed
    ///   - quantity: Optional quantity of the ingredient (for future use). Defaults to `nil`.
    ///   - isRequired: Whether the ingredient is required. Defaults to `true`.
    init(
        id: UUID = UUID(),
        recipe: SDRecipe,
        ingredientName: String,
        quantity: String? = nil,
        isRequired: Bool
    ) {
        self.id = id
        self.recipe = recipe
        self.ingredientName = ingredientName
        self.quantity = quantity
        self.isRequired = isRequired
    }
}
