//
//  ShoppingListMapperTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Testing
import SwiftData
import Foundation

@testable import MiCocina

@Suite("Shopping List Mapper Tests")
struct ShoppingListMapperTests {
    
    // MARK: - Setup
    
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            SDShoppingListItem.self,
            SDIngredient.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
    
    // MARK: - StorageMapper Tests
    
    @MainActor @Test("StorageMapper converts ShoppingListItem to SDShoppingListItem")
    func storageMapperConvertsShoppingListItem() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let ingredient = Ingredient(name: "tomato")
        let shoppingListItem = ShoppingListItem(
            id: UUID(),
            ingredient: ingredient,
            isBought: false
        )
        
        let sdItem = StorageMapper.toStorage(shoppingListItem: shoppingListItem, context: context)
        
        #expect(sdItem.id == shoppingListItem.id)
        #expect(sdItem.ingredient.name == ingredient.name)
        #expect(sdItem.isBought == false)
    }
    
    @MainActor @Test("StorageMapper creates SDIngredient if not exists")
    func storageMapperCreatesIngredientIfNeeded() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let ingredient = Ingredient(name: "onion")
        let shoppingListItem = ShoppingListItem(ingredient: ingredient, isBought: false)
        
        let sdItem = StorageMapper.toStorage(shoppingListItem: shoppingListItem, context: context)
        
        // Verify the ingredient was created
        let ingredientID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientID }
        )
        let fetchedIngredients = try context.fetch(descriptor)
        
        #expect(fetchedIngredients.count == 1)
        #expect(fetchedIngredients.first?.name == ingredient.name)
        #expect(sdItem.ingredient === fetchedIngredients.first)
    }
    
    @MainActor @Test("StorageMapper reuses existing SDIngredient")
    func storageMapperReusesExistingIngredient() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let ingredient = Ingredient(name: "garlic")
        
        // First, create an SDIngredient
        let existingSDIngredient = SDIngredient(id: ingredient.id, name: ingredient.name)
        context.insert(existingSDIngredient)
        try context.save()
        
        // Now create a shopping list item with the same ingredient
        let shoppingListItem = ShoppingListItem(ingredient: ingredient, isBought: false)
        let sdItem = StorageMapper.toStorage(shoppingListItem: shoppingListItem, context: context)
        
        // Should reuse the existing ingredient
        #expect(sdItem.ingredient === existingSDIngredient)
        
        // Verify there's only one SDIngredient
        let ingredientID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientID }
        )
        let fetchedIngredients = try context.fetch(descriptor)
        #expect(fetchedIngredients.count == 1)
    }
    
    @MainActor @Test("StorageMapper preserves bought state")
    func storageMapperPreservesBoughtState() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let ingredient = Ingredient(name: "cheese")
        let boughtItem = ShoppingListItem(ingredient: ingredient, isBought: true)
        let unboughtItem = ShoppingListItem(ingredient: ingredient, isBought: false)
        
        let sdBoughtItem = StorageMapper.toStorage(shoppingListItem: boughtItem, context: context)
        let sdUnboughtItem = StorageMapper.toStorage(shoppingListItem: unboughtItem, context: context)
        
        #expect(sdBoughtItem.isBought == true)
        #expect(sdUnboughtItem.isBought == false)
    }
    
    @MainActor @Test("StorageMapper inserts item into context")
    func storageMapperInsertsIntoContext() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let ingredient = Ingredient(name: "milk")
        let shoppingListItem = ShoppingListItem(ingredient: ingredient, isBought: false)
        
        _ = StorageMapper.toStorage(shoppingListItem: shoppingListItem, context: context)
        
        // Verify the item was inserted
        let descriptor = FetchDescriptor<SDShoppingListItem>()
        let items = try context.fetch(descriptor)
        
        #expect(items.count == 1)
        #expect(items.first?.ingredient.name == ingredient.name)
    }
    
    // MARK: - DomainMapper Tests
    
    @MainActor @Test("DomainMapper converts SDShoppingListItem to ShoppingListItem")
    func domainMapperConvertsShoppingListItem() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let sdIngredient = SDIngredient(id: UUID(), name: "tomato")
        context.insert(sdIngredient)
        
        let sdItem = SDShoppingListItem(
            id: UUID(),
            ingredient: sdIngredient,
            isBought: false
        )
        context.insert(sdItem)
        
        let domainItem = DomainMapper.toDomain(shoppingListItem: sdItem)
        
        #expect(domainItem.id == sdItem.id)
        #expect(domainItem.ingredient.id == sdIngredient.id)
        #expect(domainItem.ingredient.name == sdIngredient.name)
        #expect(domainItem.isBought == false)
    }
    
    @MainActor @Test("DomainMapper converts SDIngredient to Ingredient")
    func domainMapperConvertsIngredient() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let sdIngredient = SDIngredient(id: UUID(), name: "onion")
        context.insert(sdIngredient)
        
        let domainIngredient = DomainMapper.toDomain(ingredient: sdIngredient)
        
        #expect(domainIngredient.id == sdIngredient.id)
        #expect(domainIngredient.name == sdIngredient.name)
    }
    
    @MainActor @Test("DomainMapper preserves bought state")
    func domainMapperPreservesBoughtState() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let sdIngredient = SDIngredient(id: UUID(), name: "bread")
        context.insert(sdIngredient)
        
        let sdBoughtItem = SDShoppingListItem(id: UUID(), ingredient: sdIngredient, isBought: true)
        let sdUnboughtItem = SDShoppingListItem(id: UUID(), ingredient: sdIngredient, isBought: false)
        
        let boughtItem = DomainMapper.toDomain(shoppingListItem: sdBoughtItem)
        let unboughtItem = DomainMapper.toDomain(shoppingListItem: sdUnboughtItem)
        
        #expect(boughtItem.isBought == true)
        #expect(unboughtItem.isBought == false)
    }
    
    // MARK: - Round-trip Tests
    
    @MainActor @Test("Round-trip conversion preserves data")
    func roundTripPreservesData() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let originalIngredient = Ingredient(id: UUID(), name: "garlic", quantity: 0)
        let originalItem = ShoppingListItem(
            id: UUID(),
            ingredient: originalIngredient,
            isBought: true
        )
        
        // To storage
        let sdItem = StorageMapper.toStorage(shoppingListItem: originalItem, context: context)
        try context.save()
        
        // Back to domain
        let roundTripItem = DomainMapper.toDomain(shoppingListItem: sdItem)
        
        #expect(roundTripItem.id == originalItem.id)
        #expect(roundTripItem.ingredient.id == originalIngredient.id)
        #expect(roundTripItem.ingredient.name == originalIngredient.name)
        #expect(roundTripItem.isBought == originalItem.isBought)
    }
    
    @MainActor @Test("Multiple round-trips maintain data integrity")
    func multipleRoundTripsPreserveData() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let items = [
            ShoppingListItem(ingredient: Ingredient(name: "tomato"), isBought: false),
            ShoppingListItem(ingredient: Ingredient(name: "onion"), isBought: true),
            ShoppingListItem(ingredient: Ingredient(name: "garlic"), isBought: false),
        ]
        
        // Convert to storage
        let sdItems = items.map { StorageMapper.toStorage(shoppingListItem: $0, context: context) }
        try context.save()
        
        // Convert back to domain
        let roundTripItems = sdItems.map { DomainMapper.toDomain(shoppingListItem: $0) }
        
        #expect(roundTripItems.count == items.count)
        
        for (index, original) in items.enumerated() {
            let roundTrip = roundTripItems[index]
            #expect(roundTrip.id == original.id)
            #expect(roundTrip.ingredient.name == original.ingredient.name)
            #expect(roundTrip.isBought == original.isBought)
        }
    }
    
    // MARK: - Edge Cases
    
    @MainActor @Test("Mapper handles special characters in ingredient names")
    func mapperHandlesSpecialCharacters() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let specialNames = [
            "jalapeño",
            "café au lait",
            "crème fraîche",
            "açaí",
            "schnitzel"
        ]
        
        for name in specialNames {
            let ingredient = Ingredient(name: name)
            let item = ShoppingListItem(ingredient: ingredient, isBought: false)
            
            let sdItem = StorageMapper.toStorage(shoppingListItem: item, context: context)
            let roundTrip = DomainMapper.toDomain(shoppingListItem: sdItem)
            
            // Note: ingredient names are normalized, so compare the normalized version
            #expect(roundTrip.ingredient.name == ingredient.name)
        }
    }
    
    @MainActor @Test("Mapper handles empty ingredient name")
    func mapperHandlesEmptyIngredientName() throws {
        let container = try makeContainer()
        let context = container.mainContext
        
        let ingredient = Ingredient(name: "")
        let item = ShoppingListItem(ingredient: ingredient, isBought: false)
        
        let sdItem = StorageMapper.toStorage(shoppingListItem: item, context: context)
        let roundTrip = DomainMapper.toDomain(shoppingListItem: sdItem)
        
        #expect(roundTrip.ingredient.name == ingredient.name)
    }
}
