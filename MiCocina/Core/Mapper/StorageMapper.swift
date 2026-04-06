//
//  StorageMapper.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 02/04/26.
//

import SwiftData
import Foundation

final class StorageMapper {

    // MARK: - SDIngredient
    static func toStorage(
        with ingredient: Ingredient,
        context: ModelContext
    ) -> SDIngredient {
        let name = ingredient.name
        let id = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == id }
        )

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        // Crear nuevo si no existe
        let new = SDIngredient(id: ingredient.id, name: name)
        context.insert(new)
        return new
    }

    // MARK: - SDRecipe
    static func toStorage(
        recipe domain: Recipe,
        context: ModelContext
    ) -> SDRecipe {
        let sdRecipe = SDRecipe(
            id: domain.id,
            name: domain.name,
            mealType: domain.mealType.rawValue,
            isFavorite: domain.isFavorite
        )

        context.insert(sdRecipe)

        domain.ingredients.forEach { recipeIngredient in
            let sdIngredient = StorageMapper.toStorage(
                with: recipeIngredient.ingredient,
                context: context
            )

            let sdRecipeIngredient = SDRecipeIngredient(
                recipe: sdRecipe,
                ingredient: sdIngredient,
                quantity: nil,
                isRequired: recipeIngredient.isRequired
            )

            context.insert(sdRecipeIngredient)
            sdRecipe.ingredients.append(sdRecipeIngredient)
        }

        return sdRecipe
    }

    // MARK: - SDRecipeIngredient
    static func toStorage(
        _ domain: RecipeIngredient,
        recipe: SDRecipe,
        ingredient: SDIngredient,
        context: ModelContext
    ) -> SDRecipeIngredient {

        // Asegurar que el SDIngredient exista en el contexto
        if ingredient.persistentModelID.storeIdentifier == nil {
            context.insert(ingredient)
        }

        // Asegurar que el SDRecipe esté insertado
        if recipe.persistentModelID.storeIdentifier == nil {
            context.insert(recipe)
        }

        // Ahora sí: crear el RecipeIngredient
        let new = SDRecipeIngredient(
            recipe: recipe,
            ingredient: ingredient,
            quantity: nil,
            isRequired: domain.isRequired
        )

        context.insert(new)
        return new
    }
}
