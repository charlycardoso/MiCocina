//
//  HomeContent.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import SwiftUI
import SwiftData

struct HomeContent: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var viewModel: HomeContentViewModel
    @State private var searchRecipe: String = ""
    @State private var showSaveNewRecipeView: Bool = false
    @State private var markRecipeAsFavorite: Bool = false
    @State private var selectedRecipe: RecipeViewData?
    @State private var applyFilters: Bool = false
    @State private var mealTypeFilter: MealType = .other
    @State private var filterOnlyCookables: Bool = false
    
    private var filteredRecipes: [RecipeGroup] {
        var groups = viewModel.recipes

        if applyFilters {
            groups = groups.filter { $0.mealType == mealTypeFilter }
        }

        if filterOnlyCookables {
            groups = groups.compactMap { group in
                let cookable = group.recipes.filter { $0.canCook }
                guard !cookable.isEmpty else { return nil }
                return RecipeGroup(mealType: group.mealType, recipes: cookable)
            }
        }

        if !searchRecipe.isEmpty {
            groups = groups.compactMap { group in
                let matched = group.recipes.filter { $0.name.localizedCaseInsensitiveContains(searchRecipe) }
                guard !matched.isEmpty else { return nil }
                return RecipeGroup(mealType: group.mealType, recipes: matched)
            }
        }

        return groups
    }
    
    private var alertViewMessage: String {
        let action = (selectedRecipe?.isFavorite ?? false) 
            ? String(localized: "homeContent.alert.removeFavorite") 
            : String(localized: "homeContent.alert.addFavorite")
        let recipeName = selectedRecipe?.name.lowercased() ?? ""
        return String(localized: "homeContent.alert.message \(action) \(recipeName)")
    }

    init(viewModel: HomeContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.recipes.isEmpty {
                    Spacer()
                    ProgressView()
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else if filteredRecipes.isEmpty {
                    FilterRow()
                        .padding(.horizontal)
                    Spacer()
                    if searchRecipe.isEmpty {
                        Text("homeContent.emptyState")
                            .padding()
                            .multilineTextAlignment(.center)
                            .font(.callout)
                            .foregroundStyle(.gray)
                            .accessibilityIdentifier("homeContent.emptyState")
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundStyle(.gray)
                            
                            Text("homeContent.noSearchResults")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Text(verbatim: String(format: NSLocalizedString("homeContent.noSearchResultsMessage", comment: ""), searchRecipe))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                    Spacer()
                } else {
                    FilterRow()
                        .padding(.horizontal)

                    ScrollView {
                        ForEach(filteredRecipes, id: \.mealType) { recipeGroup in
                            Section(header:
                                SeparatorText(mealTypeName(for: recipeGroup.mealType))
                            ) {
                                ForEach(recipeGroup.recipes, id: \.id) { recipe in
                                    NavigationLink {
                                        RecipeDetailView(recipe: recipe, viewModel: viewModel)
                                    } label: {
                                        RowContent(for: recipe)
                                            .glassEffect(.identity)
                                    }
                                    .accessibilityIdentifier("homeContent.recipeRow.\(recipe.id.uuidString)")
                                    Divider()
                                }
                            }
                        }
                    }
                    .accessibilityIdentifier("homeContent.recipeList")
                }

                Spacer()

            }
            .alert(alertViewMessage, isPresented: $markRecipeAsFavorite, actions: {
                Button(role: .confirm) {
                    guard let recipe = selectedRecipe,
                          var shownRecipe = viewModel.getByID(recipe.id) else { return
                    }
                    shownRecipe.isFavorite = true
                    try? viewModel.update(shownRecipe)
                    viewModel.getAllRecipes()
                    markRecipeAsFavorite = false
                    selectedRecipe = nil
                }

                Button(role: .cancel) {
                    markRecipeAsFavorite = false
                    selectedRecipe = nil
                }
            })
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSaveNewRecipeView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("homeContent.addButton")
                }
            })
            .navigationTitle("homeContent.navigationTitle")
            .searchable(text: $searchRecipe, prompt: "homeContent.searchPrompt")
            .onAppear {
                viewModel.getAllRecipes()
            }
            .sheet(isPresented: $showSaveNewRecipeView) {
                NewRecipeView(viewModel: viewModel)
            }
        }
    }

    @ViewBuilder
    private func FilterRow() -> some View {
        HStack {
            Spacer()

            Menu {
                Section(String(localized: "homeContent.filter.mealTypeSection")) {
                    Button(String(localized: "homeContent.filter.showAll")) {
                        applyFilters = false
                    }
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        FilterRowContent(mealType: mealType)
                    }
                }

                Section(String(localized: "homeContent.filter.optionsSection")) {
                    Button(action: {
                        filterOnlyCookables.toggle()
                    }) {
                        Label {
                            Text("homeContent.filter.onlyCookable")
                        } icon: {
                            Image(systemName: filterOnlyCookables ? "checkmark" : "circle")
                        }
                    }
                    Button(action: {
                        applyFilters = false
                        filterOnlyCookables = false
                        mealTypeFilter = .other
                    }) {
                        Label("homeContent.filter.deleteFilters", systemImage: "trash")
                    }
                }

            } label: {
                Label("homeContent.filter.label", systemImage: "line.3.horizontal.decrease")
            }
        }
    }

    @ViewBuilder
    private func FilterRowContent(mealType: MealType) -> some View {
        let isSelected = applyFilters == false ? false : mealTypeFilter == mealType

        Button(action: {
            applyFilters = true
            mealTypeFilter = mealType
        }) {
            Label {
                Text(mealTypeName(for: mealType))
            } icon: {
                Image(systemName: isSelected ? "checkmark" : "circle")
            }
        }
    }

    @ViewBuilder
    private func SeparatorText(_ text: String) -> some View {
        Text(text)
        .font(.subheadline)
        .foregroundStyle(.gray)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func RowContent(for recipe: RecipeViewData) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .foregroundStyle(.accent)
                Text(recipe.canCook ? "homeContent.canCook" : "homeContent.cannotCook")
                    .font(.caption)
                    .foregroundStyle(.accent)
                    .padding(2)
                    .padding(.horizontal, 2)
                    .background(recipe.canCook ? .cSecondary : .gray)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            Spacer()

            Button {
                // display an alert before to update the recipe
                selectedRecipe = recipe
                markRecipeAsFavorite = true
            } label: {
                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.cPrimary)
            }
        }
        .padding()
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

    return HomeContent(viewModel: mockVM)
        .modelContainer(container)
}
