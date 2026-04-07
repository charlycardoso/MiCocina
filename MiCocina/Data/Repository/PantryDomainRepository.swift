//
//  PantryDomainRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation

final class PantryDomainRepository: PantryProtocolRepository {
    private let PantryProtocolRepository: PantryProtocolRepository

    init(PantryProtocolRepository: PantryProtocolRepository) {
        self.PantryProtocolRepository = PantryProtocolRepository
    }

    func getPantry() -> Set<Ingredient> {
        PantryProtocolRepository.getPantry()
    }

    func add(_ ingredient: Ingredient) throws {
        try PantryProtocolRepository.add(ingredient)
    }

    func remove(_ ingredient: Ingredient) throws {
        try PantryProtocolRepository.remove(ingredient)
    }

    func update(_ ingredient: Ingredient) throws {
        try PantryProtocolRepository.update(ingredient)
    }

    func clear() throws {
        try PantryProtocolRepository.clear()
    }

    func exists(_ ingredient: Ingredient) -> Bool {
        PantryProtocolRepository.exists(ingredient)
    }
}
