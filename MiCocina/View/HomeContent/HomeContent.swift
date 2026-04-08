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

    init(viewModel: HomeContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.recipes.isEmpty || viewModel.possibleRecipes.isEmpty {
                    Text("No tienes recetas disponibles. \nBusca alguna receta o crea una nueva.")
                        .padding()
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundStyle(.gray)
                } else {
                    ScrollView {
                        ForEach(viewModel.recipes, id: \.mealType) { recipeGroup in
                            Section(header:
                                SeparatorText(mealTypeName(for: recipeGroup.mealType))
                            ) {
                                ForEach(recipeGroup.recipes, id: \.id) { recipe in
                                    NavigationLink {
                                        RecipeDetailView(recipe: recipe, viewModel: viewModel)
                                    } label: {
                                        RowContent(for: recipe)
                                            .padding(.vertical, 2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        showSaveNewRecipeView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(.blue)
                }
            })
            .navigationTitle("Mis recetas")
            .searchable(text: $searchRecipe, prompt: .init("Buscar recetas"))
            .onAppear {
                viewModel.getAllRecipes()
            }
            .sheet(isPresented: $showSaveNewRecipeView) {
                NewRecipeView(viewModel: viewModel)
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
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(recipe.name)
                    .fontWeight(.regular)
                    .font(.body)

                Spacer()

                if recipe.isFavorite {
                    Button {
                        // display an alert before to update the recipe
                    } label: {
                        Image(systemName: "heart.fill")
                            .padding(8)
                            .foregroundStyle(.red)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }

            Text(recipe.canCook ? "Cocinable" : "No cocinable")
                .foregroundStyle(recipe.canCook ? Color.green : Color.orange)
                .font(.footnote)
                .fontWeight(.medium)
                .font(.caption)
                .padding(6)
                .padding(.horizontal, 4)
                .background {
                    (recipe.canCook ? Color.green : Color.orange).opacity(0.1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1)
        }
        .padding(.horizontal)
    }

    private func mealTypeName(for mealType: MealType) -> String {
        switch mealType {
        case .breakFast:
            return "Desayuno"
        case .lunch:
            return "Comida"
        case .dinner:
            return "Cena"
        case .other:
            return "Otros"
        }
    }
}

#Preview {
    let schema = Schema([
        Item.self,
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
