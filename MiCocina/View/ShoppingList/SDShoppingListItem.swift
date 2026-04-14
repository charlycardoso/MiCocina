//
//  SDShoppingListItem.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Foundation
import SwiftData

/// SwiftData persistence model for shopping list items.
///
/// `SDShoppingListItem` represents a shopping list item in the database,
/// linking an ingredient with purchase tracking state.
///
/// - Important: This is a storage layer model. Use `ShoppingListItem` for domain logic.
@Model
final class SDShoppingListItem {
    /// Unique identifier
    var id: UUID
    
    /// The ingredient to purchase
    var ingredient: SDIngredient
    
    /// Whether the item has been purchased
    var isBought: Bool
    
    /// Initializes a new shopping list item.
    ///
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - ingredient: The ingredient storage model
    ///   - isBought: Purchase status
    init(id: UUID = .init(), ingredient: SDIngredient, isBought: Bool = false) {
        self.id = id
        self.ingredient = ingredient
        self.isBought = isBought
    }
}
