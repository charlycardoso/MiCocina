import Testing
import SwiftData
import Foundation

@testable import MiCocina

/// Test suite for `SDPantryProtocolRepository` SwiftData-based pantry persistence.
///
/// `SDPantryProtocolRepositoryTests` validates all CRUD operations for pantry ingredients
/// stored using SwiftData. Tests ensure proper ingredient management, deduplication,
/// and collection operations.
@Suite
struct SDPantryProtocolRepositoryTests {
    private var container: ModelContainer
    private var context: ModelContext
    private var repository: SDPantryProtocolRepository

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: SDIngredient.self, configurations: config)
        context = ModelContext(container)
        repository = SDPantryProtocolRepository(context: context)
    }

    /// Tests that getPantry returns empty set when pantry is empty.
    @Test
    func getPantry_empty_returns_empty_set() {
        let pantry = repository.getPantry()
        #expect(pantry.isEmpty)
    }

    /// Tests that getPantry returns all stored ingredients.
    @Test
    func getPantry_with_ingredients_returns_all() throws {
        // Given
        let ingredient1 = Ingredient(name: "Flour")
        let ingredient2 = Ingredient(name: "Sugar")
        
        try repository.add(ingredient1)
        try repository.add(ingredient2)

        // When
        let pantry = repository.getPantry()

        // Then
        #expect(pantry.count == 2)
        #expect(pantry.contains(ingredient1))
        #expect(pantry.contains(ingredient2))
    }

    /// Tests that a single ingredient can be added successfully.
    @Test
    func add_single_ingredient_succeeds() throws {
        // Given
        let ingredient = Ingredient(name: "Butter")

        // When
        try repository.add(ingredient)

        // Then
        let pantry = repository.getPantry()
        #expect(pantry.count == 1)
        #expect(pantry.contains(ingredient))
    }

    @Test
    func add_multiple_ingredients_succeeds() throws {
        // Given
        let ingredients = [
            Ingredient(name: "Salt"),
            Ingredient(name: "Pepper"),
            Ingredient(name: "Garlic")
        ]

        // When
        for ingredient in ingredients {
            try repository.add(ingredient)
        }

        // Then
        let pantry = repository.getPantry()
        #expect(pantry.count == 3)
        for ingredient in ingredients {
            #expect(pantry.contains(ingredient))
        }
    }

    @Test
    func add_existing_ingredient_calls_update() throws {
        // Given
        let ingredient = Ingredient(name: "Tomato")
        try repository.add(ingredient)

        // When - Add the same ingredient again (same UUID)
        try repository.add(ingredient)

        // Then - Should still have only one ingredient since the repository detected it exists and called update
        let pantry = repository.getPantry()
        #expect(pantry.count == 1)
    }

    @Test
    func remove_existing_ingredient_succeeds() throws {
        // Given
        let ingredient1 = Ingredient(name: "Onion")
        let ingredient2 = Ingredient(name: "Carrot")
        try repository.add(ingredient1)
        try repository.add(ingredient2)

        // When
        try repository.remove(ingredient1)

        // Then
        let pantry = repository.getPantry()
        #expect(pantry.count == 1)
        #expect(pantry.contains(ingredient2))
        #expect(!pantry.contains(ingredient1))
    }

    @Test
    func remove_nonexistent_ingredient_does_not_throw() throws {
        // Given
        let ingredient = Ingredient(name: "NonExistent")

        // When - Should not throw
        try repository.remove(ingredient)

        // Then - No error
        let pantry = repository.getPantry()
        #expect(pantry.isEmpty)
    }

    @Test
    func update_existing_ingredient_succeeds() throws {
        // Given
        let originalIngredient = Ingredient(name: "Apple")
        try repository.add(originalIngredient)

        // When - Update with new name
        let updatedIngredient = Ingredient(name: "Apples")
        try repository.update(updatedIngredient)

        // Then
        let pantry = repository.getPantry()
        #expect(pantry.count == 1)
    }

    @Test
    func update_nonexistent_ingredient_does_not_throw() throws {
        // Given
        let ingredient = Ingredient(name: "NonExistent")

        // When - Should not throw
        try repository.update(ingredient)

        // Then - No error and pantry is empty
        let pantry = repository.getPantry()
        #expect(pantry.isEmpty)
    }

    @Test
    func clear_removes_all_ingredients() throws {
        // Given
        let ingredients = [
            Ingredient(name: "Milk"),
            Ingredient(name: "Eggs"),
            Ingredient(name: "Cheese")
        ]
        for ingredient in ingredients {
            try repository.add(ingredient)
        }

        // When
        try repository.clear()

        // Then
        let pantry = repository.getPantry()
        #expect(pantry.isEmpty)
    }

    @Test
    func clear_on_empty_pantry_succeeds() throws {
        // When - Clear empty pantry
        try repository.clear()

        // Then - No error
        let pantry = repository.getPantry()
        #expect(pantry.isEmpty)
    }

    @Test
    func exists_for_existing_ingredient_returns_true() throws {
        // Given
        let ingredient = Ingredient(name: "Olive Oil")
        try repository.add(ingredient)

        // When - Use the same ingredient instance since it has the UUID that was stored
        let exists = repository.exists(ingredient)

        // Then
        #expect(exists)
    }

    @Test
    func exists_for_nonexistent_ingredient_returns_false() throws {
        // Given
        let ingredient = Ingredient(name: "NonExistent")

        // When
        let exists = repository.exists(ingredient)

        // Then
        #expect(!exists)
    }

    @Test
    func exists_in_populated_pantry_returns_correct_result() throws {
        // Given
        let ingredient1 = Ingredient(name: "Rice")
        let ingredient2 = Ingredient(name: "Beans")
        let ingredient3 = Ingredient(name: "Lentils")
        
        try repository.add(ingredient1)
        try repository.add(ingredient2)

        // When - Check with original ingredients (same UUID)
        let exists1 = repository.exists(ingredient1)
        let exists2 = repository.exists(ingredient2)
        let exists3 = repository.exists(ingredient3)

        // Then
        #expect(exists1)
        #expect(exists2)
        #expect(!exists3)
    }
}
