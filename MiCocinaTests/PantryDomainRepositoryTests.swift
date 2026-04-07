import Testing
import Foundation

@testable import MiCocina

@Suite
struct PantryDomainRepositoryTests {
    private var mockRepository: MockPantryRepository
    private var repository: PantryDomainRepository

    init() {
        let mockRepo = MockPantryRepository()
        mockRepository = mockRepo
        repository = PantryDomainRepository(PantryProtocolRepository: mockRepo)
    }

    @Test
    func getPantry_delegates_to_underlying_repository() throws {
        // Given
        let ingredient1 = Ingredient(name: "Flour")
        let ingredient2 = Ingredient(name: "Sugar")
        try mockRepository.add(ingredient1)
        try mockRepository.add(ingredient2)

        // When
        let pantry = repository.getPantry()

        // Then
        #expect(pantry.count == 2)
        #expect(pantry.contains(ingredient1))
        #expect(pantry.contains(ingredient2))
    }

    @Test
    func getPantry_returns_empty_set_when_no_ingredients() {
        // When
        let pantry = repository.getPantry()

        // Then
        #expect(pantry.isEmpty)
    }

    @Test
    func add_ingredient_delegates_to_underlying_repository() throws {
        // Given
        let ingredient = Ingredient(name: "Butter")

        // When
        try repository.add(ingredient)

        // Then
        let pantry = repository.getPantry()
        #expect(pantry.contains(ingredient))
    }

    @Test
    func add_multiple_ingredients_succeeds() throws {
        // Given
        let ingredient1 = Ingredient(name: "Eggs")
        let ingredient2 = Ingredient(name: "Milk")
        let ingredient3 = Ingredient(name: "Salt")

        // When
        try repository.add(ingredient1)
        try repository.add(ingredient2)
        try repository.add(ingredient3)

        // Then
        let pantry = repository.getPantry()
        #expect(pantry.count == 3)
        #expect(pantry.contains(ingredient1))
        #expect(pantry.contains(ingredient2))
        #expect(pantry.contains(ingredient3))
    }

    @Test
    func remove_ingredient_delegates_to_underlying_repository() throws {
        // Given
        let ingredient = Ingredient(name: "Pepper")
        try repository.add(ingredient)

        // When
        try repository.remove(ingredient)

        // Then
        let pantry = repository.getPantry()
        #expect(!pantry.contains(ingredient))
    }

    @Test
    func remove_nonexistent_ingredient_succeeds() throws {
        // Given
        let ingredient = Ingredient(name: "NonExistent")

        // When & Then - Should not throw
        try repository.remove(ingredient)
    }

    @Test
    func remove_specific_ingredient_from_multiple() throws {
        // Given
        let ingredient1 = Ingredient(name: "Garlic")
        let ingredient2 = Ingredient(name: "Onion")
        try repository.add(ingredient1)
        try repository.add(ingredient2)

        // When
        try repository.remove(ingredient1)

        // Then
        let pantry = repository.getPantry()
        #expect(pantry.count == 1)
        #expect(!pantry.contains(ingredient1))
        #expect(pantry.contains(ingredient2))
    }

    @Test
    func update_ingredient_delegates_to_underlying_repository() throws {
        // Given
        let ingredient = Ingredient(id: UUID(), name: "Tomato")
        try repository.add(ingredient)
        let updatedIngredient = Ingredient(id: ingredient.id, name: "Cherry Tomato")

        // When
        try repository.update(updatedIngredient)

        // Then
        let pantry = repository.getPantry()
        #expect(pantry.contains(updatedIngredient))
    }

    @Test
    func update_nonexistent_ingredient_succeeds() throws {
        // Given
        let ingredient = Ingredient(name: "Ghost Ingredient")

        // When & Then - Should not throw
        try repository.update(ingredient)
    }

    @Test
    func clear_removes_all_ingredients() throws {
        // Given
        try repository.add(Ingredient(name: "Basil"))
        try repository.add(Ingredient(name: "Oregano"))
        try repository.add(Ingredient(name: "Thyme"))

        // When
        try repository.clear()

        // Then
        let pantry = repository.getPantry()
        #expect(pantry.isEmpty)
    }

    @Test
    func clear_on_empty_pantry_succeeds() throws {
        // When & Then - Should not throw
        try repository.clear()
        let pantry = repository.getPantry()
        #expect(pantry.isEmpty)
    }

    @Test
    func exists_returns_true_for_present_ingredient() throws {
        // Given
        let ingredient = Ingredient(name: "Honey")
        try repository.add(ingredient)

        // When
        let exists = repository.exists(ingredient)

        // Then
        #expect(exists)
    }

    @Test
    func exists_returns_false_for_absent_ingredient() {
        // Given
        let ingredient = Ingredient(name: "Absent Ingredient")

        // When
        let exists = repository.exists(ingredient)

        // Then
        #expect(!exists)
    }

    @Test
    func exists_with_multiple_ingredients() throws {
        // Given
        let ingredient1 = Ingredient(name: "Coconut")
        let ingredient2 = Ingredient(name: "Almond")
        let ingredient3 = Ingredient(name: "Walnut")
        try repository.add(ingredient1)
        try repository.add(ingredient2)

        // When
        let existsIngredient1 = repository.exists(ingredient1)
        let existsIngredient2 = repository.exists(ingredient2)
        let existsIngredient3 = repository.exists(ingredient3)

        // Then
        #expect(existsIngredient1)
        #expect(existsIngredient2)
        #expect(!existsIngredient3)
    }

    @Test
    func delegates_preserve_ingredient_identity() throws {
        // Given
        let ingredientID = UUID()
        let ingredient = Ingredient(id: ingredientID, name: "Original Name")
        try repository.add(ingredient)

        // When
        let pantry = repository.getPantry()
        let retrievedIngredient = pantry.first { $0.id == ingredientID }

        // Then
        #expect(retrievedIngredient?.id == ingredientID)
        // Name gets normalized (lowercase, no diacritics) during Ingredient initialization
        #expect(retrievedIngredient?.name == ingredient.name)
    }

    @Test
    func sequence_of_operations_succeeds() throws {
        // Given
        let ingredient1 = Ingredient(name: "Rice")
        let ingredient2 = Ingredient(name: "Beans")
        let ingredient3 = Ingredient(name: "Lentils")

        // When & Then - Perform sequence of operations
        try repository.add(ingredient1)
        #expect(repository.exists(ingredient1))

        try repository.add(ingredient2)
        try repository.add(ingredient3)
        var pantry = repository.getPantry()
        #expect(pantry.count == 3)

        try repository.remove(ingredient2)
        pantry = repository.getPantry()
        #expect(pantry.count == 2)
        #expect(!repository.exists(ingredient2))

        try repository.clear()
        pantry = repository.getPantry()
        #expect(pantry.isEmpty)
    }
}
