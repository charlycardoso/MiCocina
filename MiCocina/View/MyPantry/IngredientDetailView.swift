//
//  IngredientDetailView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 10/04/26.
//

import SwiftUI
import SwiftData

struct IngredientDetailView: View {
    @ObservedObject private var viewModel: MyPantryModuleViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let originalIngredient: Ingredient
    @State private var name: String
    @State private var quantity: Int
    @State private var isEditing: Bool = false
    @State private var showAlert: (show: Bool, title: String, message: String) = (false, "", "")
    @State private var showDeleteConfirmation: Bool = false
    @State private var shouldDismissOnOK = false
    
    init(ingredient: Ingredient, viewModel: MyPantryModuleViewModel) {
        self.originalIngredient = ingredient
        self.viewModel = viewModel
        self._name = State(initialValue: ingredient.name.capitalized)
        self._quantity = State(initialValue: ingredient.quantity)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if isEditing {
                        TextField("common.ingredient.namePlaceholder", text: $name)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        HStack {
                            Text("common.name")
                            Spacer()
                            Text(name)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if isEditing {
                        Stepper(value: $quantity, in: 0...999) {
                            HStack {
                                Text("common.quantity")
                                Spacer()
                                Text("\(quantity)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        HStack {
                            Text("common.quantity")
                            Spacer()
                            HStack {
                                Text("\(quantity)")
                                    .foregroundColor(.secondary)
                                Circle()
                                    .fill(quantity <= 3 ? Color.red : Color.green)
                                    .frame(width: 12, height: 12)
                            }
                        }
                    }
                } header: {
                    Text("ingredientDetail.sectionHeader")
                } footer: {
                    if isEditing {
                        Text("ingredientDetail.editingFooter")
                    } else {
                        Text("ingredientDetail.viewFooter")
                    }
                }
                
                if !isEditing {
                    Section {
                        Button(action: {
                            // Add to shopping list functionality could go here
                        }) {
                            HStack {
                                Image(systemName: "basket")
                                Text("ingredientDetail.addToShoppingList")
                            }
                        }
                        .foregroundColor(.blue)
                        
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("ingredientDetail.deleteButton")
                            }
                        }
                        .foregroundColor(.red)
                    } header: {
                        Text("ingredientDetail.actionsHeader")
                    }
                }
            }
            .navigationTitle(isEditing ? String(localized: "ingredientDetail.navigationTitle.edit") : String(localized: "ingredientDetail.navigationTitle.view"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if isEditing {
                        Button("common.cancel") {
                            cancelEditing()
                        }
                    } else {
                        Button("ingredientDetail.close") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if isEditing {
                        Button("common.save") {
                            saveChanges()
                        }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    } else {
                        Button("ingredientDetail.edit") {
                            isEditing = true
                        }
                    }
                }
            }
            .alert(
                showAlert.title,
                isPresented: $showAlert.show
            ) {
                Button("common.ok") {
                    if shouldDismissOnOK {
                        dismiss()
                    }
                }
            } message: {
                Text(showAlert.message)
            }
            .confirmationDialog(
                String(localized: "ingredientDetail.deleteConfirm.title"),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("common.delete", role: .destructive) {
                    deleteIngredient()
                }
                Button("common.cancel", role: .cancel) { }
            } message: {
                Text("ingredientDetail.deleteConfirm.message")
            }
        }
    }
    
    private func cancelEditing() {
        name = originalIngredient.name.capitalized
        quantity = originalIngredient.quantity
        isEditing = false
    }
    
    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            shouldDismissOnOK = false
            showAlert = (true, String(localized: "common.error"), String(localized: "common.ingredient.emptyNameError"))
            return
        }
        
        // Check if we're changing the name and if the new name already exists
        let normalizedNewName = trimmedName.normalize()
        let normalizedOriginalName = originalIngredient.name
        
        if normalizedNewName != normalizedOriginalName {
            let testIngredient = Ingredient(name: trimmedName, quantity: quantity)
            if viewModel.exists(testIngredient) {
                shouldDismissOnOK = false
                showAlert = (
                    true,
                    String(localized: "common.ingredient.duplicateTitle"),
                    String(localized: "ingredientDetail.duplicate.message")
                )
                return
            }
        }
        
        do {
            // Remove the old ingredient
            try viewModel.remove(originalIngredient)
            
            // Add the updated ingredient
            let updatedIngredient = Ingredient(
                id: originalIngredient.id,
                name: trimmedName,
                quantity: quantity
            )
            try viewModel.add(updatedIngredient)
            
            shouldDismissOnOK = true
            showAlert = (true, String(localized: "ingredientDetail.saved.title"), String(localized: "ingredientDetail.saved.message"))
            isEditing = false
        } catch {
            shouldDismissOnOK = false
            showAlert = (true, String(localized: "common.error"), String(localized: "ingredientDetail.saveError"))
        }
    }
    
    private func deleteIngredient() {
        do {
            try viewModel.remove(originalIngredient)
            dismiss()
        } catch {
            shouldDismissOnOK = false
            showAlert = (true, String(localized: "common.error"), String(localized: "ingredientDetail.deleteError"))
        }
    }
}

#Preview {
    let schema = Schema([
        SDRecipe.self,
        SDIngredient.self,
        SDRecipeIngredient.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    let mockVM = MyPantryModuleViewModel.mockForPreview(context: container.mainContext)
    let sampleIngredient = Ingredient(name: "Tomate", quantity: 2)
    
    return IngredientDetailView(ingredient: sampleIngredient, viewModel: mockVM)
        .modelContainer(container)
}
