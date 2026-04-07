//
//  MockPantryRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

/// A mock implementation of `PantryProtocolRepository` for testing purposes.
///
/// `MockPantryRepository` provides an in-memory, set-based implementation of the pantry
/// repository protocol, designed for unit testing and development without database
/// dependencies.
///
/// All operations work directly on an in-memory set of ingredients. Data is not persisted
/// across instances, making this implementation ideal for test isolation.
///
/// - Example:
/// ```swift
/// let pantry: Set<Ingredient> = [tomato, lettuce, cucumber]
/// let mockRepository = MockPantryRepository(pantry: pantry)
/// let retrieved = mockRepository.getPantry()
/// XCTAssertEqual(retrieved.count, 3)
/// ```
final class MockPantryRepository: PantryProtocolRepository {
    /// The in-memory set of ingredients in the pantry
    private var pantry: Set<Ingredient>

    /// Initializes a mock pantry repository with an optional set of ingredients.
    ///
    /// - Parameter pantry: A set of ingredients to initialize with.
    ///                    Defaults to an empty set.
    init(pantry: Set<Ingredient> = []) {
        self.pantry = pantry
    }

    /// Returns the current pantry contents.
    ///
    /// - Returns: A set of all ingredients in the pantry
    func getPantry() -> Set<Ingredient> {
        pantry
    }

    /// Adds an ingredient to the pantry.
    ///
    /// - Parameter ingredient: The ingredient to add
    /// - Throws: Never throws
    func add(_ ingredient: Ingredient) throws {
        pantry.insert(ingredient)
    }

    /// Removes an ingredient from the pantry.
    ///
    /// - Parameter ingredient: The ingredient to remove
    /// - Throws: Never throws
    ///
    /// - Note: Silently succeeds if the ingredient doesn't exist
    func remove(_ ingredient: Ingredient) throws {
        pantry.remove(ingredient)
    }

    /// Updates an ingredient in the pantry.
    ///
    /// - Parameter ingredient: The ingredient with updated information
    /// - Throws: Never throws
    ///
    /// - Note: Updates the ingredient in the set using its unique ID
    func update(_ ingredient: Ingredient) throws {
        pantry.update(with: ingredient)
    }

    /// Clears all ingredients from the pantry.
    ///
    /// - Throws: Never throws
    func clear() throws {
        pantry.removeAll()
    }

    /// Checks whether an ingredient exists in the pantry.
    ///
    /// - Parameter ingredient: The ingredient to check
    /// - Returns: `true` if the ingredient exists, `false` otherwise
    func exists(_ ingredient: Ingredient) -> Bool {
        pantry.contains(ingredient)
    }
}
