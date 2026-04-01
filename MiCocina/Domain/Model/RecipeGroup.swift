//
//  RecipeGroup.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

struct RecipeGroup {
    let mealType: MealType
    let recipes: [RecipeViewData]

    init(mealType: MealType, recipes: [RecipeViewData]) {
        self.mealType = mealType
        self.recipes = Self.orderRecipes(recipes)
    }

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
