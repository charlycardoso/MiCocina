//
//  Recipe.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Foundation

/// Represents a recipe in the MiCocina application.
///
/// `Recipe` is a domain model that encapsulates all information about a recipe,
/// including its name, ingredients, meal type classification, and favorite status.
/// This model is central to the recipe matching and discovery functionality.
///
/// - Note: The `Recipe` model uses a `Set` for ingredients to ensure uniqueness
///   and efficient lookups during recipe matching operations.
///
/// - Example:
/// ```swift
/// let bread = Ingredient(name: "bread")
/// let butter = Ingredient(name: "butter")
/// let sandwich = Recipe(
///     name: "Sandwich",
///     ingredients: [.init(ingredient: bread), .init(ingredient: butter)],
///     mealType: .lunch,
///     isFavorite: false
/// )
/// ```
struct Recipe: Equatable {
    /// Unique identifier for the recipe
    let id: UUID
    
    /// Human-readable name of the recipe
    let name: String
    
    /// Set of ingredients required for the recipe
    let ingredients: Set<RecipeIngredient>
    
    /// Classification of the recipe by meal type (breakfast, lunch, dinner, other)
    let mealType: MealType
    
    /// Boolean flag indicating if the recipe is marked as a favorite
    var isFavorite: Bool

    /// Initializes a new `Recipe` instance.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the recipe. Defaults to a newly generated UUID.
    ///   - name: The name of the recipe.
    ///   - ingredients: A set of `RecipeIngredient` items required for the recipe.
    ///   - mealType: The meal type category for the recipe. Defaults to `.other`.
    ///   - isFavorite: Whether the recipe is marked as a favorite. Defaults to `false`.
    init(id: UUID = .init(), name: String, ingredients: Set<RecipeIngredient>, mealType: MealType = .other, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.mealType = mealType
        self.isFavorite = isFavorite
    }
}
