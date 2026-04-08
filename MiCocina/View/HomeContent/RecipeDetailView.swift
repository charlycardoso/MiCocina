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
    @State private var fullRecipe: Recipe?
    
    init(recipe: RecipeViewData, viewModel: HomeContentViewModel) {
        self.recipe = recipe
        self.homeContentViewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                ingredientsSection
                cookingStatusSection
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(recipe.isFavorite ? .red : .gray)
                }
                
                Menu {
                    Button("Editar") {
                        showEditView = true
                    }
                    
                    Button("Eliminar", role: .destructive) {
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
        .alert("Eliminar Receta", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                deleteRecipe()
            }
        } message: {
            Text("¿Estás seguro de que deseas eliminar la receta \"\(recipe.name)\"? Esta acción no se puede deshacer.")
        }
        .sheet(isPresented: $showEditView) {
            if let fullRecipe = fullRecipe {
                EditRecipeView(recipe: fullRecipe, viewModel: homeContentViewModel)
            }
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(mealTypeName(for: recipe.mealType))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        }
    }
    
    @ViewBuilder
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ingredientes")
                .font(.headline)
                .foregroundStyle(.primary)
            
            if let fullRecipe = fullRecipe {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(fullRecipe.ingredients.sorted(by: { $0.ingredient.name < $1.ingredient.name })), id: \.ingredient.id) { recipeIngredient in
                        HStack(alignment: .center, spacing: 12) {
                            Image(systemName: recipeIngredient.isRequired ? "circle.fill" : "circle")
                                .font(.caption)
                                .foregroundStyle(recipeIngredient.isRequired ? .green : .orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(recipeIngredient.ingredient.name.capitalized)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                if !recipeIngredient.isRequired {
                                    Text("Opcional")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Show if ingredient is available in pantry
                            if homeContentViewModel.exists(recipeIngredient.ingredient) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(.green)
                            } else {
                                Image(systemName: "exclamationmark.circle")
                                    .font(.body)
                                    .foregroundStyle(.orange)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            } else {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Cargando ingredientes...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
    }
    
    @ViewBuilder
    private var cookingStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estado de la receta")
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: recipe.canCook ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(recipe.canCook ? .green : .orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.canCook ? "¡Puedes cocinar esta receta!" : "Te faltan algunos ingredientes")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(recipe.canCook ? .green : .orange)
                        
                        if !recipe.canCook {
                            Text("Te faltan \(recipe.missingCount) ingrediente\(recipe.missingCount == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                if recipe.canCook {
                    Button {
                        // Future: Add cooking mode or instructions
                    } label: {
                        HStack {
                            Image(systemName: "flame.fill")
                            Text("Empezar a cocinar")
                        }
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(recipe.canCook ? Color.green.opacity(0.05) : Color.orange.opacity(0.05))
                .stroke((recipe.canCook ? Color.green : Color.orange).opacity(0.3), lineWidth: 1)
        }
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
    
    private func loadFullRecipe() {
        fullRecipe = homeContentViewModel.getByID(recipe.id)
    }
    
    private func toggleFavorite() {
        guard var fullRecipe = fullRecipe else { return }
        
        do {
            let updatedRecipe = Recipe(
                id: fullRecipe.id,
                name: fullRecipe.name,
                ingredients: fullRecipe.ingredients,
                mealType: fullRecipe.mealType,
                isFavorite: !fullRecipe.isFavorite
            )
            
            try homeContentViewModel.update(updatedRecipe)
            homeContentViewModel.getAllRecipes()
            
            // Update local state
            self.fullRecipe = updatedRecipe
            
        } catch {
            // Handle error
            print("Error updating favorite status: \(error)")
        }
    }
    
    private func deleteRecipe() {
        guard let fullRecipe = fullRecipe else { return }
        
        do {
            try homeContentViewModel.delete(fullRecipe)
            homeContentViewModel.getAllRecipes()
            dismiss()
        } catch {
            print("Error deleting recipe: \(error)")
        }
    }
}

// MARK: - EditRecipeView

struct EditRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let originalRecipe: Recipe
    private let homeContentViewModel: HomeContentViewModel
    
    @State private var recipeName: String
    @State private var selectedMealType: MealType
    @State private var isFavorite: Bool
    @State private var ingredientText: String = ""
    @State private var ingredients: [String]
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    init(recipe: Recipe, viewModel: HomeContentViewModel) {
        self.originalRecipe = recipe
        self.homeContentViewModel = viewModel
        
        self._recipeName = State(initialValue: recipe.name)
        self._selectedMealType = State(initialValue: recipe.mealType)
        self._isFavorite = State(initialValue: recipe.isFavorite)
        self._ingredients = State(initialValue: recipe.ingredients.map { $0.ingredient.name }.sorted())
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
            .navigationTitle("Editar Receta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveRecipe()
                    }
                    .disabled(recipeName.isEmpty || ingredients.isEmpty)
                }
            }
            .alert("Información", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    @ViewBuilder
    private var recipeBasicInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Información Básica")
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Nombre de la receta")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Ej: Pasta Carbonara", text: $recipeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Tipo de comida")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Tipo de comida", selection: $selectedMealType) {
                    Text("Desayuno").tag(MealType.breakFast)
                    Text("Comida").tag(MealType.lunch)
                    Text("Cena").tag(MealType.dinner)
                    Text("Otros").tag(MealType.other)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Toggle("Marcar como favorito", isOn: $isFavorite)
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
            Text("Ingredientes")
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("Agregar ingrediente", text: $ingredientText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            addIngredient()
                        }
                    
                    Button("Agregar") {
                        addIngredient()
                    }
                    .disabled(ingredientText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                if ingredients.isEmpty {
                    Text("No hay ingredientes agregados")
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
            alertMessage = "Este ingrediente ya fue agregado"
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
            // Create domain ingredients
            let recipeIngredients = Set(ingredients.map { ingredientName in
                let ingredient = Ingredient(name: ingredientName)
                return RecipeIngredient(ingredient: ingredient, isRequired: true)
            })
            
            // Create the updated recipe
            let updatedRecipe = Recipe(
                id: originalRecipe.id, // Keep the same ID
                name: recipeName,
                ingredients: recipeIngredients,
                mealType: selectedMealType,
                isFavorite: isFavorite
            )
            
            // Update using the view model
            try homeContentViewModel.update(updatedRecipe)
            
            // Refresh the recipes list
            homeContentViewModel.getAllRecipes()
            
            dismiss()
            
        } catch {
            alertMessage = "Error al guardar la receta: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview("Recipe Detail") {
    let schema = Schema([
        Item.self,
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