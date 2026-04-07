import Testing
import Foundation

@testable import MiCocina

@Suite
struct RecipeDomainRepositoryTests {
    private var mockRepository: MockRecipeRepository
    private var repository: RecipeDomainRepository

    init() {
        let mockRepo = MockRecipeRepository()
        mockRepository = mockRepo
        repository = RecipeDomainRepository(RecipeProtocolRepository: mockRepo)
    }

    private func createTestRecipe(
        id: UUID = UUID(),
        name: String = "Test Recipe",
        mealType: MealType = .other,
        isFavorite: Bool = false
    ) -> Recipe {
        Recipe(
            id: id,
            name: name,
            ingredients: [],
            mealType: mealType,
            isFavorite: isFavorite
        )
    }

    @Test
    func getAll_delegates_to_underlying_repository() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Pasta")
        let recipe2 = createTestRecipe(name: "Pizza")
        try mockRepository.save(recipe1)
        try mockRepository.save(recipe2)

        // When
        let recipes = repository.getAll()

        // Then
        #expect(recipes.count == 2)
        #expect(recipes.contains { $0.id == recipe1.id })
        #expect(recipes.contains { $0.id == recipe2.id })
    }

    @Test
    func getAll_returns_empty_list_when_no_recipes() {
        // When
        let recipes = repository.getAll()

        // Then
        #expect(recipes.isEmpty)
    }

    @Test
    func getByID_returns_correct_recipe() throws {
        // Given
        let recipe = createTestRecipe(name: "Risotto")
        try mockRepository.save(recipe)

        // When
        let retrieved = repository.getByID(recipe.id)

        // Then
        #expect(retrieved?.id == recipe.id)
        #expect(retrieved?.name == "Risotto")
    }

    @Test
    func getByID_returns_nil_for_nonexistent_recipe() {
        // Given
        let nonexistentID = UUID()

        // When
        let recipe = repository.getByID(nonexistentID)

        // Then
        #expect(recipe == nil)
    }

    @Test
    func getByID_returns_correct_recipe_among_multiple() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Burger")
        let recipe2 = createTestRecipe(name: "Salad")
        let recipe3 = createTestRecipe(name: "Steak")
        try mockRepository.save(recipe1)
        try mockRepository.save(recipe2)
        try mockRepository.save(recipe3)

        // When
        let retrieved = repository.getByID(recipe2.id)

        // Then
        #expect(retrieved?.id == recipe2.id)
        #expect(retrieved?.name == "Salad")
    }

    @Test
    func getByName_returns_correct_recipe() throws {
        // Given
        let recipe = createTestRecipe(name: "Sushi")
        try mockRepository.save(recipe)

        // When
        let retrieved = repository.getByName("Sushi")

        // Then
        #expect(retrieved?.name == "Sushi")
    }

    @Test
    func getByName_returns_nil_for_nonexistent_recipe() {
        // When
        let recipe = repository.getByName("NonexistentRecipe")

        // Then
        #expect(recipe == nil)
    }

    @Test
    func getByMealType_returns_recipes_with_matching_type() throws {
        // Given
        let breakfast = createTestRecipe(name: "Eggs", mealType: .breakFast)
        let lunch = createTestRecipe(name: "Sandwich", mealType: .lunch)
        let dinner = createTestRecipe(name: "Steak", mealType: .dinner)
        try mockRepository.save(breakfast)
        try mockRepository.save(lunch)
        try mockRepository.save(dinner)

        // When
        let dinnerRecipes = repository.getByMealType(.dinner)

        // Then
        #expect(dinnerRecipes.count == 1)
        #expect(dinnerRecipes.first?.name == "Steak")
    }

    @Test
    func getByMealType_returns_empty_list_when_no_matching_type() throws {
        // Given
        let recipe = createTestRecipe(name: "Pasta", mealType: .lunch)
        try mockRepository.save(recipe)

        // When
        let snacks = repository.getByMealType(.other)

        // Then
        #expect(snacks.isEmpty)
    }

    @Test
    func getByMealType_returns_multiple_matching_recipes() throws {
        // Given
        let breakfast1 = createTestRecipe(name: "Pancakes", mealType: .breakFast)
        let breakfast2 = createTestRecipe(name: "Oatmeal", mealType: .breakFast)
        let lunch = createTestRecipe(name: "Tacos", mealType: .lunch)
        try mockRepository.save(breakfast1)
        try mockRepository.save(breakfast2)
        try mockRepository.save(lunch)

        // When
        let breakfasts = repository.getByMealType(.breakFast)

        // Then
        #expect(breakfasts.count == 2)
        #expect(breakfasts.contains { $0.name == "Pancakes" })
        #expect(breakfasts.contains { $0.name == "Oatmeal" })
    }

    @Test
    func getFavorites_returns_only_favorite_recipes() throws {
        // Given
        let favorite1 = createTestRecipe(name: "FavDish1", isFavorite: true)
        let favorite2 = createTestRecipe(name: "FavDish2", isFavorite: true)
        let notFavorite = createTestRecipe(name: "Regular", isFavorite: false)
        try mockRepository.save(favorite1)
        try mockRepository.save(favorite2)
        try mockRepository.save(notFavorite)

        // When
        let favorites = repository.getFavorites()

        // Then
        #expect(favorites.count == 2)
        #expect(favorites.contains { $0.name == "FavDish1" })
        #expect(favorites.contains { $0.name == "FavDish2" })
        #expect(!favorites.contains { $0.name == "Regular" })
    }

    @Test
    func getFavorites_returns_empty_list_when_no_favorites() throws {
        // Given
        try mockRepository.save(createTestRecipe(name: "Regular", isFavorite: false))

        // When
        let favorites = repository.getFavorites()

        // Then
        #expect(favorites.isEmpty)
    }

    @Test
    func save_adds_new_recipe() throws {
        // Given
        let recipe = createTestRecipe(name: "NewRecipe")

        // When
        try repository.save(recipe)

        // Then
        let retrieved = repository.getByID(recipe.id)
        #expect(retrieved?.name == "NewRecipe")
    }

    @Test
    func save_multiple_recipes_succeeds() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Recipe1")
        let recipe2 = createTestRecipe(name: "Recipe2")
        let recipe3 = createTestRecipe(name: "Recipe3")

        // When
        try repository.save(recipe1)
        try repository.save(recipe2)
        try repository.save(recipe3)

        // Then
        let all = repository.getAll()
        #expect(all.count == 3)
    }

    @Test
    func delete_removes_recipe_by_id() throws {
        // Given
        let recipe = createTestRecipe(name: "ToDelete")
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
        let recipe = createTestRecipe(name: "Never existed")

        // When & Then - Should not throw
        try repository.delete(recipe)
    }

    @Test
    func delete_correct_recipe_from_multiple() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Keep1")
        let recipe2 = createTestRecipe(name: "ToDelete")
        let recipe3 = createTestRecipe(name: "Keep2")
        try repository.save(recipe1)
        try repository.save(recipe2)
        try repository.save(recipe3)

        // When
        try repository.delete(recipe2)

        // Then
        let all = repository.getAll()
        #expect(all.count == 2)
        #expect(all.contains { $0.name == "Keep1" })
        #expect(!all.contains { $0.name == "ToDelete" })
        #expect(all.contains { $0.name == "Keep2" })
    }

    @Test
    func update_modifies_existing_recipe() throws {
        // Given
        var recipe = createTestRecipe(id: UUID(), name: "Original", isFavorite: false)
        try repository.save(recipe)
        let updatedRecipe = Recipe(
            id: recipe.id,
            name: "Updated",
            ingredients: [],
            mealType: .dinner,
            isFavorite: true
        )

        // When
        try repository.update(updatedRecipe)

        // Then
        let retrieved = repository.getByID(recipe.id)
        #expect(retrieved?.name == "Updated")
        #expect(retrieved?.isFavorite == true)
        #expect(retrieved?.mealType == .dinner)
    }

    @Test
    func update_nonexistent_recipe_does_not_throw() throws {
        // Given
        let recipe = createTestRecipe(name: "NonExistent")

        // When & Then - Should not throw
        try repository.update(recipe)
    }

    @Test
    func update_preserves_recipe_id() throws {
        // Given
        let originalID = UUID()
        let recipe = createTestRecipe(id: originalID, name: "Original")
        try repository.save(recipe)
        let updated = Recipe(
            id: originalID,
            name: "Updated",
            ingredients: [],
            mealType: .lunch,
            isFavorite: true
        )

        // When
        try repository.update(updated)

        // Then
        let retrieved = repository.getByID(originalID)
        #expect(retrieved?.id == originalID)
    }

    @Test
    func delegates_preserve_recipe_properties() throws {
        // Given
        let recipeID = UUID()
        let recipe = Recipe(
            id: recipeID,
            name: "Complex Recipe",
            ingredients: [],
            mealType: .dinner,
            isFavorite: true
        )
        try repository.save(recipe)

        // When
        let retrieved = repository.getByID(recipeID)

        // Then
        #expect(retrieved?.id == recipeID)
        #expect(retrieved?.name == "Complex Recipe")
        #expect(retrieved?.mealType == .dinner)
        #expect(retrieved?.isFavorite == true)
    }

    @Test
    func sequence_of_read_operations_succeeds() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Recipe1", mealType: .breakFast)
        let recipe2 = createTestRecipe(name: "Recipe2", mealType: .lunch, isFavorite: true)
        let recipe3 = createTestRecipe(name: "Recipe3", mealType: .lunch)
        try repository.save(recipe1)
        try repository.save(recipe2)
        try repository.save(recipe3)

        // When & Then
        #expect(repository.getAll().count == 3)
        #expect(repository.getByID(recipe1.id)?.name == "Recipe1")
        #expect(repository.getByName("Recipe2")?.id == recipe2.id)
        #expect(repository.getByMealType(.breakFast).count == 1)
        #expect(repository.getFavorites().count == 1)
    }

    @Test
    func sequence_of_write_operations_succeeds() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Add1")
        let recipe2 = createTestRecipe(name: "Add2")

        // When & Then - Add
        try repository.save(recipe1)
        try repository.save(recipe2)
        #expect(repository.getAll().count == 2)

        // Update
        let updated = Recipe(
            id: recipe1.id,
            name: "Modified",
            ingredients: [],
            mealType: .dinner,
            isFavorite: true
        )
        try repository.update(updated)
        #expect(repository.getByID(recipe1.id)?.name == "Modified")

        // Delete
        try repository.delete(recipe1)
        #expect(repository.getAll().count == 1)
        #expect(repository.getByID(recipe1.id) == nil)
    }

    @Test
    func mixed_operations_sequence_succeeds() throws {
        // Given
        let recipe1 = createTestRecipe(name: "Breakfast", mealType: .breakFast)
        let recipe2 = createTestRecipe(name: "Lunch", mealType: .lunch)
        let recipe3 = createTestRecipe(name: "Dinner", mealType: .dinner, isFavorite: true)

        // When & Then
        try repository.save(recipe1)
        #expect(repository.getAll().count == 1)

        try repository.save(recipe2)
        try repository.save(recipe3)
        #expect(repository.getAll().count == 3)

        #expect(repository.getFavorites().count == 1)
        #expect(repository.getByMealType(.lunch).count == 1)

        let updated = Recipe(
            id: recipe2.id,
            name: "Updated Lunch",
            ingredients: [],
            mealType: .lunch,
            isFavorite: true
        )
        try repository.update(updated)
        #expect(repository.getFavorites().count == 2)

        try repository.delete(recipe1)
        #expect(repository.getByMealType(.breakFast).isEmpty)
        #expect(repository.getAll().count == 2)
    }
}
