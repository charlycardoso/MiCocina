//
//  ShoppingListRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Foundation

/// Protocol defining operations for managing the shopping list.
///
/// `ShoppingListRepository` provides an abstraction for shopping list persistence,
/// allowing different implementations (in-memory, SwiftData, etc.).
///
/// - Note: This follows the repository pattern used throughout MiCocina
protocol ShoppingListRepository {
    /// Retrieves all items in the shopping list.
    ///
    /// - Returns: A set of all shopping list items
    func getShoppingList() -> Set<ShoppingListItem>
    
    /// Adds an ingredient to the shopping list.
    ///
    /// If the ingredient already exists in the shopping list, this operation
    /// does nothing to avoid duplicates.
    ///
    /// - Parameter ingredient: The ingredient to add
    /// - Throws: `RepositoryError` if the operation fails
    func add(_ ingredient: Ingredient) throws
    
    /// Removes an item from the shopping list.
    ///
    /// - Parameter item: The shopping list item to remove
    /// - Throws: `RepositoryError` if the operation fails
    func remove(_ item: ShoppingListItem) throws
    
    /// Marks an item as bought or unbought.
    ///
    /// - Parameters:
    ///   - item: The shopping list item to update
    ///   - bought: The new bought state
    /// - Throws: `RepositoryError` if the operation fails
    func markAsBought(_ item: ShoppingListItem, bought: Bool) throws
    
    /// Clears all items from the shopping list.
    ///
    /// - Throws: `RepositoryError` if the operation fails
    func clear() throws
    
    /// Checks whether an ingredient exists in the shopping list.
    ///
    /// - Parameter ingredient: The ingredient to check
    /// - Returns: `true` if the ingredient is in the shopping list
    func exists(_ ingredient: Ingredient) -> Bool
}
