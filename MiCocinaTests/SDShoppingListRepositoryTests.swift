//
//  SDShoppingListRepositoryTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Testing
import SwiftData
import Foundation

@testable import MiCocina

@Suite("SDShoppingListRepository Tests")
struct SDShoppingListRepositoryTests {
    
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
    
    // MARK: - Initialization Tests
    
    @MainActor @Test("Repository initializes with context")
    func repositoryInitializesWithContext() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        #expect(repository.context === container.mainContext)
    }
    
    // MARK: - getShoppingList Tests
    
    @MainActor @Test("getShoppingList returns empty set when nothing added")
    func getShoppingListReturnsEmptyWhenEmpty() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let shoppingList = repository.getShoppingList()
        
        #expect(shoppingList.isEmpty)
    }
    
    @MainActor @Test("getShoppingList returns all added items")
    func getShoppingListReturnsAllItems() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let tomato = Ingredient(name: "tomato")
        let onion = Ingredient(name: "onion")
        
        try repository.add(tomato)
        try repository.add(onion)
        
        let shoppingList = repository.getShoppingList()
        
        #expect(shoppingList.count == 2)
        #expect(shoppingList.contains { $0.ingredient.id == tomato.id })
        #expect(shoppingList.contains { $0.ingredient.id == onion.id })
    }
    
    // MARK: - add Tests
    
    @MainActor @Test("add stores a single ingredient")
    func addStoresSingleIngredient() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let garlic = Ingredient(name: "garlic")
        try repository.add(garlic)
        
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 1)
        #expect(shoppingList.first?.ingredient.id == garlic.id)
        #expect(shoppingList.first?.isBought == false)
    }
    
    @MainActor @Test("add stores multiple distinct ingredients")
    func addStoresMultipleIngredients() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let ingredients = [
            Ingredient(name: "salt"),
            Ingredient(name: "pepper"),
            Ingredient(name: "oregano")
        ]
        
        for ingredient in ingredients {
            try repository.add(ingredient)
        }
        
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 3)
    }
    
    @MainActor @Test("add does not duplicate existing ingredient")
    func addDoesNotDuplicateExisting() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let tomato = Ingredient(name: "tomato")
        
        try repository.add(tomato)
        try repository.add(tomato)
        
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 1)
    }
    
    @MainActor @Test("add sets isBought to false by default")
    func addSetsIsBoughtToFalse() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let milk = Ingredient(name: "milk")
        try repository.add(milk)
        
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.first?.isBought == false)
    }
    
    // MARK: - remove Tests
    
    @MainActor @Test("remove deletes item from shopping list")
    func removeDeletesItem() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let cheese = Ingredient(name: "cheese")
        try repository.add(cheese)
        
        var shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 1)
        
        let item = shoppingList.first!
        try repository.remove(item)
        
        shoppingList = repository.getShoppingList()
        #expect(shoppingList.isEmpty)
    }
    
    @MainActor @Test("remove handles non-existent item gracefully")
    func removeHandlesNonExistentItem() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let nonExistentItem = ShoppingListItem(
            id: UUID(),
            ingredient: Ingredient(name: "ghost"),
            isBought: false
        )
        
        // Should not throw
        try repository.remove(nonExistentItem)
        
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.isEmpty)
    }
    
    @MainActor @Test("remove only deletes specified item")
    func removeOnlyDeletesSpecifiedItem() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let tomato = Ingredient(name: "tomato")
        let onion = Ingredient(name: "onion")
        
        try repository.add(tomato)
        try repository.add(onion)
        
        var shoppingList = repository.getShoppingList()
        let tomatoItem = shoppingList.first { $0.ingredient.id == tomato.id }!
        
        try repository.remove(tomatoItem)
        
        shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 1)
        #expect(shoppingList.first?.ingredient.id == onion.id)
    }
    
    // MARK: - markAsBought Tests
    
    @MainActor @Test("markAsBought updates item bought state to true")
    func markAsBoughtUpdatesStateToTrue() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let bread = Ingredient(name: "bread")
        try repository.add(bread)
        
        var shoppingList = repository.getShoppingList()
        let item = shoppingList.first!
        
        try repository.markAsBought(item, bought: true)
        
        shoppingList = repository.getShoppingList()
        #expect(shoppingList.first?.isBought == true)
    }
    
    @MainActor @Test("markAsBought updates item bought state to false")
    func markAsBoughtUpdatesStateToFalse() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let eggs = Ingredient(name: "eggs")
        try repository.add(eggs)
        
        var shoppingList = repository.getShoppingList()
        let item = shoppingList.first!
        
        // Mark as bought first
        try repository.markAsBought(item, bought: true)
        
        // Then unmark
        shoppingList = repository.getShoppingList()
        let boughtItem = shoppingList.first!
        try repository.markAsBought(boughtItem, bought: false)
        
        shoppingList = repository.getShoppingList()
        #expect(shoppingList.first?.isBought == false)
    }
    
    @MainActor @Test("markAsBought handles non-existent item gracefully")
    func markAsBoughtHandlesNonExistentItem() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let nonExistentItem = ShoppingListItem(
            id: UUID(),
            ingredient: Ingredient(name: "ghost"),
            isBought: false
        )
        
        // Should not throw
        try repository.markAsBought(nonExistentItem, bought: true)
    }
    
    // MARK: - clear Tests
    
    @MainActor @Test("clear removes all items from shopping list")
    func clearRemovesAllItems() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let ingredients = [
            Ingredient(name: "tomato"),
            Ingredient(name: "onion"),
            Ingredient(name: "garlic"),
            Ingredient(name: "cheese")
        ]
        
        for ingredient in ingredients {
            try repository.add(ingredient)
        }
        
        var shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 4)
        
        try repository.clear()
        
        shoppingList = repository.getShoppingList()
        #expect(shoppingList.isEmpty)
    }
    
    @MainActor @Test("clear on empty shopping list does not throw")
    func clearOnEmptyDoesNotThrow() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        // Should not throw
        try repository.clear()
        
        let shoppingList = repository.getShoppingList()
        #expect(shoppingList.isEmpty)
    }
    
    // MARK: - exists Tests
    
    @MainActor @Test("exists returns true for ingredient in shopping list")
    func existsReturnsTrueForExistingIngredient() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let milk = Ingredient(name: "milk")
        try repository.add(milk)
        
        #expect(repository.exists(milk))
    }
    
    @MainActor @Test("exists returns false for ingredient not in shopping list")
    func existsReturnsFalseForNonExistingIngredient() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let milk = Ingredient(name: "milk")
        
        #expect(!repository.exists(milk))
    }
    
    @MainActor @Test("exists returns false after item is removed")
    func existsReturnsFalseAfterRemoval() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        let bread = Ingredient(name: "bread")
        try repository.add(bread)
        
        #expect(repository.exists(bread))
        
        let shoppingList = repository.getShoppingList()
        let item = shoppingList.first!
        try repository.remove(item)
        
        #expect(!repository.exists(bread))
    }
    
    // MARK: - Integration Tests
    
    @MainActor @Test("Complete workflow: add, mark as bought, remove, clear")
    func completeWorkflow() throws {
        let container = try makeContainer()
        let repository = SDShoppingListRepository(context: container.mainContext)
        
        // Add items
        let tomato = Ingredient(name: "tomato")
        let onion = Ingredient(name: "onion")
        let garlic = Ingredient(name: "garlic")
        
        try repository.add(tomato)
        try repository.add(onion)
        try repository.add(garlic)
        
        var shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 3)
        
        // Mark one as bought
        let tomatoItem = shoppingList.first { $0.ingredient.id == tomato.id }!
        try repository.markAsBought(tomatoItem, bought: true)
        
        shoppingList = repository.getShoppingList()
        let updatedTomatoItem = shoppingList.first { $0.ingredient.id == tomato.id }!
        #expect(updatedTomatoItem.isBought == true)
        
        // Remove one item
        let onionItem = shoppingList.first { $0.ingredient.id == onion.id }!
        try repository.remove(onionItem)
        
        shoppingList = repository.getShoppingList()
        #expect(shoppingList.count == 2)
        #expect(!repository.exists(onion))
        
        // Clear all
        try repository.clear()
        
        shoppingList = repository.getShoppingList()
        #expect(shoppingList.isEmpty)
    }
}
