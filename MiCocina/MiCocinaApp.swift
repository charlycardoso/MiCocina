//
//  MiCocinaApp.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import SwiftUI
import SwiftData

@main
struct MiCocinaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SDShoppingListItem.self,
            SDPlannerData.self,
            SDRecipe.self,
            SDIngredient.self,
            SDRecipeIngredient.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            // Enable autosave on the main context
            container.mainContext.autosaveEnabled = true
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.cPrimary)
        }
        .modelContainer(sharedModelContainer)
    }
}
