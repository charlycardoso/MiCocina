//
//  Ingredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Foundation

/// Represents an ingredient used in the MiCocina application.
///
/// `Ingredient` is a domain model that represents a single ingredient that can be
/// stored in a user's pantry or used in recipes. The ingredient name is automatically
/// normalized upon initialization to ensure consistent matching across the application.
///
/// - Important: The `quantity` property is provided for future extensibility but
///   is not currently used in the pantry tracking system.
///
/// - Note: Ingredient names are normalized (case-insensitive, diacritics removed)
///   to improve recipe matching accuracy.
///
/// - Example:
/// ```swift
/// let tomato = Ingredient(name: "Tomato")     // Normalized to "tomato"
/// let tomate = Ingredient(name: "Tomate")     // Normalized to "tomate"
/// let cheddar = Ingredient(name: "Chéddar")   // Normalized to "cheddar"
/// ```
struct Ingredient: Identifiable, Equatable, Hashable {
    /// Unique identifier for the ingredient
    let id: UUID
    
    /// Human-readable name of the ingredient (automatically normalized)
    let name: String
    
    /// Quantity of the ingredient
    let quantity: Int

    /// Initializes a new `Ingredient` instance.
    ///
    /// The ingredient name is automatically normalized to ensure consistent
    /// matching throughout the application. Normalization includes:
    /// - Converting to lowercase
    /// - Removing diacritical marks (accents)
    /// - Trimming whitespace
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the ingredient. Defaults to a newly generated UUID.
    ///   - name: The name of the ingredient. Will be normalized automatically.
    ///   - quantity: The quantity you have of the ingredient.
    init(id: UUID = .init(), name: String, quantity: Int = 0) {
        self.id = id
        self.name = name.normalize()
        self.quantity = quantity
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
}
