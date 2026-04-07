//
//  SDRecipe.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import SwiftData
import Foundation

/// A SwiftData persistence model representing a recipe in the database.
///
/// `SDRecipe` is the storage layer representation of the domain `Recipe` model.
/// It manages relationships with `SDRecipeIngredient` and persists recipe metadata
/// using Apple's SwiftData framework.
///
/// - Important: This model is an implementation detail of the data layer. Use the domain
///   `Recipe` model for all application logic. Use `DomainMapper` to convert between layers.
///
/// - Note: The ingredients relationship uses cascade delete rules, ensuring that
///   deleting a recipe automatically deletes its associated recipe-ingredient entries.
@Model
final class SDRecipe {
    /// Unique identifier for the recipe (database primary key)
    @Attribute(.unique)
    var id: UUID

    /// Human-readable name of the recipe
    var name: String
    
    /// The meal type of the recipe (stored as a string)
    var mealType: String
    
    /// Whether the recipe is marked as a user favorite
    var isFavorite: Bool

    /// The ingredients in this recipe (with cascade delete on recipe deletion)
    @Relationship(deleteRule: .cascade, inverse: \SDRecipeIngredient.recipe)
    var ingredients: [SDRecipeIngredient] = []

    /// Initializes a new storage recipe model.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a newly generated UUID.
    ///   - name: The name of the recipe
    ///   - mealType: The meal type as a string (e.g., "breakfast", "lunch")
    ///   - isFavorite: Whether the recipe is a user favorite. Defaults to `false`.
    init(id: UUID = UUID(), name: String, mealType: String, isFavorite: Bool) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.isFavorite = isFavorite
    }
}
