//
//  PantryRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

protocol PantryRepository {
    func getPantry() -> Set<Ingredient>

    func add(_ ingredient: Ingredient) throws

    func remove(_ ingredient: Ingredient) throws

    func update(_ ingredient: Ingredient) throws

    func clear() throws

    func exists(_ ingredient: Ingredient) -> Bool
}

final class MockPantryRepository: PantryRepository {
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
