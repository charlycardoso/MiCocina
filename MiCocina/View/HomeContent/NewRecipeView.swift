//
//  NewRecipeView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import SwiftUI
import SwiftData

struct NewRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var recipeName: String = ""
    @State private var selectedMealType: MealType = .other
    @State private var isFavorite: Bool = false
    @State private var ingredientText: String = ""
    @State private var ingredients: [IngredientItem] = []
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var pantryIngredientNames: [String] = []

    private var filteredSuggestions: [String] {
        let trimmed = ingredientText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return pantryIngredientNames.filter { name in
            name.localizedCaseInsensitiveContains(trimmed) &&
            !ingredients.contains(where: { $0.name.lowercased() == name.lowercased() })
        }
    }

    private var homeContentViewModel: HomeContentViewModel
    private var existingRecipe: Recipe?
    
    private var isEditMode: Bool {
        existingRecipe != nil
    }
    
    private var navigationTitle: String {
        isEditMode ? String(localized: "editRecipe.navigationTitle") : String(localized: "newRecipe.navigationTitle")
    }
    
    // Helper struct to track ingredient and its required status
    struct IngredientItem: Identifiable, Hashable {
        let id = UUID()
        var name: String
        var isRequired: Bool = true
    }

    init(viewModel: HomeContentViewModel, recipe: Recipe? = nil) {
        self.homeContentViewModel = viewModel
        self.existingRecipe = recipe
        
        // Pre-populate fields if editing
        if let recipe = recipe {
            _recipeName = State(initialValue: recipe.name)
            _selectedMealType = State(initialValue: recipe.mealType)
            _isFavorite = State(initialValue: recipe.isFavorite)
            _ingredients = State(initialValue: recipe.ingredients.map { 
                IngredientItem(name: $0.ingredientName, isRequired: $0.isRequired)
            })
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Mark as Favorite Section
                    HStack {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(isFavorite ? .red : .gray)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("common.markAsFavorite")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text("common.recipe.favoriteDescription")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isFavorite)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle())
                            .accessibilityIdentifier("newRecipe.favoriteToggle")
                    }
                    .padding(8)

                    recipeBasicInfo
                    ingredientsSection
                }
                .padding()
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common.cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("newRecipe.cancelButton")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.save") {
                        saveRecipe()
                    }
                    .disabled(recipeName.isEmpty || ingredients.isEmpty)
                    .accessibilityIdentifier("newRecipe.saveButton")
                }
            }
            .alert("common.information", isPresented: $showAlert) {
                Button("common.ok") { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                let pantry = homeContentViewModel.getPantry()
                pantryIngredientNames = pantry.map { $0.name }.sorted()
            }
        }
    }

    @ViewBuilder
    private var recipeBasicInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("common.basicInfo")
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 8) {
                Text("common.recipeName")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("common.recipeNamePlaceholder", text: $recipeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityIdentifier("newRecipe.recipeNameField")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("common.mealTypeLabel")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Picker("common.mealTypeLabel", selection: $selectedMealType) {
                    Text("mealType.breakfast").tag(MealType.breakFast)
                    Text("mealType.lunch").tag(MealType.lunch)
                    Text("mealType.dinner").tag(MealType.dinner)
                    Text("mealType.other").tag(MealType.other)
                }
                .pickerStyle(.segmented)
                .glassEffect()
                .accessibilityIdentifier("newRecipe.mealTypePicker")
            }
        }
        .padding()
    }

    @ViewBuilder
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("common.ingredients")
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("common.addIngredientPlaceholder", text: $ingredientText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("newRecipe.ingredientTextField")
                        .onSubmit {
                            addIngredient()
                        }

                    Button("common.add") {
                        addIngredient()
                    }
                    .tint(.cSecondary)
                    .disabled(ingredientText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("newRecipe.addIngredientButton")
                }

                if !filteredSuggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(filteredSuggestions.prefix(5), id: \.self) { suggestion in
                            Button {
                                ingredientText = suggestion
                                addIngredient()
                            } label: {
                                HStack {
                                    Image(systemName: "basket")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(suggestion)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                            }
                            if suggestion != filteredSuggestions.prefix(5).last {
                                Divider().padding(.leading, 32)
                            }
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                if ingredients.isEmpty {
                    Text("common.noIngredientsAdded")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    // Use VStack (not LazyVStack) with value-based ForEach.
                    // ForEach($array) in a LazyVStack crashes when an element is
                    // deleted because the lazy renderer may still hold a binding
                    // to the removed element. A regular VStack renders eagerly and
                    // handles removal safely. The toggle binding is constructed
                    // manually via index lookup to avoid dangling-binding crashes.
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(ingredients) { ingredient in
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)

                                    Text(ingredient.name)
                                        .font(.body)

                                    Spacer()

                                    Button {
                                        removeIngredient(ingredient: ingredient)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundStyle(.red)
                                    }
                                    .accessibilityIdentifier("newRecipe.removeIngredient.\(ingredient.id)")
                                }

                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("common.ingredient.required")
                                            .font(.subheadline)
                                            .fontWeight(.medium)

                                        Text("common.ingredient.requiredDescription")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Toggle("", isOn: Binding(
                                        get: { ingredient.isRequired },
                                        set: { newValue in
                                            if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                                                ingredients[index].isRequired = newValue
                                            }
                                        }
                                    ))
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle())
                                }
                                .padding(.leading, 20)
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func addIngredient() {
        let trimmedIngredient = ingredientText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedIngredient.isEmpty else { return }
        guard !ingredients.contains(where: { $0.name.lowercased() == trimmedIngredient.lowercased() }) else {
            alertMessage = NSLocalizedString("common.duplicateIngredient", comment: "")
            showAlert = true
            return
        }

        ingredients.append(IngredientItem(name: trimmedIngredient, isRequired: true))
        ingredientText = ""
    }

    private func removeIngredient(ingredient: IngredientItem) {
        ingredients.removeAll { $0.id == ingredient.id }
    }

    private func saveRecipe() {
        guard !recipeName.isEmpty && !ingredients.isEmpty else { return }

        do {
            // Create recipe ingredients with names and required status
            let recipeIngredients = Set(ingredients.map { ingredient in
                RecipeIngredient(ingredientName: ingredient.name, isRequired: ingredient.isRequired)
            })

            // Create or update the recipe
            let recipe = Recipe(
                id: existingRecipe?.id ?? UUID(),
                name: recipeName,
                ingredients: recipeIngredients,
                mealType: selectedMealType,
                isFavorite: isFavorite
            )

            // Save or update using the view model
            if isEditMode {
                try homeContentViewModel.update(recipe)
            } else {
                try homeContentViewModel.save(recipe)
            }

            // Refresh the recipes list
            homeContentViewModel.getAllRecipes()

            dismiss()

        } catch {
            alertMessage = String(format: NSLocalizedString("common.saveRecipeError", comment: ""), error.localizedDescription)
            showAlert = true
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

    let mockVM = HomeContentViewModel.mockForPreview(context: container.mainContext)

    return NewRecipeView(viewModel: mockVM)
        .modelContainer(container)
}
