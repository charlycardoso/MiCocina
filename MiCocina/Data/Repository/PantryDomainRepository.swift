//
//  PantryDomainRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation

final class PantryDomainRepository: PantryProtocolRepository {
    private let pantryRepository: PantryProtocolRepository

    init(PantryProtocolRepository: PantryProtocolRepository) {
        self.pantryRepository = PantryProtocolRepository
    }

    func getPantry() -> Set<Ingredient> {
        pantryRepository.getPantry()
    }

    func add(_ ingredient: Ingredient) throws {
        try pantryRepository.add(ingredient)
    }

    func remove(_ ingredient: Ingredient) throws {
        try pantryRepository.remove(ingredient)
    }

    func update(_ ingredient: Ingredient) throws {
        try pantryRepository.update(ingredient)
    }

    func clear() throws {
        try pantryRepository.clear()
    }

    func exists(_ ingredient: Ingredient) -> Bool {
        pantryRepository.exists(ingredient)
    }
}
