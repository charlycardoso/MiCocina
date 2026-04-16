//
//  SDShoppingListRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/04/26.
//

import SwiftData
import Foundation

/// A concrete implementation of `ShoppingListRepository` using SwiftData for persistence.
///
/// `SDShoppingListRepository` provides persistent storage for shopping list items using
/// Apple's SwiftData framework. It manages CRUD operations for shopping list items in the
/// local database.
///
/// This implementation handles:
/// - Fetching all shopping list items
/// - Adding new ingredients to the shopping list
/// - Removing items from the shopping list
/// - Marking items as bought/unbought
/// - Clearing the shopping list
/// - Checking ingredient existence
///
/// - Important: All operations use the provided `ModelContext` for persistence.
///   The caller is responsible for managing the context lifecycle.
///
/// - Example:
/// ```swift
/// let repository = SDShoppingListRepository(context: modelContext)
/// let items = repository.getShoppingList()
/// try repository.add(Ingredient(name: "tomato"))
/// ```
final class SDShoppingListRepository: ShoppingListRepository {
    /// The SwiftData model context used for persistence operations
    let context: ModelContext

    /// Initializes a new shopping list repository with a SwiftData model context.
    ///
    /// - Parameter context: The `ModelContext` instance for database operations
    init(context: ModelContext) {
        self.context = context
    }

    /// Retrieves all items in the shopping list.
    ///
    /// Fetches all `SDShoppingListItem` records from the database and maps them to
    /// domain `ShoppingListItem` models for use in the application.
    ///
    /// - Returns: A set of all shopping list items. Returns empty set if fetch fails.
    func getShoppingList() -> Set<ShoppingListItem> {
        let descriptor = FetchDescriptor<SDShoppingListItem>()
        do {
            let items = try context.fetch(descriptor)
            let retrievedItems = items.map { DomainMapper.toDomain(shoppingListItem: $0) }
            var shoppingList: Set<ShoppingListItem> = []
            retrievedItems.forEach { shoppingList.insert($0) }
            return shoppingList
        } catch {
            let repositoryError = RepositoryError.fetchFailed(operation: "getShoppingList", underlyingError: error)
            print("Error in getShoppingList(): \(repositoryError.debugDescription)")
            return .init()
        }
    }

    /// Adds an ingredient to the shopping list.
    ///
    /// If an ingredient with the same ID already exists in the shopping list,
    /// the operation does nothing to avoid duplicates.
    ///
    /// - Parameter ingredient: The ingredient to add
    /// - Throws: `RepositoryError` if the operation fails
    func add(_ ingredient: Ingredient) throws {
        let ingredientUUID: UUID = ingredient.id
        
        // Check if this ingredient is already in the shopping list
        let shoppingListDescriptor = FetchDescriptor<SDShoppingListItem>(
            predicate: #Predicate { $0.ingredient.id == ingredientUUID }
        )
        
        do {
            let existingItem = try context.fetch(shoppingListDescriptor).first
            if existingItem != nil {
                // Already in shopping list, do nothing
                return
            }
        } catch {
            throw RepositoryError.fetchFailed(operation: "add - checking existing shopping list item", underlyingError: error)
        }

        // Get or create the ingredient in storage
        let sdIngredient = StorageMapper.toStorage(with: ingredient, context: context)
        
        // Create the shopping list item
        let newItem = SDShoppingListItem(
            id: UUID(),
            ingredient: sdIngredient,
            isBought: false
        )
        
        context.insert(newItem)
        
        do {
            try context.save()
        } catch {
            throw RepositoryError.saveFailed(operation: "add new shopping list item for \(ingredient.name)", underlyingError: error)
        }
    }
    
    /// Adds a shopping list item directly without creating a pantry entry.
    ///
    /// This allows adding items to the shopping list without automatically
    /// adding them to the pantry.
    ///
    /// - Parameter item: The shopping list item to add
    /// - Throws: `RepositoryError` if the operation fails
    func addItem(_ item: ShoppingListItem) throws {
        // Check if already exists
        let itemName = item.ingredient.name
        let shoppingListDescriptor = FetchDescriptor<SDShoppingListItem>(
            predicate: #Predicate { $0.ingredient.name == itemName }
        )
        
        do {
            let existingItem = try context.fetch(shoppingListDescriptor).first
            if existingItem != nil {
                // Already in shopping list, do nothing
                return
            }
        } catch {
            throw RepositoryError.fetchFailed(operation: "addItem - checking existing", underlyingError: error)
        }
        
        // Reuse existing ingredient if available, otherwise create it
        let ingredientID = item.ingredient.id
        let ingredientDescriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientID }
        )

        let sdIngredient: SDIngredient
        if let existingIngredient = try context.fetch(ingredientDescriptor).first {
            sdIngredient = existingIngredient
        } else {
            sdIngredient = SDIngredient(
                id: item.ingredient.id,
                name: item.ingredient.name,
                quantity: item.ingredient.quantity == 0 ? 1 : item.ingredient.quantity
            )
            context.insert(sdIngredient)
        }
        
        // Create the shopping list item
        let newItem = SDShoppingListItem(
            id: item.id,
            ingredient: sdIngredient,
            isBought: item.isBought
        )
        
        context.insert(newItem)
        
        do {
            try context.save()
        } catch {
            throw RepositoryError.saveFailed(operation: "addItem \(item.ingredient.name)", underlyingError: error)
        }
    }

    /// Removes an item from the shopping list.
    ///
    /// - Parameter item: The shopping list item to remove
    /// - Throws: `RepositoryError` if the operation fails
    ///
    /// - Note: If the item doesn't exist, the operation completes silently
    func remove(_ item: ShoppingListItem) throws {
        let itemUUID: UUID = item.id
        let descriptor = FetchDescriptor<SDShoppingListItem>(
            predicate: #Predicate { $0.id == itemUUID }
        )
        
        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch let error where error is NSError {
            if (error as NSError).domain.contains("delete") || (error as NSError).localizedDescription.lowercased().contains("delete") {
                throw RepositoryError.deleteFailed(operation: "remove shopping list item \(item.ingredient.name)", underlyingError: error)
            } else {
                throw RepositoryError.fetchFailed(operation: "remove - finding shopping list item to delete", underlyingError: error)
            }
        } catch {
            throw RepositoryError.fetchFailed(operation: "remove - finding shopping list item to delete", underlyingError: error)
        }
    }

    /// Marks a shopping list item as bought or unbought.
    ///
    /// - Parameters:
    ///   - item: The shopping list item to update
    ///   - bought: The new bought state
    /// - Throws: `RepositoryError` if the operation fails
    func markAsBought(_ item: ShoppingListItem, bought: Bool) throws {
        let itemUUID: UUID = item.id
        let descriptor = FetchDescriptor<SDShoppingListItem>(
            predicate: #Predicate { $0.id == itemUUID }
        )
        
        let existing: SDShoppingListItem?
        do {
            existing = try context.fetch(descriptor).first
        } catch {
            throw RepositoryError.fetchFailed(operation: "markAsBought - finding shopping list item", underlyingError: error)
        }
        
        guard let existing = existing else {
            // Silently succeed if item doesn't exist
            return
        }
        
        existing.isBought = bought
        do {
            try context.save()
        } catch {
            throw RepositoryError.updateFailed(operation: "mark shopping list item \(item.ingredient.name) as \(bought ? "bought" : "unbought")", underlyingError: error)
        }
    }

    /// Clears all items from the shopping list.
    ///
    /// Removes every item from the database, resulting in an empty shopping list.
    ///
    /// - Throws: `RepositoryError` if the operation fails
    ///
    /// - Warning: This operation is not easily reversible
    func clear() throws {
        let descriptor = FetchDescriptor<SDShoppingListItem>()
        do {
            let allItems = try context.fetch(descriptor)
            allItems.forEach { context.delete($0) }
            try context.save()
        } catch let error where error is NSError && ((error as NSError).domain.contains("delete") || (error as NSError).localizedDescription.lowercased().contains("delete")) {
            throw RepositoryError.deleteFailed(operation: "clear all shopping list items", underlyingError: error)
        } catch {
            throw RepositoryError.fetchFailed(operation: "clear - fetching shopping list items to delete", underlyingError: error)
        }
    }

    /// Checks whether an ingredient exists in the shopping list.
    ///
    /// - Parameter ingredient: The ingredient to check
    /// - Returns: `true` if the ingredient is in the shopping list
    func exists(_ ingredient: Ingredient) -> Bool {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDShoppingListItem>(
            predicate: #Predicate { $0.ingredient.id == ingredientUUID }
        )
        do {
            let existing = try context.fetch(descriptor).first
            return existing != nil
        } catch {
            let repositoryError = RepositoryError.fetchFailed(operation: "exists - checking ingredient \(ingredient.name)", underlyingError: error)
            print("Error in exists(): \(repositoryError.debugDescription)")
            return false
        }
    }
}
