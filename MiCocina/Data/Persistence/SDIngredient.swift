//
//  SDIngredient.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import SwiftData
import Foundation

/// A SwiftData persistence model representing an ingredient in the pantry.
///
/// `SDIngredient` is the storage layer representation of an `Ingredient` domain model.
/// It is used exclusively for persistence using Apple's SwiftData framework.
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

    /// Initializes a new storage ingredient model.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a newly generated UUID.
    ///   - name: The name of the ingredient
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
