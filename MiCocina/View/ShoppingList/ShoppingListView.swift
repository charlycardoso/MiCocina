//
//  ShoppingListView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/04/26.
//

import SwiftUI
import SwiftData

/// The main view for displaying and managing the shopping list.
///
/// `ShoppingListView` presents a clean interface for viewing ingredients that need
/// to be purchased. Users can:
/// - View all items in their shopping list
/// - Add new ingredients directly
/// - Mark items as bought/unbought
/// - Search and filter ingredients
/// - Clear the entire list
/// - See bought and unbought items separately
///
/// The view automatically refreshes when items are added from other modules.
///
/// - Example:
/// ```swift
/// ShoppingListView()
///     .environment(\.modelContext, modelContext)
/// ```
struct ShoppingListView: View {
    
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    
    @State private var viewModel: ShoppingListViewModel?
    @State private var showClearConfirmation = false
    @State private var showAddIngredient = false
    @State private var newIngredientName = ""
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    
    /// Filtered items based on search text
    private var filteredUnboughtItems: [ShoppingListItem] {
        guard let viewModel = viewModel else { return [] }
        if searchText.isEmpty {
            return viewModel.unboughtItems
        }
        return viewModel.unboughtItems.filter { 
            $0.ingredient.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var filteredBoughtItems: [ShoppingListItem] {
        guard let viewModel = viewModel else { return [] }
        if searchText.isEmpty {
            return viewModel.boughtItems
        }
        return viewModel.boughtItems.filter { 
            $0.ingredient.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    /// Total count of items in the list
    private var itemCount: Int {
        viewModel?.items.count ?? 0
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                if viewModel.isEmpty {
                    emptyStateView
                } else {
                    listView(viewModel: viewModel)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("shoppingList.title")
        .searchable(text: $searchText, prompt: Text("shoppingList.searchPrompt"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let viewModel = viewModel, !viewModel.isEmpty {
                    Menu {
                        Button {
                            showAddIngredient = true
                        } label: {
                            Label("shoppingList.toolbar.addIngredient", systemImage: "plus")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Label("shoppingList.toolbar.clearList", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                } else {
                    Button {
                        showAddIngredient = true
                    } label: {
                        Label("shoppingList.toolbar.addIngredient", systemImage: "plus")
                    }
                }
            }
        }
        .confirmationDialog(
            "shoppingList.clear.title",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("shoppingList.clear.confirm", role: .destructive) {
                viewModel?.clearList()
            }
            Button("shoppingList.clear.cancel", role: .cancel) { }
        } message: {
            Text("shoppingList.clear.message")
        }
        .sheet(isPresented: $showAddIngredient) {
            AddIngredientSheet(
                ingredientName: $newIngredientName,
                onAdd: {
                    addNewIngredient()
                },
                onCancel: {
                    showAddIngredient = false
                    newIngredientName = ""
                }
            )
            .presentationDetents([.height(200)])
        }
        .onAppear {
            setupViewModel()
        }
    }
    
    // MARK: - Subviews
    
    /// The main list view showing shopping list items
    private func listView(viewModel: ShoppingListViewModel) -> some View {
        List {
            // Item counter section
            Section {
                HStack {
                    Image(systemName: "cart.fill")
                        .foregroundStyle(.blue)
                    
                    Text("\(itemCount) \(itemCount == 1 ? String(localized: "shoppingList.counter.item") : String(localized: "shoppingList.counter.items")) \(String(localized: "shoppingList.counter.inList"))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if viewModel.unboughtItems.count > 0 {
                        Text("\(viewModel.unboughtItems.count) \(String(localized: "shoppingList.counter.toBuy"))")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
            
            // Unbought items section
            if !filteredUnboughtItems.isEmpty {
                Section {
                    ForEach(filteredUnboughtItems) { item in
                        ShoppingListItemRow(
                            item: item,
                            onToggle: { viewModel.toggleBought(item) }
                        )
                        .accessibilityIdentifier("shoppingList.unboughtRow.\(item.id.uuidString)")
                    }
                    .onDelete { indexSet in
                        let itemsToDelete = indexSet.map { filteredUnboughtItems[$0] }
                        viewModel.removeItems(itemsToDelete)
                    }
                } header: {
                    Text("shoppingList.section.toBuy")
                }
            }
            
            // Bought items section
            if !filteredBoughtItems.isEmpty {
                Section {
                    ForEach(filteredBoughtItems) { item in
                        ShoppingListItemRow(
                            item: item,
                            onToggle: { viewModel.toggleBought(item) }
                        )
                        .accessibilityIdentifier("shoppingList.boughtRow.\(item.id.uuidString)")
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                addToPantry(item)
                            } label: {
                                Label("shoppingList.addToPantry", systemImage: "refrigerator.fill")
                            }
                            .tint(.green)
                        }
                    }
                    .onDelete { indexSet in
                        let itemsToDelete = indexSet.map { filteredBoughtItems[$0] }
                        viewModel.removeItems(itemsToDelete)
                    }
                } header: {
                    Text("shoppingList.section.bought")
                }
            }
            
            // No results message when searching
            if !searchText.isEmpty && filteredUnboughtItems.isEmpty && filteredBoughtItems.isEmpty {
                Section {
                    ContentUnavailableView(
                        "shoppingList.search.noResults",
                        systemImage: "magnifyingglass",
                        description: Text("shoppingList.search.noMatch")
                    )
                }
            }
        }
    }
    
    /// The empty state view shown when there are no items
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("shoppingList.emptyState.title", systemImage: "cart")
        } description: {
            Text("shoppingList.emptyState.description")
        }
        .accessibilityIdentifier("shoppingList.emptyState")
    }
    
    // MARK: - Helper Methods
    
    /// Sets up the view model with the repository
    private func setupViewModel() {
        if viewModel == nil {
            let repository = SDShoppingListRepository(context: modelContext)
            viewModel = ShoppingListViewModel(repository: repository)
        }
        viewModel?.loadShoppingList()
    }
    
    /// Adds a new ingredient to the shopping list
    private func addNewIngredient() {
        guard !newIngredientName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        // Create shopping list item WITHOUT adding to pantry
        let item = ShoppingListItem(
            ingredient: Ingredient(
                name: newIngredientName
            ),
            isBought: false
        )
        viewModel?.addItem(item)
        
        // Reset and dismiss
        newIngredientName = ""
        showAddIngredient = false
    }
    
    /// Adds a bought item to the pantry
    private func addToPantry(_ item: ShoppingListItem) {
        let pantryRepo = SDPantryProtocolRepository(context: modelContext)
        do {
            try pantryRepo.add(item.ingredient)
            viewModel?.removeItem(item)
        } catch {
            print("Error adding to pantry: \(error)")
        }
    }
}

// MARK: - Shopping List Item Row

/// A row view for displaying a single shopping list item.
///
/// Shows the ingredient name with a checkbox to mark it as bought/unbought.
private struct ShoppingListItemRow: View {
    let item: ShoppingListItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isBought ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isBought ? .green : .secondary)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("shoppingList.toggleButton.\(item.id.uuidString)")
            
            Text(item.ingredient.name.capitalized)
                .strikethrough(item.isBought)
                .foregroundStyle(item.isBought ? .secondary : .primary)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

// MARK: - Add Ingredient Sheet

/// Sheet for adding a new ingredient to the shopping list.
private struct AddIngredientSheet: View {
    @Binding var ingredientName: String
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField(String(localized: "shoppingList.add.placeholder"), text: $ingredientName)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTextFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        if !ingredientName.trimmingCharacters(in: .whitespaces).isEmpty {
                            onAdd()
                        }
                    }
                    .padding()
                
                Spacer()
            }
            .navigationTitle("shoppingList.add.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("shoppingList.add.cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("shoppingList.add.add") {
                        onAdd()
                    }
                    .disabled(ingredientName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
}

// MARK: - Preview

#Preview("With Items") {
    let container = try! ModelContainer(
        for: SDShoppingListItem.self, SDIngredient.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    // Create mock ingredients
    let tomato = SDIngredient(id: UUID(), name: "tomato")
    let onion = SDIngredient(id: UUID(), name: "onion")
    let garlic = SDIngredient(id: UUID(), name: "garlic")
    let cheese = SDIngredient(id: UUID(), name: "cheese")
    let milk = SDIngredient(id: UUID(), name: "milk")
    let bread = SDIngredient(id: UUID(), name: "bread")
    let eggs = SDIngredient(id: UUID(), name: "eggs")
    
    context.insert(tomato)
    context.insert(onion)
    context.insert(garlic)
    context.insert(cheese)
    context.insert(milk)
    context.insert(bread)
    context.insert(eggs)
    
    // Create mock shopping list items
    let item1 = SDShoppingListItem(id: UUID(), ingredient: tomato, isBought: false)
    let item2 = SDShoppingListItem(id: UUID(), ingredient: onion, isBought: false)
    let item3 = SDShoppingListItem(id: UUID(), ingredient: garlic, isBought: false)
    let item4 = SDShoppingListItem(id: UUID(), ingredient: cheese, isBought: true)
    let item5 = SDShoppingListItem(id: UUID(), ingredient: milk, isBought: false)
    let item6 = SDShoppingListItem(id: UUID(), ingredient: bread, isBought: true)
    let item7 = SDShoppingListItem(id: UUID(), ingredient: eggs, isBought: false)
    
    context.insert(item1)
    context.insert(item2)
    context.insert(item3)
    context.insert(item4)
    context.insert(item5)
    context.insert(item6)
    context.insert(item7)
    
    return NavigationStack {
        ShoppingListView()
    }
    .modelContainer(container)
}
#Preview("Empty State") {
    let container = try! ModelContainer(
        for: SDShoppingListItem.self, SDIngredient.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    return NavigationStack {
        ShoppingListView()
    }
    .modelContainer(container)
}

