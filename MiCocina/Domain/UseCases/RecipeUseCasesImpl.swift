//
//  RecipeUseCasesImpl.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 20/03/26.
//

/// Maps domain `Recipe` models to `RecipeViewData` objects optimized for UI display.
///
/// `RecipeMapper` handles the transformation of recipes from the domain layer into
/// view data transfer objects (DTOs). It pre-computes valuable information for the UI
/// such as whether a recipe can be cooked with available pantry items and how many
/// ingredients are missing.
///
/// This transformation encapsulates the complexity of evaluating recipe feasibility
/// and produces data that's directly usable by the presentation layer.
///
/// - Example:
/// ```swift
/// let mapper = RecipeMapper()
/// let viewData = mapper.map(recipe, pantry: ingredients, matcher: matcher)
/// // viewData now contains canCook and missingCount pre-computed
/// ```
struct RecipeMapper {
    
    /// Maps a recipe to a view-optimized data object.
    ///
    /// Transforms a domain `Recipe` into a `RecipeViewData` object by:
    /// 1. Using the recipe matcher to determine if the recipe is cookable
    /// 2. Counting the number of missing **required** ingredients
    /// 3. Extracting relevant fields into the view data structure
    ///
    /// **Architecture**: Compares recipe ingredient names against pantry ingredient names.
    ///
    /// - Parameters:
    ///   - recipe: The recipe to transform
    ///   - pantry: The set of available ingredients (with quantities)
    ///   - matcher: The recipe matcher service used to evaluate feasibility
    ///
    /// - Returns: A `RecipeViewData` object containing all information needed for UI display
    func map(_ recipe: Recipe, pantry: Set<Ingredient>, matcher: RecipeMatcher) -> RecipeViewData {
        let canCook = matcher.canCook(recipe: recipe, with: pantry)
        
        // Get required ingredient names from recipe
        let requiredIngredientNames = Set(
            recipe.ingredients
                .map { $0.ingredientName.normalize() }
        )
        
        // Get available ingredient names from pantry
        let pantryNames = Set(
            pantry
                .map { $0.name.normalize() }
        )
        
        let missing = requiredIngredientNames.subtracting(pantryNames).count
        
        return RecipeViewData(
            id: recipe.id,
            name: recipe.name,
            mealType: recipe.mealType,
            isFavorite: recipe.isFavorite,
            canCook: canCook,
            missingCount: missing
        )
    }
}

/// Groups recipes by meal type, applying intelligent sorting within each group.
///
/// `RecipeGrouper` is responsible for organizing a flat collection of `RecipeViewData`
/// objects into hierarchically grouped `RecipeGroup` objects. Each group contains recipes
/// for a specific meal type, and recipes are automatically sorted according to MiCocina's
/// smart sorting algorithm.
///
/// - Example:
/// ```swift
/// let viewData = [eggs, toast, pasta, soup]
/// let groups = RecipeGrouper.group(viewData)
/// // Results in groups for breakfast (eggs, toast) and lunch (pasta, soup)
/// ```
struct RecipeGrouper {
    
    /// Groups recipes by meal type and returns sorted recipe groups.
    ///
    /// Organizes recipes into groups where each group represents a meal type.
    /// Recipes within each group are automatically sorted according to MiCocina's
    /// sorting rules (favorites first, then cookable, then by missing count, then alphabetically).
    ///
    /// - Parameter items: An array of `RecipeViewData` objects to group
    /// - Returns: An array of `RecipeGroup` objects, one for each meal type represented in the input,
    ///           sorted by meal type
    static func group(_ items: [RecipeViewData]) -> [RecipeGroup] {
        let groups = Dictionary(grouping: items, by: { $0.mealType })
        return groups.keys.sorted().map { key in
            RecipeGroup(mealType: key, recipes: groups[key] ?? [])
        }
    }
}

/// Concrete implementation of the `RecipeUseCases` protocol.
///
/// `RecipeUseCasesImpl` orchestrates the workflow for retrieving and processing recipes
/// by coordinating between the recipe and pantry repositories, applying recipe matching,
/// mapping results for UI presentation, and grouping by meal type.
///
/// This class implements the core business logic for recipe discovery:
/// 1. Fetches recipes and pantry data from repositories
/// 2. Applies the recipe matching algorithm
/// 3. Maps domain models to UI-optimized DTOs
/// 4. Groups and sorts results for optimal UX
///
/// - Example:
/// ```swift
/// let useCases = RecipeUseCasesImpl(
///     RecipeProtocolRepository: recipeRepository,
///     PantryProtocolRepository: pantryRepository,
///     matcher: RecipeMatcher()
/// )
/// let groups = useCases.getAllRecipes()
/// ```
final class RecipeUseCasesImpl: RecipeUseCases {
    
    /// Repository for accessing recipe data
    private let RecipeProtocolRepository: RecipeProtocolRepository
    
    /// Repository for accessing pantry data
    private let PantryProtocolRepository: PantryProtocolRepository
    
    /// Service for matching recipes to available ingredients
    private let matcher: RecipeMatcher
    
    /// Mapper for transforming recipes to view data
    private let mapper = RecipeMapper()

    /// Initializes a new `RecipeUseCasesImpl` instance.
    ///
    /// - Parameters:
    ///   - RecipeProtocolRepository: Repository for recipe data access
    ///   - PantryProtocolRepository: Repository for pantry data access
    ///   - matcher: Recipe matcher service for evaluating recipe feasibility
    init(RecipeProtocolRepository: RecipeProtocolRepository, PantryProtocolRepository: PantryProtocolRepository, matcher: RecipeMatcher) {
        self.RecipeProtocolRepository = RecipeProtocolRepository
        self.PantryProtocolRepository = PantryProtocolRepository
        self.matcher = matcher
    }

    /// Retrieves all recipes grouped and sorted by meal type.
    ///
    /// Implements the `RecipeUseCases` protocol requirement. Fetches all recipes
    /// from the repository, evaluates them against the current pantry, and presents
    /// them grouped by meal type with intelligent sorting.
    ///
    /// - Returns: An array of recipe groups containing all recipes
    func getAllRecipes() -> [RecipeGroup] {
        let recipes = RecipeProtocolRepository.getAll()
        let pantry = PantryProtocolRepository.getPantry()
        let mapped = recipes.map { mapper.map($0, pantry: pantry, matcher: matcher) }
        return RecipeGrouper.group(mapped)
    }

    /// Retrieves only recipes that can be cooked with current pantry items.
    ///
    /// Implements the `RecipeUseCases` protocol requirement. Filters recipes to
    /// return only those that can be cooked (up to 3 missing ingredients), maps them
    /// for UI presentation, and returns them grouped by meal type.
    ///
    /// - Returns: An array of recipe groups containing only cookable recipes
    func getPossibleRecipes() -> [RecipeGroup] {
        let recipes = RecipeProtocolRepository.getAll()
        let pantry = PantryProtocolRepository.getPantry()
        let possible = matcher.possibleRecipes(from: recipes, pantry: pantry)
        let mapped = possible.map { mapper.map($0, pantry: pantry, matcher: matcher) }
        return RecipeGrouper.group(mapped)
    }
}
