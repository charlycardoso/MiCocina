//
//  ShoppingListHelperTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Testing
import SwiftData
import Foundation

@testable import MiCocina

@Suite("ShoppingListHelper Tests")
struct ShoppingListHelperTests {
    
    // MARK: - Setup
    
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            SDPantryItem.self,
            SDShoppingListItem.self,
            SDIngredient.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
    
    // MARK: - addToShoppingList Single Ingredient Tests
    
    @MainActor @Test("addToShoppingList adds single ingredient successfully")
    func addSingleIngredientSuccessfully() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let tomato = Ingredient(name: "tomato")
        let result = ShoppingListHelper.addToShoppingList(tomato, context: context)
        
        #expect(result == true)
        
        // Verify it was added
        let repository = SDShoppingListRepository(context: context)
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 1)
        #expect(shoppingList.first?.ingredient.id == tomato.id)
    }
    
    @MainActor @Test("addToShoppingList returns true on success")
    func addReturnsTrue() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let onion = Ingredient(name: "onion")
        let result = ShoppingListHelper.addToShoppingList(onion, context: context)
        
        #expect(result == true)
    }
    
    @MainActor @Test("addToShoppingList adds multiple different ingredients")
    func addMultipleDifferentIngredients() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let tomato = Ingredient(name: "tomato")
        let onion = Ingredient(name: "onion")
        let garlic = Ingredient(name: "garlic")
        
        ShoppingListHelper.addToShoppingList(tomato, context: context)
        ShoppingListHelper.addToShoppingList(onion, context: context)
        ShoppingListHelper.addToShoppingList(garlic, context: context)
        
        let repository = SDShoppingListRepository(context: context)
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 3)
    }
    
    @MainActor @Test("addToShoppingList handles duplicate gracefully")
    func addHandlesDuplicate() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let cheese = Ingredient(name: "cheese")
        
        let result1 = ShoppingListHelper.addToShoppingList(cheese, context: context)
        let result2 = ShoppingListHelper.addToShoppingList(cheese, context: context)
        
        #expect(result1 == true)
        #expect(result2 == true)
        
        let repository = SDShoppingListRepository(context: context)
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 1)
    }
    
    // MARK: - addToShoppingList Multiple Ingredients Tests
    
    @MainActor @Test("addToShoppingList adds multiple ingredients array")
    func addMultipleIngredientsArray() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let ingredients = [
            Ingredient(name: "tomato"),
            Ingredient(name: "onion"),
            Ingredient(name: "garlic")
        ]
        
        let count = ShoppingListHelper.addToShoppingList(ingredients, context: context)
        
        #expect(count == 3)
        
        let repository = SDShoppingListRepository(context: context)
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 3)
    }
    
    @MainActor @Test("addToShoppingList returns count of successful adds")
    func addReturnsSuccessCount() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let ingredients = [
            Ingredient(name: "milk"),
            Ingredient(name: "bread"),
            Ingredient(name: "eggs")
        ]
        
        let count = ShoppingListHelper.addToShoppingList(ingredients, context: context)
        
        #expect(count == 3)
    }
    
    @MainActor @Test("addToShoppingList handles empty array")
    func addHandlesEmptyArray() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let ingredients: [Ingredient] = []
        let count = ShoppingListHelper.addToShoppingList(ingredients, context: context)
        
        #expect(count == 0)
        
        let repository = SDShoppingListRepository(context: context)
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.isEmpty)
    }
    
    @MainActor @Test("addToShoppingList handles array with duplicates")
    func addHandlesArrayWithDuplicates() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let tomato = Ingredient(id: UUID(), name: "tomato")
        let ingredients = [
            tomato,
            tomato,  // Same ingredient twice
            Ingredient(name: "onion")
        ]
        
        let count = ShoppingListHelper.addToShoppingList(ingredients, context: context)
        
        // All three add calls succeed (repository handles deduplication)
        #expect(count == 3)
        
        let repository = SDShoppingListRepository(context: context)
        let shoppingList = repository.getShoppingList()
        // But only 2 unique items in the list
        #expect(shoppingList.count == 2)
    }
    
    // MARK: - isInShoppingList Tests
    
    @MainActor @Test("isInShoppingList returns true for existing ingredient")
    func isInShoppingListReturnsTrueForExisting() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let milk = Ingredient(name: "milk")
        ShoppingListHelper.addToShoppingList(milk, context: context)
        
        let exists = ShoppingListHelper.isInShoppingList(milk, context: context)
        
        #expect(exists == true)
    }
    
    @MainActor @Test("isInShoppingList returns false for non-existing ingredient")
    func isInShoppingListReturnsFalseForNonExisting() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let bread = Ingredient(name: "bread")
        let exists = ShoppingListHelper.isInShoppingList(bread, context: context)
        
        #expect(exists == false)
    }
    
    @MainActor @Test("isInShoppingList checks by ingredient ID")
    func isInShoppingListChecksByID() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let originalIngredient = Ingredient(id: UUID(), name: "cheese")
        ShoppingListHelper.addToShoppingList(originalIngredient, context: context)
        
        // Same ID, different name (shouldn't happen in practice, but tests ID matching)
        let sameIDIngredient = Ingredient(id: originalIngredient.id, name: "different")
        let exists = ShoppingListHelper.isInShoppingList(sameIDIngredient, context: context)
        
        #expect(exists == true)
    }
    
    @MainActor @Test("isInShoppingList returns false after ingredient removed")
    func isInShoppingListReturnsFalseAfterRemoval() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let eggs = Ingredient(name: "eggs")
        ShoppingListHelper.addToShoppingList(eggs, context: context)
        
        #expect(ShoppingListHelper.isInShoppingList(eggs, context: context) == true)
        
        // Remove it
        let repository = SDShoppingListRepository(context: context)
        let shoppingList = repository.getShoppingList()
        let item = shoppingList.first!
        try repository.remove(item)
        
        #expect(ShoppingListHelper.isInShoppingList(eggs, context: context) == false)
    }
    
    // MARK: - Integration Tests
    
    @MainActor @Test("Helper integrates with repository correctly")
    func helperIntegratesWithRepository() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let repository = SDShoppingListRepository(context: context)
        
        // Add via helper
        let tomato = Ingredient(name: "tomato")
        ShoppingListHelper.addToShoppingList(tomato, context: context)
        
        // Check via repository
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 1)
        #expect(shoppingList.first?.ingredient.id == tomato.id)
        
        // Check via helper
        #expect(ShoppingListHelper.isInShoppingList(tomato, context: context))
    }
    
    @MainActor @Test("Helper can add ingredients from different sources")
    func helperAddsFromDifferentSources() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        // Simulate adding from recipe
        let recipeIngredients = [
            Ingredient(name: "tomato"),
            Ingredient(name: "basil")
        ]
        
        // Simulate adding from pantry
        let pantryIngredients = [
            Ingredient(name: "olive oil"),
            Ingredient(name: "salt")
        ]
        
        ShoppingListHelper.addToShoppingList(recipeIngredients, context: context)
        ShoppingListHelper.addToShoppingList(pantryIngredients, context: context)
        
        let repository = SDShoppingListRepository(context: context)
        let shoppingList = repository.getShoppingList()
        
        #expect(shoppingList.count == 4)
    }
    
    @MainActor @Test("Complete workflow using helper")
    func completeWorkflowUsingHelper() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        // Add some ingredients
        let groceries = [
            Ingredient(name: "milk"),
            Ingredient(name: "bread"),
            Ingredient(name: "eggs")
        ]
        
        let addedCount = ShoppingListHelper.addToShoppingList(groceries, context: context)
        #expect(addedCount == 3)
        
        // Check they exist
        for ingredient in groceries {
            #expect(ShoppingListHelper.isInShoppingList(ingredient, context: context))
        }
        
        // Add one more individually
        let butter = Ingredient(name: "butter")
        let success = ShoppingListHelper.addToShoppingList(butter, context: context)
        #expect(success)
        
        // Verify total count
        let repository = SDShoppingListRepository(context: context)
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 4)
    }
    
    // MARK: - Edge Cases
    
    @MainActor @Test("Helper handles ingredient with empty name")
    func helperHandlesEmptyName() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let emptyIngredient = Ingredient(name: "")
        let result = ShoppingListHelper.addToShoppingList(emptyIngredient, context: context)
        
        #expect(result == true)
        
        let repository = SDShoppingListRepository(context: context)
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 1)
    }
    
    @MainActor @Test("Helper handles ingredient with special characters")
    func helperHandlesSpecialCharacters() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let specialIngredients = [
            Ingredient(name: "jalapeño"),
            Ingredient(name: "crème fraîche"),
            Ingredient(name: "café")
        ]
        
        let count = ShoppingListHelper.addToShoppingList(specialIngredients, context: context)
        
        #expect(count == 3)
        
        for ingredient in specialIngredients {
            #expect(ShoppingListHelper.isInShoppingList(ingredient, context: context))
        }
    }
    
    @MainActor @Test("discardableResult attribute allows ignoring return value")
    func discardableResultWorks() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let ingredient = Ingredient(name: "tomato")
        
        // Should compile without warning
        ShoppingListHelper.addToShoppingList(ingredient, context: context)
        ShoppingListHelper.addToShoppingList([ingredient], context: context)
    }
}
