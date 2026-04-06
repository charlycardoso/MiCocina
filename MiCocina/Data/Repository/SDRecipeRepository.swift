//
//  SDRecipeRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 03/04/26.
//

import SwiftData
import Foundation

final class SDRecipeRepository: RecipeRepository {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getAll() -> [Recipe] {
        let descriptor = FetchDescriptor<SDRecipe>()
        guard let sdRecipes = try? context.fetch(descriptor) else { return [] }
        return sdRecipes.map { DomainMapper.toDomain(recipe: $0) }
    }

    func getByID(_ id: UUID) -> Recipe? {
        let recipeUUID: UUID = id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        guard let sdRecipe = try? context.fetch(descriptor).first else { return nil }
        return DomainMapper.toDomain(recipe: sdRecipe)
    }
    
    func getByName(_ name: String) -> Recipe? {
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.name == name }
        )
        guard let sdRecipe = try? context.fetch(descriptor).last else { return nil }
        return DomainMapper.toDomain(recipe: sdRecipe)
    }
    
    func getByMealType(_ mealType: MealType) -> [Recipe] {
        let mealTypeString: String = mealType.rawValue
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.mealType == mealTypeString }
        )
        guard let sdRecipes = try? context.fetch(descriptor) else { return [] }
        return sdRecipes.map { DomainMapper.toDomain(recipe: $0) }
    }
    
    func getFavorites() -> [Recipe] {
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.isFavorite }
        )
        guard let sdRecipes = try? context.fetch(descriptor) else { return [] }
        return sdRecipes.map { DomainMapper.toDomain(recipe: $0) }
    }
    
    func save(_ recipe: Recipe) throws {
        let recipeUUID: UUID = recipe.id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        if let _ = try? context.fetch(descriptor).first {
            try update(recipe)
            return
        }
        let sdRecipe = StorageMapper.toStorage(recipe: recipe, context: context)
        try context.save()
    }
    
    func delete(_ recipe: Recipe) throws {
        let recipeUUID: UUID = recipe.id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        if let sdRecipe = try? context.fetch(descriptor).first {
            context.delete(sdRecipe)
            try context.save()
        }
    }

    func update(_ recipe: Recipe) throws {
        let recipeUUID: UUID = recipe.id
        let descriptor = FetchDescriptor<SDRecipe>(
            predicate: #Predicate { $0.id == recipeUUID }
        )
        guard let sdRecipe = try context.fetch(descriptor).first else {
            throw NSError(domain: "RecipeRepository", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Recipe not found"
            ])
        }
        sdRecipe.name = recipe.name
        sdRecipe.mealType = recipe.mealType.rawValue
        sdRecipe.isFavorite = recipe.isFavorite
        for old in sdRecipe.ingredients {
            context.delete(old)
        }
        sdRecipe.ingredients.removeAll()
        for ingredient in recipe.ingredients {
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
    }
}
