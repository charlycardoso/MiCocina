//
//  HomeContentViewModel.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation
import SwiftData
import Combine

final class HomeContentViewModel: ObservableObject {
    
    // MARK: Properties
    private let context: ModelContext
    private let isPreviewMode: Bool
    
    private var pantryRepo: PantryDomainRepository {
        .init(PantryProtocolRepository: SDPantryProtocolRepository(context: context))
    }
    private var recipeRepo: RecipeDomainRepository {
        .init(RecipeProtocolRepository: SDRecipeProtocolRepository(context: context))
    }
    private var matcher: RecipeUseCasesImpl {
        .init(
            RecipeProtocolRepository: recipeRepo,
            PantryProtocolRepository: pantryRepo,
            matcher: .init()
        )
    }

    // MARK: Published properties
    @Published var recipes: [RecipeGroup] = []
    @Published var possibleRecipes: [RecipeGroup] = []
    
    init(context: ModelContext, isPreviewMode: Bool = false) {
        self.context = context
        self.isPreviewMode = isPreviewMode
    }

    // MARK: Methods
    func getAllRecipes(){
        // Don't try to access repositories in preview mode
        guard !isPreviewMode else { return }
        
        let recipes = matcher.getAllRecipes()
        self.recipes = recipes
    }

    func getPossibleRecipes() {
        // Don't try to access repositories in preview mode
        guard !isPreviewMode else { return }
        
        let recipes = matcher.getPossibleRecipes()
        self.possibleRecipes = recipes
    }
}

// MARK: Shopping List methods
extension HomeContentViewModel {
    func addToShoppingList(_ ingredientName: String) {
        let shoppingListRepo = SDShoppingListRepository(context: context)
        let item = ShoppingListItem(ingredient: Ingredient(name: ingredientName))
        do {
            try shoppingListRepo.addItem(item)
        } catch {
            print("Error adding ingredient to shopping list: \(error)")
        }
    }
}

// MARK: Pantry Repository methods
extension HomeContentViewModel: PantryProtocolRepository {
    func getPantry() -> Set<Ingredient> {
        pantryRepo.getPantry()
    }
    
    func add(_ ingredient: Ingredient) throws {
        try pantryRepo.add(ingredient)
    }
    
    func remove(_ ingredient: Ingredient) throws {
        try pantryRepo.remove(ingredient)
    }
    
    func update(_ ingredient: Ingredient) throws {
        try pantryRepo.update(ingredient)
    }
    
    func clear() throws {
        try pantryRepo.clear()
    }
    
    func exists(_ ingredient: Ingredient) -> Bool {
        pantryRepo.exists(ingredient)
    }
}

// MARK: Recipe Repository methods
extension HomeContentViewModel: RecipeProtocolRepository {
    func getAll() -> [Recipe] {
        recipeRepo.getAll()
    }
    
    func getByID(_ id: UUID) -> Recipe? {
        recipeRepo.getByID(id)
    }
    
    func getByName(_ name: String) -> Recipe? {
        recipeRepo.getByName(name)
    }
    
    func getByMealType(_ mealType: MealType) -> [Recipe] {
        recipeRepo.getByMealType(mealType)
    }
    
    func getFavorites() -> [Recipe] {
        recipeRepo.getFavorites()
    }
    
    func save(_ recipe: Recipe) throws {
        try recipeRepo.save(recipe)
    }
    
    func delete(_ recipe: Recipe) throws {
        try recipeRepo.delete(recipe)
    }
    
    func update(_ recipe: Recipe) throws {
        try recipeRepo.update(recipe)
    }
}

// MARK: Mocks
extension HomeContentViewModel {
    static func mockForPreview(context: ModelContext) -> HomeContentViewModel {
        let vm = HomeContentViewModel(context: context, isPreviewMode: true)
        vm.recipes = [
            RecipeGroup(mealType: .breakFast, recipes: [
                RecipeViewData(id: UUID(), name: "Huevos Revueltos", mealType: .breakFast, isFavorite: true, canCook: true, missingCount: 0),
                RecipeViewData(id: UUID(), name: "Tostadas Francesas", mealType: .breakFast, isFavorite: false, canCook: true, missingCount: 0),
                RecipeViewData(id: UUID(), name: "Panqueques", mealType: .breakFast, isFavorite: false, canCook: false, missingCount: 1)
            ]),
            RecipeGroup(mealType: .lunch, recipes: [
                RecipeViewData(id: UUID(), name: "Ensalada César", mealType: .lunch, isFavorite: true, canCook: false, missingCount: 2),
                RecipeViewData(id: UUID(), name: "Pasta Alfredo", mealType: .lunch, isFavorite: false, canCook: true, missingCount: 0),
                RecipeViewData(id: UUID(), name: "Sandwich Club", mealType: .lunch, isFavorite: false, canCook: false, missingCount: 3)
            ]),
            RecipeGroup(mealType: .dinner, recipes: [
                RecipeViewData(id: UUID(), name: "Pollo a la Parrilla", mealType: .dinner, isFavorite: true, canCook: true, missingCount: 0),
                RecipeViewData(id: UUID(), name: "Salmón Teriyaki", mealType: .dinner, isFavorite: false, canCook: false, missingCount: 2)
            ])
        ]
        return vm
    }
}
