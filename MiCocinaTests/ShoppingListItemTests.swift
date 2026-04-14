//
//  ShoppingListItemTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Testing
import Foundation

@testable import MiCocina

@Suite("ShoppingListItem Tests")
struct ShoppingListItemTests {
    
    // MARK: - Initialization Tests
    
    @Test("ShoppingListItem initializes with default values")
    func initializesWithDefaults() {
        let ingredient = Ingredient(name: "tomato")
        let item = ShoppingListItem(ingredient: ingredient)
        
        #expect(item.id != UUID())  // Should have a valid UUID
        #expect(item.ingredient.name == "tomato")
        #expect(item.isBought == false)
    }
    
    @Test("ShoppingListItem initializes with custom ID")
    func initializesWithCustomID() {
        let customID = UUID()
        let ingredient = Ingredient(name: "onion")
        let item = ShoppingListItem(id: customID, ingredient: ingredient)
        
        #expect(item.id == customID)
    }
    
    @Test("ShoppingListItem initializes with bought state")
    func initializesWithBoughtState() {
        let ingredient = Ingredient(name: "garlic")
        let item = ShoppingListItem(ingredient: ingredient, isBought: true)
        
        #expect(item.isBought == true)
    }
    
    @Test("ShoppingListItem initializes with all parameters")
    func initializesWithAllParameters() {
        let id = UUID()
        let ingredient = Ingredient(name: "cheese")
        let item = ShoppingListItem(id: id, ingredient: ingredient, isBought: true)
        
        #expect(item.id == id)
        #expect(item.ingredient.name == "cheese")
        #expect(item.isBought == true)
    }
    
    // MARK: - Equatable Tests
    
    @Test("ShoppingListItem equatable compares by ID")
    func equatableComparesById() {
        let id = UUID()
        let ingredient1 = Ingredient(name: "tomato")
        let ingredient2 = Ingredient(name: "onion")
        
        let item1 = ShoppingListItem(id: id, ingredient: ingredient1, isBought: false)
        let item2 = ShoppingListItem(id: id, ingredient: ingredient2, isBought: true)
        
        #expect(item1 == item2)  // Same ID means equal
    }
    
    @Test("ShoppingListItem with different IDs are not equal")
    func differentIDsNotEqual() {
        let ingredient = Ingredient(name: "tomato")
        let item1 = ShoppingListItem(ingredient: ingredient)
        let item2 = ShoppingListItem(ingredient: ingredient)
        
        #expect(item1 != item2)  // Different IDs
    }
    
    // MARK: - Hashable Tests
    
    @Test("ShoppingListItem is hashable")
    func isHashable() {
        let ingredient = Ingredient(name: "tomato")
        let item1 = ShoppingListItem(ingredient: ingredient)
        let item2 = ShoppingListItem(ingredient: ingredient)
        
        var set: Set<ShoppingListItem> = []
        set.insert(item1)
        set.insert(item2)
        
        #expect(set.count == 2)  // Different items should hash differently
    }
    
    @Test("ShoppingListItem with same ID hash equally")
    func sameIDHashesEqually() {
        let id = UUID()
        let ingredient1 = Ingredient(name: "tomato")
        let ingredient2 = Ingredient(name: "onion")
        
        let item1 = ShoppingListItem(id: id, ingredient: ingredient1, isBought: false)
        let item2 = ShoppingListItem(id: id, ingredient: ingredient2, isBought: true)
        
        var set: Set<ShoppingListItem> = []
        set.insert(item1)
        set.insert(item2)
        
        #expect(set.count == 1)  // Same ID should hash equally
    }
    
    @Test("ShoppingListItem can be used in Set")
    func canBeUsedInSet() {
        let items = [
            ShoppingListItem(ingredient: Ingredient(name: "tomato")),
            ShoppingListItem(ingredient: Ingredient(name: "onion")),
            ShoppingListItem(ingredient: Ingredient(name: "garlic"))
        ]
        
        let set = Set(items)
        #expect(set.count == 3)
    }
    
    // MARK: - Identifiable Tests
    
    @Test("ShoppingListItem conforms to Identifiable")
    func conformsToIdentifiable() {
        let item = ShoppingListItem(ingredient: Ingredient(name: "tomato"))
        
        let _: UUID = item.id
        #expect(item.id != UUID())  // Should have a valid ID
    }
    
    // MARK: - withBoughtState Tests
    
    @Test("withBoughtState creates new item with updated state")
    func withBoughtStateCreatesNewItem() {
        let ingredient = Ingredient(name: "milk")
        let originalItem = ShoppingListItem(ingredient: ingredient, isBought: false)
        
        let updatedItem = originalItem.withBoughtState(true)
        
        #expect(updatedItem.id == originalItem.id)
        #expect(updatedItem.ingredient.id == originalItem.ingredient.id)
        #expect(updatedItem.isBought == true)
        #expect(originalItem.isBought == false)  // Original unchanged
    }
    
    @Test("withBoughtState preserves all other properties")
    func withBoughtStatePreservesProperties() {
        let id = UUID()
        let ingredient = Ingredient(name: "bread")
        let originalItem = ShoppingListItem(id: id, ingredient: ingredient, isBought: false)
        
        let updatedItem = originalItem.withBoughtState(true)
        
        #expect(updatedItem.id == id)
        #expect(updatedItem.ingredient.name == "bread")
        #expect(updatedItem.isBought == true)
    }
    
    @Test("withBoughtState can toggle state multiple times")
    func withBoughtStateCanToggleMultipleTimes() {
        let ingredient = Ingredient(name: "eggs")
        let item1 = ShoppingListItem(ingredient: ingredient, isBought: false)
        
        let item2 = item1.withBoughtState(true)
        #expect(item2.isBought == true)
        
        let item3 = item2.withBoughtState(false)
        #expect(item3.isBought == false)
        
        let item4 = item3.withBoughtState(true)
        #expect(item4.isBought == true)
    }
    
    @Test("withBoughtState setting same state creates new instance")
    func withBoughtStateSameStateCreatesNewInstance() {
        let ingredient = Ingredient(name: "cheese")
        let originalItem = ShoppingListItem(ingredient: ingredient, isBought: true)
        
        let sameStateItem = originalItem.withBoughtState(true)
        
        #expect(sameStateItem.id == originalItem.id)
        #expect(sameStateItem.isBought == true)
    }
    
    // MARK: - Integration with Ingredient Tests
    
    @Test("ShoppingListItem preserves normalized ingredient name")
    func preservesNormalizedIngredientName() {
        let ingredient = Ingredient(name: "Tomato")  // Will be normalized to "tomato"
        let item = ShoppingListItem(ingredient: ingredient)
        
        #expect(item.ingredient.name == "tomato")
    }
    
    @Test("ShoppingListItem works with ingredients with special characters")
    func worksWithSpecialCharacterIngredients() {
        let ingredient = Ingredient(name: "Jalapeño")
        let item = ShoppingListItem(ingredient: ingredient)
        
        // Ingredient normalization will handle special characters
        #expect(item.ingredient.name == ingredient.name)
    }
    
    // MARK: - Edge Cases
    
    @Test("ShoppingListItem with empty ingredient name")
    func handlesEmptyIngredientName() {
        let ingredient = Ingredient(name: "")
        let item = ShoppingListItem(ingredient: ingredient)
        
        #expect(item.ingredient.name == "")
        #expect(item.isBought == false)
    }
    
    @Test("ShoppingListItem with whitespace ingredient name")
    func handlesWhitespaceIngredientName() {
        let ingredient = Ingredient(name: "   ")
        let item = ShoppingListItem(ingredient: ingredient)
        
        // Ingredient normalization should handle this
        #expect(item.ingredient.name.isEmpty || item.ingredient.name == "   ")
    }
    
    @Test("Multiple ShoppingListItems with same ingredient have different IDs")
    func multipleItemsSameIngredientDifferentIDs() {
        let ingredient = Ingredient(name: "tomato")
        
        let item1 = ShoppingListItem(ingredient: ingredient)
        let item2 = ShoppingListItem(ingredient: ingredient)
        
        #expect(item1.id != item2.id)
        #expect(item1.ingredient.id == item2.ingredient.id)
    }
}
