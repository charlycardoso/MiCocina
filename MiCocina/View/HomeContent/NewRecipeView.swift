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
    @State private var ingredients: [String] = []
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    private var homeContentViewModel: HomeContentViewModel

    init(viewModel: HomeContentViewModel) {
        self.homeContentViewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    recipeBasicInfo
                    ingredientsSection
                }
                .padding()
            }
            .navigationTitle("newRecipe.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common.cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.save") {
                        saveRecipe()
                    }
                    .disabled(recipeName.isEmpty || ingredients.isEmpty)
                }
            }
            .alert("common.information", isPresented: $showAlert) {
                Button("common.ok") { }
            } message: {
                Text(alertMessage)
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
                .pickerStyle(SegmentedPickerStyle())
            }

            Toggle("common.markAsFavorite", isOn: $isFavorite)
                .toggleStyle(SwitchToggleStyle())
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(Color(.systemBackground))
        }
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
                        .onSubmit {
                            addIngredient()
                        }

                    Button("common.add") {
                        addIngredient()
                    }
                    .disabled(ingredientText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if ingredients.isEmpty {
                    Text("common.noIngredientsAdded")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)

                                Text(ingredient)
                                    .font(.body)

                                Spacer()

                                Button {
                                    removeIngredient(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(Color(.systemBackground))
        }
    }

    private func addIngredient() {
        let trimmedIngredient = ingredientText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedIngredient.isEmpty else { return }
        guard !ingredients.contains(where: { $0.lowercased() == trimmedIngredient.lowercased() }) else {
            alertMessage = NSLocalizedString("common.duplicateIngredient", comment: "")
            showAlert = true
            return
        }

        ingredients.append(trimmedIngredient)
        ingredientText = ""
    }

    private func removeIngredient(at index: Int) {
        ingredients.remove(at: index)
    }

    private func saveRecipe() {
        guard !recipeName.isEmpty && !ingredients.isEmpty else { return }

        do {
            // Create recipe ingredients with just the names
            let recipeIngredients = Set(ingredients.map { ingredientName in
                RecipeIngredient(ingredientName: ingredientName, isRequired: true)
            })

            // Create the recipe
            let recipe = Recipe(
                name: recipeName,
                ingredients: recipeIngredients,
                mealType: selectedMealType,
                isFavorite: isFavorite
            )

            // Save using the view model
            try homeContentViewModel.save(recipe)

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
