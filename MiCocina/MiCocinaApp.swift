//
//  MiCocinaApp.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import SwiftUI
import SwiftData

/// The main entry point for the MiCocina application.
///
/// `MiCocinaApp` is the app delegate and root scene manager for the MiCocina application.
/// It configures and manages the SwiftData model container for persistent storage and
/// initializes the root view hierarchy.
///
/// - Note: This app uses SwiftData for local persistence of recipes and pantry items.
///   The model container is configured in memory on disk for the `Item` model.
///
/// - Important: Currently includes the `Item` model (legacy) which can be removed
///   once migration to the recipe domain models is complete.
@main
struct MiCocinaApp: App {
    /// The shared SwiftData model container managing database operations
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
