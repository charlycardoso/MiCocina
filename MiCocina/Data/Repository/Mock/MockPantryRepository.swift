//
//  MockPantryProtocolRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

final class MockPantryProtocolRepository: PantryProtocolRepository {
    private var pantry: Set<Ingredient>

    init(pantry: Set<Ingredient> = []) {
        self.pantry = pantry
    }

    func getPantry() -> Set<Ingredient> {
        pantry
    }

    func add(_ ingredient: Ingredient) throws {
        pantry.insert(ingredient)
    }

    func remove(_ ingredient: Ingredient) throws {
        pantry.remove(ingredient)
    }

    func update(_ ingredient: Ingredient) throws {
        pantry.update(with: ingredient)
    }

    func clear() throws {
        pantry.removeAll()
    }

    func exists(_ ingredient: Ingredient) -> Bool {
        pantry.contains(ingredient)
    }
}
