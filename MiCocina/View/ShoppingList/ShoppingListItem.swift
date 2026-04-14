//
//  ShoppingListItem.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Foundation

/// Represents an item in the shopping list.
///
/// `ShoppingListItem` wraps an ingredient with additional shopping-specific state,
/// tracking whether the item has been purchased.
///
/// - Note: Shopping list items are stored as a set to avoid duplicates
///
/// - Example:
/// ```swift
/// let item = ShoppingListItem(ingredient: Ingredient(name: "tomato"))
/// item.markAsBought()
/// ```
struct ShoppingListItem: Identifiable, Equatable, Hashable, Sendable {
    /// Unique identifier for the shopping list item
    let id: UUID
    
    /// The ingredient to purchase
    let ingredient: Ingredient
    
    /// Whether the item has been purchased
    var isBought: Bool
    
    /// Initializes a new shopping list item.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a newly generated UUID.
    ///   - ingredient: The ingredient to add to the shopping list
    ///   - isBought: Whether the item has been purchased. Defaults to false.
    init(id: UUID = .init(), ingredient: Ingredient, isBought: Bool = false) {
        self.id = id
        self.ingredient = ingredient
        self.isBought = isBought
    }
    
    /// Creates a copy of this item with the bought state updated
    ///
    /// - Parameter bought: The new bought state
    /// - Returns: A new shopping list item with updated state
    func withBoughtState(_ bought: Bool) -> ShoppingListItem {
        ShoppingListItem(id: id, ingredient: ingredient, isBought: bought)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
