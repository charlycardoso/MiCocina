import Testing
import SwiftData
import Foundation

@testable import MiCocina

@Suite("MyPantryModuleViewModel Tests")
struct MyPantryModuleViewModelTests {

    // MARK: - Setup

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            SDPantryItem.self,
            SDRecipe.self,
            SDIngredient.self,
            SDRecipeIngredient.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    // MARK: - Initialization

    @MainActor @Test("Initializes with empty pantry when context is empty")
    func initWithEmptyContextHasEmptyPantry() throws {
        let container = try makeContainer()

        let viewModel = MyPantryModuleViewModel(context: container.mainContext)

        #expect(viewModel.pantry.isEmpty)
    }

    @MainActor @Test("Published pantry is populated from existing context data on init")
    func initPopulatesPantryFromExistingContext() throws {
        // Given – seed context via a first ViewModel
        let container = try makeContainer()
        let seed = MyPantryModuleViewModel(context: container.mainContext)
        let tomato = Ingredient(name: "Tomato")
        try seed.add(tomato)

        // When – create a second ViewModel over the same context
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)

        // Then – published pantry should reflect persisted data
        #expect(viewModel.pantry.count == 1)
        #expect(viewModel.pantry.first?.id == tomato.id)
        #expect(viewModel.pantry.first?.name == tomato.name)
    }

    // MARK: - getPantry

    @MainActor @Test("getPantry returns empty set when nothing has been added")
    func getPantryOnEmptyContextReturnsEmpty() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)

        #expect(viewModel.getPantry().isEmpty)
    }

    @MainActor @Test("getPantry returns all added ingredients")
    func getPantryReturnsAllIngredients() throws {
        // Given
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let tomato = Ingredient(name: "Tomato")
        let onion  = Ingredient(name: "Onion")

        // When
        try viewModel.add(tomato)
        try viewModel.add(onion)

        // Then – quantity is not persisted by SDIngredient, compare by id
        let pantry = viewModel.getPantry()
        #expect(pantry.count == 2)
        #expect(pantry.contains { $0.id == tomato.id })
        #expect(pantry.contains { $0.id == onion.id })
    }

    // MARK: - add

    @MainActor @Test("add stores a single ingredient in the pantry")
    func addSingleIngredientIsStored() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let garlic = Ingredient(name: "Garlic")

        try viewModel.add(garlic)

        let pantry = viewModel.getPantry()
        #expect(pantry.count == 1)
        #expect(pantry.contains { $0.id == garlic.id })
    }

    @MainActor @Test("add stores multiple distinct ingredients")
    func addMultipleIngredientsAllStored() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let ingredients = [
            Ingredient(name: "Salt"),
            Ingredient(name: "Pepper"),
            Ingredient(name: "Olive Oil"),
        ]

        for ingredient in ingredients {
            try viewModel.add(ingredient)
        }

        let pantry = viewModel.getPantry()
        #expect(pantry.count == 3)
        for ingredient in ingredients {
            #expect(pantry.contains { $0.id == ingredient.id })
        }
    }

    @MainActor @Test("add with same UUID does not duplicate the ingredient")
    func addSameIngredientTwiceDoesNotDuplicate() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let ingredient = Ingredient(name: "Rice", quantity: 1)

        try viewModel.add(ingredient)
        try viewModel.add(ingredient) // same UUID → update, not insert

        #expect(viewModel.getPantry().count == 1)
    }

    // MARK: - remove

    @MainActor @Test("remove deletes the target ingredient leaving others intact")
    func removeExistingIngredientLeavesOthers() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let tomato  = Ingredient(name: "Tomato")
        let lettuce = Ingredient(name: "Lettuce")
        try viewModel.add(tomato)
        try viewModel.add(lettuce)

        try viewModel.remove(tomato)

        let pantry = viewModel.getPantry()
        #expect(pantry.count == 1)
        #expect(!pantry.contains { $0.id == tomato.id })
        #expect(pantry.contains { $0.id == lettuce.id })
    }

    @MainActor @Test("remove a non-existent ingredient does not throw")
    func removeNonExistentIngredientDoesNotThrow() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let ghost = Ingredient(name: "NonExistent", quantity: 1)

        #expect(throws: Never.self) {
            try viewModel.remove(ghost)
        }
        #expect(viewModel.getPantry().isEmpty)
    }

    // MARK: - update

    @MainActor @Test("update an existing ingredient does not throw and keeps count")
    func updateExistingIngredientDoesNotThrow() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let ingredient = Ingredient(name: "Apple", quantity: 1)
        try viewModel.add(ingredient)

        #expect(throws: Never.self) {
            try viewModel.update(ingredient)
        }
        #expect(viewModel.getPantry().count == 1)
    }

    @MainActor @Test("update a non-existent ingredient does not throw")
    func updateNonExistentIngredientDoesNotThrow() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let ingredient = Ingredient(name: "Ghost", quantity: 1)

        #expect(throws: Never.self) {
            try viewModel.update(ingredient)
        }
    }

    // MARK: - clear

    @MainActor @Test("clear removes all ingredients from the pantry")
    func clearRemovesAllIngredients() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        try viewModel.add(Ingredient(name: "Milk",   quantity: 1))
        try viewModel.add(Ingredient(name: "Eggs",   quantity: 6))
        try viewModel.add(Ingredient(name: "Cheese", quantity: 2))
        #expect(viewModel.getPantry().count == 3)

        try viewModel.clear()

        #expect(viewModel.getPantry().isEmpty)
    }

    @MainActor @Test("clear on an already empty pantry does not throw")
    func clearEmptyPantrySucceeds() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)

        #expect(throws: Never.self) {
            try viewModel.clear()
        }
    }

    // MARK: - exists

    @MainActor @Test("exists returns true for an ingredient that was added")
    func existsReturnsTrueForAddedIngredient() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let butter = Ingredient(name: "Butter", quantity: 1)
        try viewModel.add(butter)

        #expect(viewModel.exists(butter))
    }

    @MainActor @Test("exists returns false for an ingredient that was never added")
    func existsReturnsFalseForMissingIngredient() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let truffle = Ingredient(name: "Truffle", quantity: 1)

        #expect(!viewModel.exists(truffle))
    }

    @MainActor @Test("exists returns false after the ingredient is removed")
    func existsReturnsFalseAfterRemoval() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let parsley = Ingredient(name: "Parsley", quantity: 1)
        try viewModel.add(parsley)
        #expect(viewModel.exists(parsley))

        try viewModel.remove(parsley)

        #expect(!viewModel.exists(parsley))
    }

    @MainActor @Test("exists returns false for all ingredients after clear")
    func existsReturnsFalseAfterClear() throws {
        let container = try makeContainer()
        let viewModel = MyPantryModuleViewModel(context: container.mainContext)
        let cumin = Ingredient(name: "Cumin", quantity: 1)
        try viewModel.add(cumin)

        try viewModel.clear()

        #expect(!viewModel.exists(cumin))
    }

    // MARK: - mockForPreview

    @MainActor @Test("mockForPreview creates a ViewModel with five pre-loaded ingredients")
    func mockForPreviewHasFiveIngredients() throws {
        let container = try makeContainer()

        let viewModel = MyPantryModuleViewModel.mockForPreview(context: container.mainContext)

        #expect(viewModel.pantry.count == 5)
    }

    @MainActor @Test("mockForPreview contains all expected ingredient names (normalized)")
    func mockForPreviewContainsExpectedIngredients() throws {
        let container = try makeContainer()

        let viewModel = MyPantryModuleViewModel.mockForPreview(context: container.mainContext)

        let names = Set(viewModel.pantry.map { $0.name })
        #expect(names.contains("tomate"))
        #expect(names.contains("leche"))
        #expect(names.contains("huevos"))
        #expect(names.contains("mantequilla"))
        #expect(names.contains("arroz"))
    }

    @MainActor @Test("mockForPreview ingredients all have quantity greater than zero")
    func mockForPreviewIngredientsHavePositiveQuantity() throws {
        let container = try makeContainer()

        let viewModel = MyPantryModuleViewModel.mockForPreview(context: container.mainContext)

        for ingredient in viewModel.pantry {
            #expect(ingredient.quantity > 0)
        }
    }
}
