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
/// `ContentView` serves as the primary view displayed to users. Currently, it's a
/// placeholder with infrastructure ready for the recipe discovery interface.
///
/// - Note: This view integrates with SwiftData for data access and uses the model
///   context for any future data operations.
///
/// - TODO: Implement recipe display, filtering, and interaction components

enum NavigationViews {
    case Home
    case MyPantry
    case Planner
    case ShoppingList
}
struct ContentView: View {
    /// The SwiftData model context for database operations
    @Environment(\.modelContext) private var modelContext
    @State private var navigation: NavigationViews = .Home
    
    var body: some View {
        TabView(selection: $navigation) {
            Tab(String(localized: "homeContent.navigationTitle"), systemImage: "house.fill", value: .Home) {
                NavigationStack {
                    Navigate(to: .Home)
                }
            }
            
            Tab(String(localized: "myPantry.navigationTitle"), systemImage: "refrigerator.fill", value: .MyPantry) {
                NavigationStack {
                    Navigate(to: .MyPantry)
                }
            }
            
            Tab(String(localized: "planner.title"), systemImage: "calendar", value: .Planner) {
                NavigationStack {
                    Navigate(to: .Planner)
                }
            }
            
            Tab(String(localized: "shoppingList.title"), systemImage: "cart.fill", value: .ShoppingList) {
                NavigationStack {
                    Navigate(to: .ShoppingList)
                }
            }
        }
    }

    @ViewBuilder
    private func Navigate(to: NavigationViews) -> some View {
        switch to {
        case .Home:
            HomeContent(viewModel: .init(context: modelContext))
        case .MyPantry:
            MyPantryView(viewModel: .init(context: modelContext))
        case .Planner:
            PlannerView(viewModel: .init(context: modelContext))
        case .ShoppingList:
            ShoppingListView()
        }
    }
}

#Preview {
    ContentView()
}
