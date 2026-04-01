//
//  RecipeUseCases.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

protocol RecipeUseCases {
    func getAllRecipes() -> [RecipeGroup]
    func getPossibleRecipes() -> [RecipeGroup]
}
