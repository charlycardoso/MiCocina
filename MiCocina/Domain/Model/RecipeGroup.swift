//
//  RecipeGroup.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

/// A collection of recipes grouped by meal type and intelligently sorted.
///
/// `RecipeGroup` organizes recipes by their meal type classification and automatically
/// sorts them according to user preferences and recipe availability. This model is used
/// to present recipes in the UI in a hierarchical, organized manner.
///
/// Recipes within a group are sorted by the following criteria (in order):
/// 1. **Favorite status**: Favorite recipes appear first
/// 2. **Cookability**: Recipes you can cook appear before those with missing ingredients
/// 3. **Missing ingredients**: Recipes with fewer missing ingredients appear first
/// 4. **Alphabetically**: Recipes are sorted by name as a final tiebreaker
///
/// - Example:
/// ```swift
/// let breakfastRecipes = [eggs, toast, pancakes]
/// let breakfastGroup = RecipeGroup(mealType: .breakFast, recipes: breakfastRecipes)
/// // recipes are automatically sorted by the rules above
/// ```
struct RecipeGroup {
    /// The meal type category for all recipes in this group
    let mealType: MealType
    
    /// Collection of recipes in this group, automatically sorted
    let recipes: [RecipeViewData]

    /// Initializes a new `RecipeGroup` with recipes automatically sorted.
    ///
    /// Upon initialization, the provided recipes are sorted according to the
    /// sorting rules defined in `orderRecipes(_:)`.
    ///
    /// - Parameters:
    ///   - mealType: The meal type classification for this group
    ///   - recipes: An array of recipes to include in this group
    init(mealType: MealType, recipes: [RecipeViewData]) {
        self.mealType = mealType
        self.recipes = Self.orderRecipes(recipes)
    }

    /// Sorts an array of recipes according to MiCocina's preferred order.
    ///
    /// The sorting algorithm prioritizes:
    /// 1. **Favorite recipes** (marked as favorite appear first)
    /// 2. **Cookable recipes** (recipes you can make appear before others)
    /// 3. **Ingredient count** (recipes with fewer missing ingredients first)
    /// 4. **Alphabetical** (as final tiebreaker)
    ///
    /// This ensures users see the most relevant and actionable recipes first.
    ///
    /// - Parameter recipes: An unordered array of recipes to sort
    /// - Returns: A sorted array of recipes
    private static func orderRecipes(_ recipes: [RecipeViewData]) -> [RecipeViewData] {
        recipes.sorted {
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite
            }
            if $0.canCook != $1.canCook {
                return $0.canCook
            }
            if $0.missingCount != $1.missingCount {
                return $0.missingCount < $1.missingCount
            }
            return $0.name < $1.name
        }
    }
}
