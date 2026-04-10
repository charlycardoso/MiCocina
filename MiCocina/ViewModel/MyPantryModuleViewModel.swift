//
//  MyPantryModuleViewModel.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 09/04/26.
//

import Foundation
import SwiftData
import Combine

final class MyPantryModuleViewModel: ObservableObject {
    // MARK: Properties
    private let context: ModelContext
    private let isPreviewMode: Bool

    private var pantryRepo: PantryDomainRepository {
        .init(PantryProtocolRepository: SDPantryProtocolRepository(context: context))
    }

    @Published var pantry: Set<Ingredient> = []

    init(context: ModelContext, isPreviewMode: Bool = false) {
        self.context = context
        self.isPreviewMode = isPreviewMode
        fetchPantry()
    }

    private func fetchPantry() {
        let ingredients = pantryRepo.getPantry()
        self.pantry = ingredients
    }
}

// MARK: Pantry Repository methods
extension MyPantryModuleViewModel: PantryProtocolRepository {
    func getPantry() -> Set<Ingredient> {
        pantryRepo.getPantry()
    }

    func add(_ ingredient: Ingredient) throws {
        try pantryRepo.add(ingredient)
    }

    func remove(_ ingredient: Ingredient) throws {
        try pantryRepo.remove(ingredient)
    }

    func update(_ ingredient: Ingredient) throws {
        try pantryRepo.update(ingredient)
    }

    func clear() throws {
        try pantryRepo.clear()
    }

    func exists(_ ingredient: Ingredient) -> Bool {
        pantryRepo.exists(ingredient)
    }
}

extension MyPantryModuleViewModel {
    static func mockForPreview(context: ModelContext) -> MyPantryModuleViewModel {
        let vm = MyPantryModuleViewModel(context: context, isPreviewMode: true)
        vm.pantry = [
            .init(name: "Tomate", quantity: 1),
            .init(name: "Leche", quantity: 3),
            .init(name: "Huevos", quantity: 6),
            .init(name: "Mantequilla", quantity: 1),
            .init(name: "Arroz", quantity: 1),
        ]
        return vm
    }
}
