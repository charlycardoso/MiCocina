//
//  SDPantryProtocolRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 03/04/26.
//

import SwiftData
import Foundation

final class SDPantryProtocolRepository: PantryProtocolRepository {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getPantry() -> Set<Ingredient> {
        let descriptor = FetchDescriptor<SDIngredient>()
        guard let ingredients = try? context.fetch(descriptor) else { return .init() }
        let retrievedIngredients = ingredients.map { DomainMapper.toDomain(ingredient: $0) }
        var pantry: Set<Ingredient> = []
        retrievedIngredients.forEach { pantry.insert($0) }
        return pantry
    }

    func add(_ ingredient: Ingredient) throws {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientUUID }
        )
        let existingIngredient = try context.fetch(descriptor).first
        if existingIngredient != nil {
            try update(ingredient)
            return
        }

        _ = StorageMapper.toStorage(with: ingredient, context: context)
        try context.save()
    }

    func remove(_ ingredient: Ingredient) throws {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientUUID }
        )
        if let existing = try context.fetch(descriptor).first {
            context.delete(existing)
            try context.save()
        }
    }

    func update(_ ingredient: Ingredient) throws {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientUUID }
        )
        guard let existing = try context.fetch(descriptor).first else { return }
        existing.name = ingredient.name
        try context.save()
    }

    func clear() throws {
        let descriptor = FetchDescriptor<SDIngredient>()
        let allIngredients = try context.fetch(descriptor)
        allIngredients.forEach { context.delete($0) }
        try context.save()
    }

    func exists(_ ingredient: Ingredient) -> Bool {
        let ingredientUUID: UUID = ingredient.id
        let descriptor = FetchDescriptor<SDIngredient>(
            predicate: #Predicate { $0.id == ingredientUUID }
        )
        let existing = try? context.fetch(descriptor).first
        return existing != nil
    }
}
