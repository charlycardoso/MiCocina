//
//  ContentView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import SwiftUI
import SwiftData

/// The main content view for the MiCocina application.
///
/// `ContentView` serves as the root navigation container using a tab-based interface.
/// It provides access to all four main modules of the application: Home (recipe discovery),
/// My Pantry (ingredient management), Planner (meal planning), and Shopping List.
///
/// ## Navigation Structure
///
/// The view uses a `TabView` with four tabs, each containing its own `NavigationStack`:
/// - **Home**: Recipe browsing and discovery with smart matching
/// - **My Pantry**: Ingredient inventory management
/// - **Planner**: Weekly meal planning calendar
/// - **Shopping List**: Shopping list generation and management
///
/// ## Architecture
///
/// Each tab's content is provided through the `Navigate(to:)` method, which initializes
/// the appropriate view with its corresponding ViewModel. This ensures proper dependency
/// injection and separation of concerns.
///
/// - Note: The view integrates with SwiftData for data access through the `modelContext`
///   environment value, which is passed to child ViewModels for repository operations.
///
/// - Important: All navigation labels use localized strings from the app's `.xcstrings`
///   file to support internationalization.
///
/// ## Example Usage
///
/// ```swift
/// ContentView()
///     .modelContainer(for: [SDRecipe.self, SDIngredient.self])
/// ```

/// Enumeration representing the available navigation destinations in the app.
///
/// `NavigationViews` defines the four main sections of MiCocina, used to control
/// the selected tab in the main `TabView` interface.
///
/// - Note: Each case corresponds to a distinct feature module with its own view and ViewModel.
enum NavigationViews {
    /// Home screen showing recipe discovery and browsing
    case Home
    
    /// Pantry management screen for ingredient inventory
    case MyPantry
    
    /// Weekly meal planner screen
    case Planner
    
    /// Shopping list screen for ingredient purchasing
    case ShoppingList
}
struct ContentView: View {
    /// The SwiftData model context for database operations
    @Environment(\.modelContext) private var modelContext
    @State private var navigation: NavigationViews = .Home

    // ViewModels are stored here so they survive tab switches and are never recreated.
    @State private var homeVM: HomeContentViewModel?
    @State private var plannerVM: PlannerViewModel?

    var body: some View {
        TabView(selection: $navigation) {
            Tab(String(localized: "homeContent.navigationTitle"), systemImage: "house.fill", value: .Home) {
                NavigationStack {
                    if let vm = homeVM {
                        HomeContent(viewModel: vm)
                    }
                }
            }
            .accessibilityIdentifier("contentView.homeTab")

            Tab(String(localized: "myPantry.navigationTitle"), systemImage: "refrigerator.fill", value: .MyPantry) {
                NavigationStack {
                    MyPantryView(viewModel: .init(context: modelContext))
                }
            }
            .accessibilityIdentifier("contentView.pantryTab")

            Tab(String(localized: "planner.title"), systemImage: "calendar", value: .Planner) {
                NavigationStack {
                    if let vm = plannerVM {
                        PlannerView(viewModel: vm)
                    }
                }
            }
            .accessibilityIdentifier("contentView.plannerTab")

            Tab(String(localized: "shoppingList.title"), systemImage: "cart.fill", value: .ShoppingList) {
                NavigationStack {
                    ShoppingListView()
                }
            }
            .accessibilityIdentifier("contentView.shoppingListTab")
        }
        .accessibilityIdentifier("contentView.tabView")
        .onAppear {
            guard homeVM == nil else { return }
            homeVM = HomeContentViewModel(context: modelContext)
            plannerVM = PlannerViewModel(context: modelContext)
        }
    }
}

#Preview {
    ContentView()
}
