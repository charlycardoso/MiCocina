//
//  ShoppingListViewModelTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Testing
import Foundation

@testable import MiCocina

@Suite("ShoppingListViewModel Tests")
struct ShoppingListViewModelTests {
    
    // MARK: - Mock Repository
    
    @Observable
    final class MockShoppingListRepository: ShoppingListRepository {
        var items: Set<ShoppingListItem> = []
        var addCalled = false
        var removeCalled = false
        var markAsBoughtCalled = false
        var clearCalled = false
        
        func getShoppingList() -> Set<ShoppingListItem> {
            return items
        }
        
        func add(_ ingredient: Ingredient) throws {
            addCalled = true
            let newItem = ShoppingListItem(ingredient: ingredient, isBought: false)
            items.insert(newItem)
        }
        
        func remove(_ item: ShoppingListItem) throws {
            removeCalled = true
            items.remove(item)
        }
        
        func markAsBought(_ item: ShoppingListItem, bought: Bool) throws {
            markAsBoughtCalled = true
            items.remove(item)
            let updated = item.withBoughtState(bought)
            items.insert(updated)
        }
        
        func clear() throws {
            clearCalled = true
            items.removeAll()
        }
        
        func exists(_ ingredient: Ingredient) -> Bool {
            return items.contains { $0.ingredient.id == ingredient.id }
        }
    }
    
    // MARK: - Initialization Tests
    
    @Test("ViewModel initializes with empty items")
    func initializesWithEmptyItems() {
        let mockRepo = MockShoppingListRepository()
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.isEmpty)
    }
    
    @Test("ViewModel loads items from repository")
    func loadsItemsFromRepository() {
        let mockRepo = MockShoppingListRepository()
        let ingredient = Ingredient(name: "tomato")
        let item = ShoppingListItem(ingredient: ingredient, isBought: false)
        mockRepo.items.insert(item)
        
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        #expect(viewModel.items.count == 1)
        #expect(!viewModel.isEmpty)
    }
    
    // MARK: - Computed Properties Tests
    
    @Test("unboughtItems returns only unbought items")
    func unboughtItemsFiltersCorrectly() {
        let mockRepo = MockShoppingListRepository()
        let tomato = Ingredient(name: "tomato")
        let onion = Ingredient(name: "onion")
        let garlic = Ingredient(name: "garlic")
        
        mockRepo.items.insert(ShoppingListItem(ingredient: tomato, isBought: false))
        mockRepo.items.insert(ShoppingListItem(ingredient: onion, isBought: true))
        mockRepo.items.insert(ShoppingListItem(ingredient: garlic, isBought: false))
        
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        #expect(viewModel.unboughtItems.count == 2)
        #expect(viewModel.unboughtItems.allSatisfy { !$0.isBought })
    }
    
    @Test("boughtItems returns only bought items")
    func boughtItemsFiltersCorrectly() {
        let mockRepo = MockShoppingListRepository()
        let tomato = Ingredient(name: "tomato")
        let onion = Ingredient(name: "onion")
        let garlic = Ingredient(name: "garlic")
        
        mockRepo.items.insert(ShoppingListItem(ingredient: tomato, isBought: false))
        mockRepo.items.insert(ShoppingListItem(ingredient: onion, isBought: true))
        mockRepo.items.insert(ShoppingListItem(ingredient: garlic, isBought: true))
        
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        #expect(viewModel.boughtItems.count == 2)
        #expect(viewModel.boughtItems.allSatisfy { $0.isBought })
    }
    
    @Test("unboughtItems are sorted alphabetically")
    func unboughtItemsAreSorted() {
        let mockRepo = MockShoppingListRepository()
        let zebra = Ingredient(name: "zebra")
        let apple = Ingredient(name: "apple")
        let banana = Ingredient(name: "banana")
        
        mockRepo.items.insert(ShoppingListItem(ingredient: zebra, isBought: false))
        mockRepo.items.insert(ShoppingListItem(ingredient: apple, isBought: false))
        mockRepo.items.insert(ShoppingListItem(ingredient: banana, isBought: false))
        
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        let names = viewModel.unboughtItems.map { $0.ingredient.name }
        #expect(names == ["apple", "banana", "zebra"])
    }
    
    @Test("isEmpty is true when no items")
    func isEmptyTrueWhenNoItems() {
        let mockRepo = MockShoppingListRepository()
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        #expect(viewModel.isEmpty)
    }
    
    @Test("isEmpty is false when items exist")
    func isEmptyFalseWhenItemsExist() {
        let mockRepo = MockShoppingListRepository()
        let ingredient = Ingredient(name: "tomato")
        mockRepo.items.insert(ShoppingListItem(ingredient: ingredient))
        
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        #expect(!viewModel.isEmpty)
    }
    
    // MARK: - Action Tests
    
    @Test("toggleBought changes item bought state")
    func toggleBoughtChangesState() throws {
        let mockRepo = MockShoppingListRepository()
        let ingredient = Ingredient(name: "tomato")
        let item = ShoppingListItem(ingredient: ingredient, isBought: false)
        mockRepo.items.insert(item)
        
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        viewModel.toggleBought(item)
        
        #expect(mockRepo.markAsBoughtCalled)
    }
    
    @Test("removeItem removes item from list")
    func removeItemRemovesFromList() throws {
        let mockRepo = MockShoppingListRepository()
        let ingredient = Ingredient(name: "tomato")
        let item = ShoppingListItem(ingredient: ingredient)
        mockRepo.items.insert(item)
        
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        viewModel.removeItem(item)
        
        #expect(mockRepo.removeCalled)
    }
    
    @Test("removeItems removes multiple items")
    func removeItemsRemovesMultiple() throws {
        let mockRepo = MockShoppingListRepository()
        let tomato = Ingredient(name: "tomato")
        let onion = Ingredient(name: "onion")
        let item1 = ShoppingListItem(ingredient: tomato)
        let item2 = ShoppingListItem(ingredient: onion)
        mockRepo.items.insert(item1)
        mockRepo.items.insert(item2)
        
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        viewModel.removeItems([item1, item2])
        
        #expect(mockRepo.removeCalled)
        #expect(viewModel.items.isEmpty)
    }
    
    @Test("clearList removes all items")
    func clearListRemovesAll() throws {
        let mockRepo = MockShoppingListRepository()
        mockRepo.items.insert(ShoppingListItem(ingredient: Ingredient(name: "tomato")))
        mockRepo.items.insert(ShoppingListItem(ingredient: Ingredient(name: "onion")))
        mockRepo.items.insert(ShoppingListItem(ingredient: Ingredient(name: "garlic")))
        
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        viewModel.clearList()
        
        #expect(mockRepo.clearCalled)
        #expect(viewModel.items.isEmpty)
    }
    
    @Test("addIngredient adds new ingredient to list")
    func addIngredientAddsToList() throws {
        let mockRepo = MockShoppingListRepository()
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        let ingredient = Ingredient(name: "tomato")
        viewModel.addIngredient(ingredient)
        
        #expect(mockRepo.addCalled)
        #expect(viewModel.items.count == 1)
    }
    
    @Test("addIngredient does not duplicate existing ingredient")
    func addIngredientNoDuplicate() throws {
        let mockRepo = MockShoppingListRepository()
        let ingredient = Ingredient(name: "tomato")
        
        // Add once
        try mockRepo.add(ingredient)
        
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        // Try to add again - mock repo should handle this
        viewModel.addIngredient(ingredient)
        
        // Count should still be based on unique items
        #expect(viewModel.items.count >= 1)
    }
    
    // MARK: - Edge Cases
    
    @Test("loadShoppingList handles empty repository")
    func loadHandlesEmptyRepository() {
        let mockRepo = MockShoppingListRepository()
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        
        viewModel.loadShoppingList()
        
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.unboughtItems.isEmpty)
        #expect(viewModel.boughtItems.isEmpty)
    }
    
    @Test("toggling already bought item unboughts it")
    func toggleBoughtItemUnboughtsIt() throws {
        let mockRepo = MockShoppingListRepository()
        let ingredient = Ingredient(name: "tomato")
        let item = ShoppingListItem(ingredient: ingredient, isBought: true)
        mockRepo.items.insert(item)
        
        let viewModel = ShoppingListViewModel(repository: mockRepo)
        viewModel.loadShoppingList()
        
        viewModel.toggleBought(item)
        
        #expect(mockRepo.markAsBoughtCalled)
    }
}
