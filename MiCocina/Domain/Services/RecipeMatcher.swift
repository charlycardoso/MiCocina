//
//  RecipeMatcher.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Foundation

/// A service that determines which recipes can be cooked with available pantry items.
///
/// `RecipeMatcher` implements the core recipe matching algorithm that powers MiCocina's
/// recipe discovery feature. It uses an intelligent tolerance mechanism to suggest recipes
/// that you can cook with minimal shopping needed.
///
/// The matching algorithm considers:
/// - All ingredients currently in your pantry
/// - Required and optional ingredients in recipes
/// - A tolerance of up to 3 missing ingredients
///
/// This approach balances practicality (you don't need everything to cook) with
/// usability (too many missing ingredients becomes impractical).
///
/// - Example:
/// ```swift
/// let matcher = RecipeMatcher()
/// let pantry: Set<Ingredient> = [water, flour, salt]
/// let recipe = Recipe(name: "Bread", ingredients: [...])
/// let canCook = matcher.canCook(recipe: recipe, with: pantry)  // true if <= 3 ingredients missing
/// ```
struct RecipeMatcher {
    
    /// Determines whether a recipe can be cooked with the given pantry ingredients.
    ///
    /// A recipe is considered cookable if:
    /// - It has at least one ingredient
    /// - The number of missing **required** ingredients is 3 or fewer
    ///
    /// **Architecture**: Compares recipe ingredient names against pantry ingredient names.
    /// - Recipe ingredients: Just names (no quantity)
    /// - Pantry ingredients: Names with quantities (quantity > 0 means you have it)
    ///
    /// This tolerance mechanism allows users to cook recipes even when they're missing
    /// a few items, promoting flexibility in meal planning.
    ///
    /// - Parameters:
    ///   - recipe: The recipe to evaluate
    ///   - pantry: A set of ingredients available in the pantry (with quantities > 0)
    ///
    /// - Returns: `true` if the recipe can be cooked with the available ingredients,
    ///           `false` otherwise
    ///
    /// - Note: Empty recipes (with no ingredients) are considered uncookable
    func canCook(recipe: Recipe, with pantry: Set<Ingredient>) -> Bool {
        guard !recipe.ingredients.isEmpty else { return false }

        // Get required ingredient names from recipe
        let requiredIngredientNames = Set(
            recipe.ingredients
                .filter { $0.isRequired }
                .map { $0.ingredientName.normalize() }
        )
        
        // Get available ingredient names from pantry (only items with quantity > 0)
        let pantryNames = Set(
            pantry
                .map { $0.name.normalize() }
        )

        let missingIngredients = requiredIngredientNames.subtracting(pantryNames)

        return missingIngredients.count <= 3
    }

    /// Filters recipes to return only those that can be cooked with pantry items.
    ///
    /// This method uses `canCook(recipe:with:)` to evaluate each recipe and returns
    /// a filtered array containing only cookable recipes.
    ///
    /// - Parameters:
    ///   - recipes: An array of recipes to filter
    ///   - pantry: A set of ingredients available in the pantry
    ///
    /// - Returns: An array of recipes that can be cooked with the available ingredients
    ///
    /// - Example:
    /// ```swift
    /// let allRecipes = [pasta, pizza, salad, soup]
    /// let pantry: Set<Ingredient> = [olive, garlic, tomato]
    /// let possible = matcher.possibleRecipes(from: allRecipes, pantry: pantry)
    /// // possible contains only recipes that can be made with at most 3 missing ingredients
    /// ```
    func possibleRecipes(from recipes: [Recipe], pantry: Set<Ingredient>) -> [Recipe] {
        let possibleRecipes = recipes.filter { canCook(recipe: $0, with: pantry) }
        return possibleRecipes
    }
}
