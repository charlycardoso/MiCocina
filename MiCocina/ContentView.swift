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
struct ContentView: View {
    /// The SwiftData model context for database operations
    @Environment(\.modelContext) private var modelContext
    
    /// Query for retrieving Item objects from the database
    @Query private var items: [Item]

    // Properties
    
    
    var body: some View {
        Text("Hello, world!")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

extension ContentView {
    /// An example view showing how to interact with SwiftData.
    ///
    /// This view demonstrates:
    /// - Displaying items in a NavigationSplitView
    /// - Editing items in a list
    /// - Adding new items
    /// - Deleting items
    ///
    /// - Returns: A SwiftUI view hierarchy
    @ViewBuilder
    private func ExampleView() -> some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    /// Adds a new item to the database.
    ///
    /// Creates a new item with the current timestamp and inserts it into the model context.
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    /// Deletes items from the database.
    ///
    /// - Parameter offsets: The index set of items to delete
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}
