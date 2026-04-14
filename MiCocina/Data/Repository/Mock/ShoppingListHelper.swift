//
//  ShoppingListHelper.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/04/26.
//

import SwiftData
import Foundation

/// Helper class for adding ingredients to the shopping list from other modules.
///
/// `ShoppingListHelper` provides a simple interface for other parts of the app
/// to add ingredients to the shopping list without needing to manage repositories
/// directly.
///
/// - Example:
/// ```swift
/// // From a recipe view or pantry view
/// ShoppingListHelper.addToShoppingList(ingredient, context: modelContext)
/// ```
final class ShoppingListHelper {
    
    /// Adds an ingredient to the shopping list.
    ///
    /// This is a convenience method that other modules can call to add ingredients
    /// to the shopping list. It handles repository creation and error handling.
    ///
    /// - Parameters:
    ///   - ingredient: The ingredient to add to the shopping list
    ///   - context: The SwiftData model context
    ///
    /// - Returns: `true` if the ingredient was added successfully, `false` otherwise
    @discardableResult
    static func addToShoppingList(_ ingredient: Ingredient, context: ModelContext) -> Bool {
        let repository = SDShoppingListRepository(context: context)
        
        do {
            try repository.add(ingredient)
            return true
        } catch {
            print("Error adding ingredient to shopping list: \(error)")
            return false
        }
    }
    
    /// Adds multiple ingredients to the shopping list.
    ///
    /// - Parameters:
    ///   - ingredients: The ingredients to add to the shopping list
    ///   - context: The SwiftData model context
    ///
    /// - Returns: The number of ingredients successfully added
    @discardableResult
    static func addToShoppingList(_ ingredients: [Ingredient], context: ModelContext) -> Int {
        let repository = SDShoppingListRepository(context: context)
        var successCount = 0
        
        for ingredient in ingredients {
            do {
                try repository.add(ingredient)
                successCount += 1
            } catch {
                print("Error adding ingredient \(ingredient.name) to shopping list: \(error)")
            }
        }
        
        return successCount
    }
    
    /// Checks if an ingredient is already in the shopping list.
    ///
    /// - Parameters:
    ///   - ingredient: The ingredient to check
    ///   - context: The SwiftData model context
    ///
    /// - Returns: `true` if the ingredient is in the shopping list, `false` otherwise
    static func isInShoppingList(_ ingredient: Ingredient, context: ModelContext) -> Bool {
        let repository = SDShoppingListRepository(context: context)
        return repository.exists(ingredient)
    }
}
