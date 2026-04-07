//
//  PantryProtocolRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation

protocol PantryProtocolRepository {
    func getPantry() -> Set<Ingredient>

    func add(_ ingredient: Ingredient) throws

    func remove(_ ingredient: Ingredient) throws

    func update(_ ingredient: Ingredient) throws

    func clear() throws

    func exists(_ ingredient: Ingredient) -> Bool
}
