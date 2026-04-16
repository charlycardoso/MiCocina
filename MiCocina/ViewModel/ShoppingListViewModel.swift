//
//  ShoppingListViewModel.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Foundation
import Observation

/// View model for managing shopping list state and interactions.
///
/// `ShoppingListViewModel` provides the business logic layer between the shopping list
/// view and the data repository. It manages shopping list items, handles user actions,
/// and provides computed properties for the view.
///
/// This view model is observable and will automatically update the view when
/// shopping list items change.
///
/// - Example:
/// ```swift
/// let viewModel = ShoppingListViewModel(repository: repository)
/// viewModel.loadShoppingList()
/// viewModel.toggleBought(item)
/// ```
@Observable
final class ShoppingListViewModel {
    
    // MARK: - Properties
    
    /// The repository for shopping list persistence
    private let repository: ShoppingListRepository
    
    /// All items in the shopping list
    private(set) var items: [ShoppingListItem] = []
    
    /// Items that haven't been purchased yet
    var unboughtItems: [ShoppingListItem] {
        items.filter { !$0.isBought }.sorted { $0.ingredient.name < $1.ingredient.name }
    }
    
    /// Items that have been purchased
    var boughtItems: [ShoppingListItem] {
        items.filter { $0.isBought }.sorted { $0.ingredient.name < $1.ingredient.name }
    }
    
    /// Whether the shopping list is empty
    var isEmpty: Bool {
        items.isEmpty
    }
    
    // MARK: - Initialization
    
    /// Initializes a new shopping list view model.
    ///
    /// - Parameter repository: The repository for shopping list persistence
    init(repository: ShoppingListRepository) {
        self.repository = repository
    }
    
    // MARK: - Actions
    
    /// Loads all shopping list items from the repository.
    func loadShoppingList() {
        let shoppingList = repository.getShoppingList()
        items = Array(shoppingList)
    }
    
    /// Toggles the bought state of an item.
    ///
    /// - Parameter item: The item to toggle
    func toggleBought(_ item: ShoppingListItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        let newBoughtState = !item.isBought
        // Optimistic update: mutate in-place so SwiftUI sees a clean, minimal diff
        items[index].isBought = newBoughtState
        do {
            try repository.markAsBought(item, bought: newBoughtState)
        } catch {
            // Revert on failure
            items[index].isBought = item.isBought
            print("Error toggling bought state: \(error)")
        }
    }
    
    /// Removes an item from the shopping list.
    ///
    /// - Parameter item: The item to remove
    func removeItem(_ item: ShoppingListItem) {
        do {
            try repository.remove(item)
            loadShoppingList()
        } catch {
            print("Error removing item: \(error)")
        }
    }
    
    /// Removes multiple items from the shopping list.
    ///
    /// - Parameter items: The items to remove
    func removeItems(_ items: [ShoppingListItem]) {
        for item in items {
            do {
                try repository.remove(item)
            } catch {
                print("Error removing item \(item.ingredient.name): \(error)")
            }
        }
        loadShoppingList()
    }
    
    /// Clears all items from the shopping list.
    func clearList() {
        do {
            try repository.clear()
            loadShoppingList()
        } catch {
            print("Error clearing shopping list: \(error)")
        }
    }
    
    /// Adds an ingredient to the shopping list.
    ///
    /// This method is intended to be called from other modules when users
    /// want to add ingredients to the shopping list.
    ///
    /// - Parameter ingredient: The ingredient to add
    func addIngredient(_ ingredient: Ingredient) {
        do {
            try repository.add(ingredient)
            loadShoppingList()
        } catch {
            print("Error adding ingredient to shopping list: \(error)")
        }
    }
    
    /// Adds a shopping list item directly without adding to pantry.
    ///
    /// - Parameter item: The shopping list item to add
    func addItem(_ item: ShoppingListItem) {
        do {
            try repository.addItem(item)
            loadShoppingList()
        } catch {
            print("Error adding item to shopping list: \(error)")
        }
    }
}
