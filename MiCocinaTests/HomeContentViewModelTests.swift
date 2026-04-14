import Testing
import SwiftData
import Foundation

@testable import MiCocina

@Suite("HomeContentViewModel Tests")
struct HomeContentViewModelTests {
    
    // MARK: - Test Setup
    
    private func createInMemoryModelContainer() -> ModelContainer {
        let schema = Schema([
            SDRecipe.self,
            SDIngredient.self,
            SDRecipeIngredient.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }
    
    private func createTestIngredient(name: String, quantity: Double = 1.0, unit: String = "unit") -> Ingredient {
        Ingredient(name: name)
    }
    
    private func createTestRecipe(
        id: UUID = UUID(),
        name: String = "Test Recipe",
        mealType: MealType = .other,
        isFavorite: Bool = false,
        ingredients: Set<RecipeIngredient> = .init()
    ) -> Recipe {
        Recipe(
            id: id,
            name: name,
            ingredients: ingredients,
            mealType: mealType,
            isFavorite: isFavorite
        )
    }
    
    // MARK: - Initialization Tests
    
    @MainActor @Test("ViewModel initializes with empty recipes and possibleRecipes")
    func initializationState() throws {
        // Given
        let container = createInMemoryModelContainer()
        
        // When
        let viewModel = HomeContentViewModel(context: container.mainContext)
        
        // Then
        #expect(viewModel.recipes.isEmpty)
        #expect(viewModel.possibleRecipes.isEmpty)
    }
    
    @MainActor @Test("Preview mode initialization sets isPreviewMode correctly")
    func previewModeInitialization() throws {
        // Given
        let container = createInMemoryModelContainer()
        
        // When
        let viewModel = HomeContentViewModel(context: container.mainContext, isPreviewMode: true)
        
        // Then - Preview mode should not crash when calling getAllRecipes
        viewModel.getAllRecipes()
        #expect(viewModel.recipes.isEmpty) // Should remain empty in preview mode
    }
    
    // MARK: - Mock for Preview Tests
    
    @MainActor @Test("Mock for preview creates expected recipe structure")
    func mockForPreviewStructure() throws {
        // Given
        let container = createInMemoryModelContainer()
        
        // When
        let mockViewModel = HomeContentViewModel.mockForPreview(context: container.mainContext)
        
        // Then
        #expect(!mockViewModel.recipes.isEmpty)
        #expect(mockViewModel.recipes.count == 3) // breakfast, lunch, dinner
        
        // Verify meal types are represented
        let mealTypes = Set(mockViewModel.recipes.map { $0.mealType })
        #expect(mealTypes.contains(.breakFast))
        #expect(mealTypes.contains(.lunch))
        #expect(mealTypes.contains(.dinner))
    }
    
    @MainActor @Test("Mock for preview has expected breakfast recipes")
    func mockForPreviewBreakfastRecipes() throws {
        // Given
        let container = createInMemoryModelContainer()
        
        // When
        let mockViewModel = HomeContentViewModel.mockForPreview(context: container.mainContext)
        
        // Then
        let breakfastGroup = mockViewModel.recipes.first { $0.mealType == .breakFast }
        #expect(breakfastGroup != nil)
        #expect(breakfastGroup!.recipes.count == 3)
        
        let recipeNames = breakfastGroup!.recipes.map { $0.name }
        #expect(recipeNames.contains("Huevos Revueltos"))
        #expect(recipeNames.contains("Tostadas Francesas"))
        #expect(recipeNames.contains("Panqueques"))
    }
    
    @MainActor @Test("Mock for preview has correct favorite and cookable status")
    func mockForPreviewRecipeProperties() throws {
        // Given
        let container = createInMemoryModelContainer()
        
        // When
        let mockViewModel = HomeContentViewModel.mockForPreview(context: container.mainContext)
        
        // Then
        let allRecipes = mockViewModel.recipes.flatMap { $0.recipes }
        
        // Check favorites
        let favorites = allRecipes.filter { $0.isFavorite }
        #expect(favorites.count == 3) // Should have 3 favorites across all meal types
        
        // Check cookable recipes
        let cookableRecipes = allRecipes.filter { $0.canCook }
        #expect(!cookableRecipes.isEmpty)
        
        // Check non-cookable recipes
        let nonCookableRecipes = allRecipes.filter { !$0.canCook }
        #expect(!nonCookableRecipes.isEmpty)
    }
    
    // MARK: - Repository Integration Tests
    
    @MainActor @Test("ViewModel conforms to PantryProtocolRepository")
    func pantryRepositoryConformance() throws {
        // Given
        let container = createInMemoryModelContainer()
        let viewModel = HomeContentViewModel(context: container.mainContext)
        let testIngredient = createTestIngredient(name: "Tomato")
        
        // When & Then - These methods should be available
        let initialPantry = viewModel.getPantry()
        #expect(initialPantry.isEmpty)
        
        // Test adding ingredient
        try viewModel.add(testIngredient)
        #expect(viewModel.exists(testIngredient))
        
        let pantryAfterAdd = viewModel.getPantry()
        #expect(pantryAfterAdd.count == 1)
        
        // Test removing ingredient
        try viewModel.remove(testIngredient)
        #expect(!viewModel.exists(testIngredient))
        
        let pantryAfterRemove = viewModel.getPantry()
        #expect(pantryAfterRemove.isEmpty)
    }
    
    @MainActor @Test("ViewModel conforms to RecipeProtocolRepository")
    func recipeRepositoryConformance() throws {
        // Given
        let container = createInMemoryModelContainer()
        let viewModel = HomeContentViewModel(context: container.mainContext)
        let testRecipe = createTestRecipe(name: "Test Recipe", mealType: .lunch)
        
        // When & Then - These methods should be available
        let initialRecipes = viewModel.getAll()
        #expect(initialRecipes.isEmpty)
        
        // Test saving recipe
        try viewModel.save(testRecipe)
        
        let recipesAfterSave = viewModel.getAll()
        #expect(recipesAfterSave.count == 1)
        
        // Test getting by ID
        let retrievedRecipe = viewModel.getByID(testRecipe.id)
        #expect(retrievedRecipe != nil)
        #expect(retrievedRecipe!.id == testRecipe.id)
        
        // Test getting by name
        let recipeByName = viewModel.getByName("Test Recipe")
        #expect(recipeByName != nil)
        #expect(recipeByName!.name == "Test Recipe")
        
        // Test getting by meal type
        let lunchRecipes = viewModel.getByMealType(.lunch)
        #expect(lunchRecipes.count == 1)
        #expect(lunchRecipes.first!.id == testRecipe.id)
    }
    
    @MainActor @Test("ViewModel handles favorite recipes correctly")
    func favoriteRecipeHandling() throws {
        // Given
        let container = createInMemoryModelContainer()
        let viewModel = HomeContentViewModel(context: container.mainContext)
        let favoriteRecipe = createTestRecipe(name: "Favorite Recipe", isFavorite: true)
        let regularRecipe = createTestRecipe(name: "Regular Recipe", isFavorite: false)
        
        // When
        try viewModel.save(favoriteRecipe)
        try viewModel.save(regularRecipe)
        
        // Then
        let favorites = viewModel.getFavorites()
        #expect(favorites.count == 1)
        #expect(favorites.first!.id == favoriteRecipe.id)
        #expect(favorites.first!.isFavorite == true)
    }
    
    @MainActor @Test("ViewModel can update recipes")
    func recipeUpdating() throws {
        // Given
        let container = createInMemoryModelContainer()
        let viewModel = HomeContentViewModel(context: container.mainContext)
        let originalRecipe = createTestRecipe(name: "Original Recipe", isFavorite: false)
        
        // When
        try viewModel.save(originalRecipe)
        
        let updatedRecipe = Recipe(
            id: originalRecipe.id,
            name: "Updated Recipe",
            ingredients: originalRecipe.ingredients,
            mealType: originalRecipe.mealType,
            isFavorite: true
        )
        
        try viewModel.update(updatedRecipe)
        
        // Then
        let retrievedRecipe = viewModel.getByID(originalRecipe.id)
        #expect(retrievedRecipe != nil)
        #expect(retrievedRecipe!.name == "Updated Recipe")
        #expect(retrievedRecipe!.isFavorite == true)
    }
    
    @MainActor @Test("ViewModel can delete recipes")
    func recipeDeletion() throws {
        // Given
        let container = createInMemoryModelContainer()
        let viewModel = HomeContentViewModel(context: container.mainContext)
        let testRecipe = createTestRecipe(name: "Recipe to Delete")
        
        // When
        try viewModel.save(testRecipe)
        #expect(viewModel.getAll().count == 1)
        
        try viewModel.delete(testRecipe)
        
        // Then
        #expect(viewModel.getAll().isEmpty)
        #expect(viewModel.getByID(testRecipe.id) == nil)
    }
    
    @MainActor @Test("ViewModel pantry operations work with multiple ingredients")
    func pantryMultipleIngredients() throws {
        // Given
        let container = createInMemoryModelContainer()
        let viewModel = HomeContentViewModel(context: container.mainContext)
        let tomato = createTestIngredient(name: "Tomato", quantity: 2.0, unit: "pieces")
        let onion = createTestIngredient(name: "Onion", quantity: 1.0, unit: "piece")
        let garlic = createTestIngredient(name: "Garlic", quantity: 3.0, unit: "cloves")
        
        // When
        try viewModel.add(tomato)
        try viewModel.add(onion)
        try viewModel.add(garlic)
        
        // Then
        let pantry = viewModel.getPantry()
        #expect(pantry.count == 3)
        #expect(viewModel.exists(tomato))
        #expect(viewModel.exists(onion))
        #expect(viewModel.exists(garlic))
    }
    
    @MainActor @Test("ViewModel can clear pantry")
    func pantryClearing() throws {
        // Given
        let container = createInMemoryModelContainer()
        let viewModel = HomeContentViewModel(context: container.mainContext)
        let ingredient1 = createTestIngredient(name: "Ingredient 1")
        let ingredient2 = createTestIngredient(name: "Ingredient 2")
        
        // When
        try viewModel.add(ingredient1)
        try viewModel.add(ingredient2)
        #expect(viewModel.getPantry().count == 2)
        
        try viewModel.clear()
        
        // Then
        #expect(viewModel.getPantry().isEmpty)
        #expect(!viewModel.exists(ingredient1))
        #expect(!viewModel.exists(ingredient2))
    }
    
    // MARK: - Edge Case Tests
    
    @MainActor @Test("getAllRecipes in preview mode doesn't crash")
    func getAllRecipesPreviewModeSafety() throws {
        // Given
        let container = createInMemoryModelContainer()
        let viewModel = HomeContentViewModel(context: container.mainContext, isPreviewMode: true)
        
        // When & Then - Should not crash
        viewModel.getAllRecipes()
        #expect(viewModel.recipes.isEmpty) // Should remain empty
    }
    
    @MainActor @Test("getPossibleRecipes in preview mode doesn't crash")
    func getPossibleRecipesPreviewModeSafety() throws {
        // Given
        let container = createInMemoryModelContainer()
        let viewModel = HomeContentViewModel(context: container.mainContext, isPreviewMode: true)
        
        // When & Then - Should not crash
        viewModel.getPossibleRecipes()
        #expect(viewModel.possibleRecipes.isEmpty) // Should remain empty
    }
}

// MARK: - Published Properties Test Suite

@Suite("HomeContentViewModel Published Properties")
struct HomeContentViewModelPublishedPropertiesTests {
    
    private func createInMemoryModelContainer() -> ModelContainer {
        let schema = Schema([
            SDRecipe.self,
            SDIngredient.self,
            SDRecipeIngredient.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }
    
    @Test("Published properties are observable")
    func publishedPropertiesObservable() async throws {
        // Given
        let container = createInMemoryModelContainer()
        let viewModel = await HomeContentViewModel(context: container.mainContext)
        
        // When & Then - Should be able to access @Published properties
        #expect(viewModel.recipes.isEmpty)
        #expect(viewModel.possibleRecipes.isEmpty)
        
        // Mock data assignment should work
        let mockGroup = RecipeGroup(mealType: .lunch, recipes: [
            RecipeViewData(
                id: UUID(),
                name: "Test Recipe",
                mealType: .lunch,
                isFavorite: false,
                canCook: true,
                missingCount: 0
            )
        ])
        
        viewModel.recipes = [mockGroup]
        #expect(viewModel.recipes.count == 1)
        #expect(viewModel.recipes.first?.mealType == .lunch)
    }
}
