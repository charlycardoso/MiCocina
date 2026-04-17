//
//  RecipeDetailView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let recipe: RecipeViewData
    private let homeContentViewModel: HomeContentViewModel

    @State private var showDeleteAlert: Bool = false
    @State private var showEditView: Bool = false
    @State private var markAsFavorite: Bool = false
    @State private var fullRecipe: Recipe?
    @State private var helpMessage: (activate: Bool, message: String) = (false, "")
    private var alertViewMessage: String {
        let action = (fullRecipe?.isFavorite ?? false)
            ? String(localized: "homeContent.alert.removeFavorite")
            : String(localized: "homeContent.alert.addFavorite")
        let recipeName = fullRecipe?.name.lowercased() ?? ""
        return String(localized: "homeContent.alert.message \(action) \(recipeName)")
    }

    init(recipe: RecipeViewData, viewModel: HomeContentViewModel) {
        self.recipe = recipe
        self.homeContentViewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    cookingStatusSection
                    ingredientsSection
                }
                .padding()
            }
            .navigationTitle(recipe.name)
            .navigationSubtitle(recipe.mealType.rawValue)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        markAsFavorite.toggle()
                    } label: {
                        Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(Color.cPrimary)
                    }
                    .accessibilityIdentifier("recipeDetail.favoriteButton")

                    Menu {
                        Button("recipeDetail.edit") {
                            showEditView = true
                        }

                        Button("recipeDetail.delete", role: .destructive) {
                            showDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                loadFullRecipe()
            }
            .alert(alertViewMessage, isPresented: $markAsFavorite, actions: {
                Button(String(localized: "common.confirm"), role: .confirm) {
                    toggleFavorite()
                }
                .accessibilityIdentifier("recipeDetailView.alert.confirmButton")

                Button(String(localized: "common.cancel"), role: .cancel) {
                    markAsFavorite = false
                }
                .accessibilityIdentifier("recipeDetailView.alert.cancelButton")
            })
            .alert(helpMessage.message, isPresented: $helpMessage.activate, actions: {
                Button("common.close", role: .close) { }
            })
            .alert("recipeDetail.deleteAlertTitle", isPresented: $showDeleteAlert) {
                Button("common.cancel", role: .cancel) { }
                Button("recipeDetail.delete", role: .destructive) {
                    deleteRecipe()
                }
            } message: {
                Text(verbatim: String(format: NSLocalizedString("recipeDetail.deleteConfirmMessage", comment: ""), recipe.name))
            }
            .sheet(isPresented: $showEditView) {
                if let fullRecipe = fullRecipe {
                    NewRecipeView(viewModel: homeContentViewModel, recipe: fullRecipe)
                }
            }
        }
    }

    @ViewBuilder
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("common.ingredients")
                .font(.headline)
                .foregroundStyle(.primary)

            if let fullRecipe = fullRecipe {
                let sortedIngredients = Array(fullRecipe.ingredients).sorted(by: { $0.ingredientName < $1.ingredientName })
                
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(sortedIngredients) { recipeIngredient in
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recipeIngredient.ingredientName.capitalized)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Text(recipeIngredient.isRequired ? "common.ingredient.required" : "recipeDetail.optional")
                                    .font(.caption)
                                    .foregroundStyle(.systemBackground)
                                    .padding(2)
                                    .padding(.horizontal, 2)
                                    .background {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(recipeIngredient.isRequired ? Color.cAccent : Color.cSecondary)
                                    }
                            }
                            
                            Spacer()
                            
                            // Show if ingredient is available in pantry
                            if homeContentViewModel.exists(Ingredient(name: recipeIngredient.ingredientName)) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(.green)
                            } else {
                                Button {
                                    withAnimation(.bouncy) {
                                        let toggle = !helpMessage.activate
                                        helpMessage = (toggle, "No cuentas con este ingrediente. Puedes agregarlo desde la sección de ingredientes.")
                                    }
                                } label: {
                                    Image(systemName: "exclamationmark.circle")
                                        .font(.body)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                        .accessibilityIdentifier("recipeDetail.ingredientRow.\(recipeIngredient.id.uuidString)")
                        Divider()
                    }
                }
            } else {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("recipeDetail.loadingIngredients")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var cookingStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: recipe.canCook ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(recipe.canCook ? .green : .orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.canCook ? (recipe.missingCount == 0 ? "recipeDetail.canCookStatus" : "recipeDetail.canCookWithMissing") : "recipeDetail.cannotCookStatus")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(recipe.canCook ? .green : .orange)

                    if recipe.canCook && recipe.missingCount != 0 {
                        Text(verbatim: String(format: NSLocalizedString("recipeDetail.needMoreIngredients", comment: ""), recipe.missingCount))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if !recipe.canCook {
                        let key = recipe.missingCount == 1
                            ? "recipeDetail.missingIngredients.singular"
                            : "recipeDetail.missingIngredients.plural"
                        Text(verbatim: String(format: NSLocalizedString(key, comment: ""), recipe.missingCount))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(recipe.canCook ? Color.green.opacity(0.05) : Color.orange.opacity(0.05))
                .stroke((recipe.canCook ? Color.green : Color.orange).opacity(0.3), lineWidth: 1)
        }
        .accessibilityIdentifier("recipeDetail.cookingStatusSection")
    }

    private func mealTypeName(for mealType: MealType) -> String {
        switch mealType {
        case .breakFast:
            return NSLocalizedString("mealType.breakfast", comment: "")
        case .lunch:
            return NSLocalizedString("mealType.lunch", comment: "")
        case .dinner:
            return NSLocalizedString("mealType.dinner", comment: "")
        case .other:
            return NSLocalizedString("mealType.other", comment: "")
        }
    }

    private func loadFullRecipe() {
        fullRecipe = homeContentViewModel.getByID(recipe.id)
    }

    private func toggleFavorite() {
        guard var fullRecipe = fullRecipe else { return }

        do {
            fullRecipe.isFavorite = true
            try homeContentViewModel.update(fullRecipe)
            homeContentViewModel.getAllRecipes()

            // Update local state
            self.fullRecipe = fullRecipe
            self.markAsFavorite = false
        } catch {
            // Handle error
            print("Error updating favorite status: \(error)")
        }
    }

    private func deleteRecipe() {
        guard let fullRecipe = fullRecipe else { return }

        dismiss()

        DispatchQueue.main.async {
            do {
                try homeContentViewModel.delete(fullRecipe)
                homeContentViewModel.getAllRecipes()
            } catch {
                print("Error deleting recipe: \(error)")
            }
        }
    }
}

#Preview("Recipe Detail") {
    let schema = Schema([
        SDPantryItem.self,
        SDRecipe.self,
        SDIngredient.self,
        SDRecipeIngredient.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let mockVM = HomeContentViewModel.mockForPreview(context: container.mainContext)
    let mockRecipe = RecipeViewData(
        id: UUID(),
        name: "Pasta Carbonara",
        mealType: .lunch,
        isFavorite: true,
        canCook: false,
        missingCount: 2
    )

    return NavigationStack {
        RecipeDetailView(recipe: mockRecipe, viewModel: mockVM)
    }
    .modelContainer(container)
}
