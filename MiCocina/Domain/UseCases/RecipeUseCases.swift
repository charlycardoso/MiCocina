//
//  RecipeUseCases.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

/// A protocol defining the main use cases for recipe operations in MiCocina.
///
/// `RecipeUseCases` encapsulates the primary high-level operations that users perform
/// when interacting with the recipe discovery feature. It abstracts the complexity of
/// data fetching, mapping, and recipe matching behind simple, intention-revealing methods.
///
/// This protocol follows the Clean Architecture principle of having use case abstractions
/// that are independent of implementation details, frameworks, and UI.
///
/// - Example:
/// ```swift
/// let useCases: RecipeUseCases = RecipeUseCasesImpl(...)
/// let allRecipes = useCases.getAllRecipes()        // All recipes grouped by meal type
/// let cookable = useCases.getPossibleRecipes()     // Only recipes you can make
/// ```
protocol RecipeUseCases {
    
    /// Retrieves all recipes in the system, organized and sorted by meal type.
    ///
    /// This method returns the complete recipe collection, grouping recipes by their
    /// meal type classification (breakfast, lunch, dinner, other). Within each group,
    /// recipes are automatically sorted according to MiCocina's smart sorting algorithm
    /// that prioritizes favorites, cookable recipes, and those with fewer missing ingredients.
    ///
    /// - Returns: An array of `RecipeGroup` objects, each containing recipes for a specific meal type
    ///
    /// - Note: The grouping and sorting is performed automatically to ensure a consistent
    ///         user experience across all views.
    func getAllRecipes() -> [RecipeGroup]
    
    /// Retrieves only recipes that can be cooked with ingredients in the current pantry.
    ///
    /// This method returns a filtered and organized subset of all recipes—only those that
    /// can be prepared with the ingredients currently available in the pantry (allowing for
    /// up to 3 missing ingredients). Like `getAllRecipes()`, results are grouped by meal type
    /// and sorted for optimal user experience.
    ///
    /// This is the primary method for the recipe discovery feature, allowing users to focus
    /// on actionable recipes they can actually cook.
    ///
    /// - Returns: An array of `RecipeGroup` objects containing only cookable recipes,
    ///           organized by meal type
    ///
    /// - Note: A recipe is considered "possible" if it has 3 or fewer missing ingredients.
    ///         This provides a practical balance between suggestions and shopping requirements.
    func getPossibleRecipes() -> [RecipeGroup]
}
