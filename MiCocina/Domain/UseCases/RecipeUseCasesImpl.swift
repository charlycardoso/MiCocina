//
//  RecipeUseCasesImpl.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 20/03/26.
//

struct RecipeMapper {
    func map(_ recipe: Recipe, pantry: Set<Ingredient>, matcher: RecipeMatcher) -> RecipeViewData {
        let canCook = matcher.canCook(recipe: recipe, with: pantry)
        let missing = recipe.ingredients.filter { !pantry.contains($0.ingredient) }.count
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

struct RecipeGrouper {
    static func group(_ items: [RecipeViewData]) -> [RecipeGroup] {
        let groups = Dictionary(grouping: items, by: { $0.mealType })
        return groups.keys.sorted().map { key in
            RecipeGroup(mealType: key, recipes: groups[key] ?? [])
        }
    }
}

final class RecipeUseCasesImpl: RecipeUseCases {
    private let recipeRepository: RecipeRepository
    private let pantryRepository: PantryRepository
    private let matcher: RecipeMatcher
    private let mapper = RecipeMapper()

    init(recipeRepository: RecipeRepository, pantryRepository: PantryRepository, matcher: RecipeMatcher) {
        self.recipeRepository = recipeRepository
        self.pantryRepository = pantryRepository
        self.matcher = matcher
    }

    func getAllRecipes() -> [RecipeGroup] {
        let recipes = recipeRepository.getAll()
        let pantry = pantryRepository.getPantry()
        let mapped = recipes.map { mapper.map($0, pantry: pantry, matcher: matcher) }
        return RecipeGrouper.group(mapped)
    }

    func getPossibleRecipes() -> [RecipeGroup] {
        let recipes = recipeRepository.getAll()
        let pantry = pantryRepository.getPantry()
        let possible = matcher.possibleRecipes(from: recipes, pantry: pantry)
        let mapped = possible.map { mapper.map($0, pantry: pantry, matcher: matcher) }
        return RecipeGrouper.group(mapped)
    }
}
