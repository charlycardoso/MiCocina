//
//  SDIngredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import SwiftData
import Foundation

/// A SwiftData persistence model representing an ingredient.
///
/// `SDIngredient` serves a dual purpose:
/// 1. **Recipe ingredients**: Just the name (quantity = 0)
/// 2. **Pantry ingredients**: Name + quantity (quantity > 0)
///
/// The distinction is made by quantity:
/// - `quantity == 0`: Recipe ingredient reference only
/// - `quantity > 0`: Pantry item
///
/// **Architecture Note**: Pantry queries filter for `quantity > 0`.
///
/// - Important: This model is an implementation detail and should not be used directly
///   outside the data layer. Use the domain `Ingredient` model instead.
///
/// - Note: The `id` attribute is marked as unique to ensure each ingredient can only
///   exist once in the database by its UUID.
@Model
final class SDIngredient {
    /// Unique identifier for the ingredient (database primary key)
    @Attribute(.unique)
    var id: UUID
    
    /// Human-readable name of the ingredient
    var name: String
    
    /// Quantity of the ingredient
    /// - 0: Recipe ingredient reference only (not in pantry)
    /// - > 0: Pantry item with actual quantity
    var quantity: Int

    /// Initializes a new storage ingredient model.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a newly generated UUID.
    ///   - name: The name of the ingredient
    ///   - quantity: The quantity. Defaults to 0 (recipe reference only).
    init(id: UUID = UUID(), name: String, quantity: Int = 0) {
        self.id = id
        self.name = name
        self.quantity = quantity
    }
}
