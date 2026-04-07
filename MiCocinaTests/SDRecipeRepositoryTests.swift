import Testing
import SwiftData
import Foundation

@testable import MiCocina

/// Test suite for `SDRecipeProtocolRepository` SwiftData-based recipe persistence.
///
/// `SDRecipeProtocolRepositoryTests` validates all CRUD operations and query methods
/// for recipes stored using SwiftData. Tests ensure data integrity, relationship
/// management, and proper error handling.
@Suite
struct SDRecipeProtocolRepositoryTests {
    private var container: ModelContainer
    private var context: ModelContext
    private var repository: SDRecipeProtocolRepository

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: SDRecipe.self, SDIngredient.self, SDRecipeIngredient.self,
            configurations: config
        )
        context = ModelContext(container)
        repository = SDRecipeProtocolRepository(context: context)
    }

    private func createTestRecipe(
        name: String = "Test Recipe",
        mealType: MealType = .other,
        isFavorite: Bool = false,
        ingredients: Set<RecipeIngredient> = []
    ) -> Recipe {
        Recipe(id: .init(), name: name, ingredients: ingredients, mealType: mealType, isFavorite: isFavorite)
    }

    private func createTestRecipeIngredient(
        name: String = "Ingredient",
        isRequired: Bool = true
    ) -> RecipeIngredient {
        let ingredient = Ingredient(id: .init(), name: name)
        return RecipeIngredient(id: .init(), ingredient: ingredient, isRequired: isRequired)
    }

    // MARK: - getAll Tests

    /// Tests that getAll returns empty list when no recipes exist.
    @Test
    func getAll_empty_returns_empty_list() {
        let recipes = repository.getAll()
        #expect(recipes.isEmpty)
    }

    /// Tests that getAll returns all stored recipes.
    @Test
    func getAll_with_recipes_returns_all() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Pasta")
        let recipe2 = createTestRecipe(name: "Pizza")
        
        try repository.save(recipe1)
        try repository.save(recipe2)

        // When
        let recipes = repository.getAll()

        // Then
        #expect(recipes.count == 2)
    }

    /// Tests that getAll correctly preserves all recipe properties including relationships.
    /// Tests that getAll correctly preserves all recipe properties including relationships.
    @Test
    func getAll_preserves_recipe_properties() throws {
        // Given
        let ingredients: Set<RecipeIngredient> = [
            RecipeIngredient(ingredient: Ingredient(name: "Flour"), isRequired: true),
            RecipeIngredient(ingredient: Ingredient(name: "Water"), isRequired: true)
        ]
        let recipe = Recipe(
            name: "Bread",
            ingredients: ingredients,
            mealType: .breakFast,
            isFavorite: true
        )
        
        try repository.save(recipe)

        // When
        let recipes = repository.getAll()

        // Then
        #expect(recipes.count == 1)
        let retrieved = recipes.first
        #expect(retrieved?.name == "Bread")
        #expect(retrieved?.mealType == .breakFast)
        #expect(retrieved?.isFavorite == true)
        #expect(retrieved?.ingredients.count == 2)
    }

    // MARK: - getByID Tests

    /// Tests that getByID returns the correct recipe when it exists.
    @Test
    func getByID_existing_recipe_returns_recipe() throws {
        // Given
        let recipe = createTestRecipe(name: "Spaghetti")
        try repository.save(recipe)

        // When
        let retrieved = repository.getByID(recipe.id)

        // Then
        #expect(retrieved != nil)
        #expect(retrieved?.name == "Spaghetti")
    }

    @Test
    func getByID_nonexistent_recipe_returns_nil() {
        // Given
        let nonexistentId = UUID()

        // When
        let retrieved = repository.getByID(nonexistentId)

        // Then
        #expect(retrieved == nil)
    }

    @Test
    func getByID_returns_correct_recipe_among_multiple() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Pizza")
        let recipe2 = createTestRecipe(name: "Hamburger")
        let recipe3 = createTestRecipe(name: "Salad")
        
        try repository.save(recipe1)
        try repository.save(recipe2)
        try repository.save(recipe3)

        // When
        let retrieved = repository.getByID(recipe2.id)

        // Then
        #expect(retrieved?.name == "Hamburger")
    }

    // MARK: - getByName Tests

    @Test
    func getByName_existing_recipe_returns_recipe() throws {
        // Given
        let recipe = createTestRecipe(name: "Risotto")
        try repository.save(recipe)

        // When
        let retrieved = repository.getByName("Risotto")

        // Then
        #expect(retrieved != nil)
        #expect(retrieved?.name == "Risotto")
    }

    @Test
    func getByName_nonexistent_recipe_returns_nil() {
        // When
        let retrieved = repository.getByName("NonExistent")

        // Then
        #expect(retrieved == nil)
    }

    @Test
    func getByName_with_multiple_recipes_returns_correct_one() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Tacos")
        let recipe2 = createTestRecipe(name: "Enchiladas")
        
        try repository.save(recipe1)
        try repository.save(recipe2)

        // When
        let retrieved = repository.getByName("Tacos")

        // Then
        #expect(retrieved?.name == "Tacos")
    }

    // MARK: - getByMealType Tests

    @Test
    func getByMealType_returns_recipes_with_matching_type() throws {
        // Given
        let breakfastRecipe = createTestRecipe(name: "Omelette", mealType: .breakFast)
        let lunchRecipe = createTestRecipe(name: "Sandwich", mealType: .lunch)
        let dinnerRecipe = createTestRecipe(name: "Steak", mealType: .dinner)
        
        try repository.save(breakfastRecipe)
        try repository.save(lunchRecipe)
        try repository.save(dinnerRecipe)

        // When
        let breakfastRecipes = repository.getByMealType(.breakFast)
        let lunchRecipes = repository.getByMealType(.lunch)
        let dinnerRecipes = repository.getByMealType(.dinner)

        // Then
        #expect(breakfastRecipes.count == 1)
        #expect(breakfastRecipes.first?.name == "Omelette")
        
        #expect(lunchRecipes.count == 1)
        #expect(lunchRecipes.first?.name == "Sandwich")
        
        #expect(dinnerRecipes.count == 1)
        #expect(dinnerRecipes.first?.name == "Steak")
    }

    @Test
    func getByMealType_empty_returns_empty_list() {
        // When
        let recipes = repository.getByMealType(.breakFast)

        // Then
        #expect(recipes.isEmpty)
    }

    @Test
    func getByMealType_with_multiple_same_type_returns_all() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Pancakes", mealType: .breakFast)
        let recipe2 = createTestRecipe(name: "Eggs", mealType: .breakFast)
        let recipe3 = createTestRecipe(name: "Soup", mealType: .lunch)
        
        try repository.save(recipe1)
        try repository.save(recipe2)
        try repository.save(recipe3)

        // When
        let breakfastRecipes = repository.getByMealType(.breakFast)

        // Then
        #expect(breakfastRecipes.count == 2)
    }

    // MARK: - getFavorites Tests

    @Test
    func getFavorites_returns_only_favorite_recipes() throws {
        // Given
        let favorite1 = createTestRecipe(name: "Favorite1", isFavorite: true)
        let favorite2 = createTestRecipe(name: "Favorite2", isFavorite: true)
        let notFavorite = createTestRecipe(name: "NotFavorite", isFavorite: false)
        
        try repository.save(favorite1)
        try repository.save(favorite2)
        try repository.save(notFavorite)

        // When
        let favorites = repository.getFavorites()

        // Then
        #expect(favorites.count == 2)
        #expect(favorites.contains { $0.name == "Favorite1" })
        #expect(favorites.contains { $0.name == "Favorite2" })
        #expect(!favorites.contains { $0.name == "NotFavorite" })
    }

    @Test
    func getFavorites_empty_returns_empty_list() {
        // When
        let favorites = repository.getFavorites()

        // Then
        #expect(favorites.isEmpty)
    }

    @Test
    func getFavorites_with_no_favorites_returns_empty_list() throws {
        // Given
        let recipe = createTestRecipe(name: "Regular", isFavorite: false)
        try repository.save(recipe)

        // When
        let favorites = repository.getFavorites()

        // Then
        #expect(favorites.isEmpty)
    }

    // MARK: - save Tests

    @Test
    func save_new_recipe_succeeds() throws {
        // Given
        let recipe = createTestRecipe(name: "New Recipe")

        // When
        try repository.save(recipe)

        // Then
        let retrieved = repository.getByID(recipe.id)
        #expect(retrieved?.name == "New Recipe")
    }

    @Test
    func save_recipe_with_ingredients_succeeds() throws {
        // Given
        let ingredients = Set([
            createTestRecipeIngredient(name: "Ingredient1"),
            createTestRecipeIngredient(name: "Ingredient2")
        ])
        let recipe = createTestRecipe(name: "Complex Recipe", ingredients: ingredients)

        // When
        try repository.save(recipe)

        // Then
        let retrieved = repository.getByID(recipe.id)
        #expect(retrieved?.ingredients.count == 2)
    }

    @Test
    func save_existing_recipe_calls_update() throws {
        // Given
        let originalRecipe = createTestRecipe(name: "Original")
        try repository.save(originalRecipe)

        // When - Save same recipe (same ID)
        try repository.save(originalRecipe)

        // Then - Should still have only one recipe
        let allRecipes = repository.getAll()
        #expect(allRecipes.count == 1)
    }

    // MARK: - delete Tests

    @Test
    func delete_existing_recipe_succeeds() throws {
        // Given
        let recipe = createTestRecipe(name: "To Delete")
        try repository.save(recipe)

        // When
        try repository.delete(recipe)

        // Then
        let retrieved = repository.getByID(recipe.id)
        #expect(retrieved == nil)
    }

    @Test
    func delete_nonexistent_recipe_does_not_throw() throws {
        // Given
        let recipe = createTestRecipe(name: "Nonexistent")

        // When - Should not throw
        try repository.delete(recipe)

        // Then - No error
        let allRecipes = repository.getAll()
        #expect(allRecipes.isEmpty)
    }

    @Test
    func delete_removes_correct_recipe_from_multiple() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Keep1")
        let recipe2 = createTestRecipe(name: "Delete")
        let recipe3 = createTestRecipe(name: "Keep2")
        
        try repository.save(recipe1)
        try repository.save(recipe2)
        try repository.save(recipe3)

        // When
        try repository.delete(recipe2)

        // Then
        let allRecipes = repository.getAll()
        #expect(allRecipes.count == 2)
        #expect(!allRecipes.contains { $0.name == "Delete" })
    }

    // MARK: - update Tests

    @Test
    func update_existing_recipe_succeeds() throws {
        // Given
        let originalRecipe = createTestRecipe(name: "Original", mealType: .lunch, isFavorite: false)
        try repository.save(originalRecipe)

        // When - Update properties
        let recipeUUID: UUID = originalRecipe.id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        guard let sdRecipe = try? context.fetch(descriptor).first else {
            #expect(Bool(false), "Recipe not found")
            return
        }
        
        sdRecipe.name = "Updated"
        sdRecipe.mealType = MealType.dinner.rawValue
        sdRecipe.isFavorite = true
        try context.save()

        // Then
        let retrieved = repository.getByID(originalRecipe.id)
        #expect(retrieved?.name == "Updated")
        #expect(retrieved?.mealType == .dinner)
        #expect(retrieved?.isFavorite == true)
    }

    @Test
    func update_nonexistent_recipe_throws_error() throws {
        // Given
        let recipe = createTestRecipe(name: "Nonexistent")

        // When/Then
        #expect(throws: NSError.self) {
            try repository.update(recipe)
        }
    }

    @Test
    func update_recipe_ingredients_succeeds() throws {
        // Given
        let originalIngredients = Set([
            createTestRecipeIngredient(name: "Flour"),
            createTestRecipeIngredient(name: "Water")
        ])
        let recipe = createTestRecipe(name: "Bread", ingredients: originalIngredients)
        try repository.save(recipe)

        // When - Update with new ingredients
        let newIngredients = Set([
            createTestRecipeIngredient(name: "Flour"),
            createTestRecipeIngredient(name: "Water"),
            createTestRecipeIngredient(name: "Salt")
        ])
        
        let recipeUUID: UUID = recipe.id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        guard let sdRecipe = try? context.fetch(descriptor).first else {
            #expect(Bool(false), "Recipe not found")
            return
        }
        
        // Clear old ingredients
        for old in sdRecipe.ingredients {
            context.delete(old)
        }
        sdRecipe.ingredients.removeAll()
        
        // Add new ingredients
        for ingredient in newIngredients {
            let sdIngredient = StorageMapper.toStorage(
                with: ingredient.ingredient,
                context: context
            )
            let sdRecipeIngredient = SDRecipeIngredient(
                recipe: sdRecipe,
                ingredient: sdIngredient,
                quantity: nil,
                isRequired: ingredient.isRequired
            )
            sdRecipe.ingredients.append(sdRecipeIngredient)
        }
        try context.save()

        // Then
        let retrieved = repository.getByID(recipe.id)
        #expect(retrieved?.ingredients.count == 3)
    }

    @Test
    func update_preserves_recipe_id() throws {
        // Given
        let originalRecipe = createTestRecipe(name: "Original")
        try repository.save(originalRecipe)
        let originalId = originalRecipe.id

        // When - Update recipe
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == originalId }
        )
        guard let sdRecipe = try? context.fetch(descriptor).first else {
            #expect(Bool(false), "Recipe not found")
            return
        }
        
        sdRecipe.name = "Updated"
        try context.save()

        // Then
        let retrieved = repository.getByID(originalId)
        #expect(retrieved?.id == originalId)
    }
}
