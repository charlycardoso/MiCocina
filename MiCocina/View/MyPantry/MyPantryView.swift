//
//  MyPantryView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 09/04/26.
//

import SwiftUI
import SwiftData

struct MyPantryView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var viewModel: MyPantryModuleViewModel
    @State private var ingredients: Set<Ingredient> = []
    @State private var showAlert: (show: Bool, title: String, message: String) = (false, "", "")
    @State private var showAddIngredientView = false
    @State private var selectedIngredient: Ingredient?
    @State private var ingredientToDelete: Ingredient?
    @State private var searchIngredient: String = ""

    init(viewModel: MyPantryModuleViewModel) {
        self.viewModel = viewModel
    }

    private var filteredIngredients: [Ingredient] {
        let sorted = ingredients.sorted { $0.name < $1.name }
        guard !searchIngredient.isEmpty else { return sorted }
        return sorted.filter { $0.name.localizedCaseInsensitiveContains(searchIngredient) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if ingredients.isEmpty {
                    Text("myPantry.emptyState")
                        .padding()
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundStyle(.gray)
                        .accessibilityIdentifier("myPantry.emptyState")
                } else if filteredIngredients.isEmpty {
                    Text("myPantry.noSearchResults")
                        .padding()
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundStyle(.gray)
                        .accessibilityIdentifier("myPantry.noSearchResults")
                } else {
                    List(filteredIngredients, id: \.id) { ingredient in
                        IngredientRow(for: ingredient)
                            .contentShape(Rectangle())
                            .accessibilityIdentifier("myPantry.ingredientRow.\(ingredient.id.uuidString)")
                            .onTapGesture {
                                selectedIngredient = ingredient
                            }
                            .swipeActions(allowsFullSwipe: false) {
                                Button(role: .confirm) {
                                    // TODO: Add to shopping list functionality
                                } label: {
                                    Label("myPantry.swipe.buy", systemImage: "basket")
                                }
                                .tint(Color.blue)
                                Button(role: .destructive) {
                                    ingredientToDelete = ingredient
                                    showAlert = (
                                        true,
                                        String(localized: "myPantry.deleteAlert.title"),
                                        String(format: String(localized: "myPantry.deleteAlert.message"), ingredient.name)
                                    )
                                } label: {
                                    Label("myPantry.swipe.delete", systemImage: "trash")
                                }
                            }
                    }
                    .listStyle(.plain)
                    .padding(.top, 16)
                    .accessibilityIdentifier("myPantry.ingredientList")
                }
            }
            .navigationTitle("myPantry.navigationTitle")
            .searchable(text: $searchIngredient)
            .toolbar(content: {
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        showAddIngredientView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("myPantry.addButton")
                }
            })
        }
        .onAppear {
            viewModel.refresh()
            ingredients = viewModel.pantry
        }
        .onChange(of: viewModel.pantry) { oldValue, newValue in
            ingredients = newValue
        }
        .sheet(isPresented: $showAddIngredientView) {
            AddIngredientView(viewModel: viewModel)
                .onDisappear {
                    refreshIngredients()
                }
        }
        .sheet(item: $selectedIngredient) { ingredient in
            IngredientDetailView(ingredient: ingredient, viewModel: viewModel)
                .onDisappear {
                    refreshIngredients()
                }
        }
        .alert(isPresented: $showAlert.show) {
            AlertView(
                title: showAlert.title,
                message: showAlert.message,
                type: .delete
            ) { result in
                if result == .confirm, let ingredient = ingredientToDelete {
                    deleteIngredient(ingredient)
                }
                ingredientToDelete = nil
            }
        }

    }
    
    private func deleteIngredient(_ ingredient: Ingredient) {
        do {
            try viewModel.remove(ingredient)
            refreshIngredients()
        } catch {
            showAlert = (true, String(localized: "common.error"), String(localized: "myPantry.deleteAlert.error"))
        }
    }
    
    private func refreshIngredients() {
        // Force a small delay to ensure SwiftData has processed changes
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            ingredients = viewModel.getPantry()
        }
    }

    @ViewBuilder
    private func IngredientRow(for ingredient: Ingredient) -> some View {
        HStack(alignment: .center) {
            Text(ingredient.name.capitalized)
            Spacer()
            Text("\(ingredient.quantity)")
                .frame(width: 20, height: 20)
                .font(.footnote)
                .fontWeight(.regular)
                .foregroundStyle(.white)
                .background {
                    Circle()
                        .fill(ingredient.quantity <= 3 ? Color.cPrimary : Color.cSecondary)
                }
        }
    }
}

#Preview {
    let schema = Schema([
        SDPantryItem.self,
        SDRecipe.self,
        SDIngredient.self,
        SDRecipeIngredient.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let mockVM = MyPantryModuleViewModel(context: container.mainContext)
    return MyPantryView(viewModel: mockVM)
        .modelContainer(container)
}
