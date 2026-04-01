//
//  PantryRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

protocol PantryRepository {
    func getPantry() -> Set<Ingredient>
}

final class MockPantryRepository: PantryRepository {
    private let pantry: Set<Ingredient>

    init(pantry: Set<Ingredient>) {
        self.pantry = pantry
    }

    func getPantry() -> Set<Ingredient> {
        pantry
    }
}
