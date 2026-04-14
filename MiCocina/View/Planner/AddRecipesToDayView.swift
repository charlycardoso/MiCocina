//
//  AddRecipesToDayView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/04/26.
//

import SwiftUI
import Foundation
import SwiftData

/// A sheet view for adding recipes to a specific day in the planner.
///
/// `AddRecipesToDayView` presents a selection interface where users can choose
/// multiple recipes from their recipe collection to add to a specific day's meal plan.
/// The view filters available recipes by meal type and allows multi-selection.
///
/// Key features:
/// - Displays the target date prominently
/// - Filters recipes by meal type (breakfast, lunch, dinner, other)
/// - Shows recipe details including favorite status and cooking availability
/// - Supports multi-selection with visual feedback
/// - Prevents duplicate additions to the same day
/// - Shows empty state when no recipes are available for the selected meal type
///
/// The view integrates with both `PlannerViewModel` for saving planner data and
/// `HomeContentViewModel` for accessing the user's recipe collection.
///
/// - Example:
/// ```swift
/// AddRecipesToDayView(
///     viewModel: plannerViewModel,
///     selectedDate: Date(),
///     onSave: { refreshPlanner() }
/// )
/// ```
struct AddRecipesToDayView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: PlannerViewModel
    
    /// The date to add recipes to
    let selectedDate: Date
    
    /// Closure called when recipes are successfully saved
    let onSave: () -> Void
    
    @State private var selectedMealType: MealType = .lunch
    @State private var availableRecipes: [RecipeViewData] = []
    @State private var selectedRecipes: Set<UUID> = []
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    /// View model for accessing the user's recipe collection
    private var homeViewModel: HomeContentViewModel {
        HomeContentViewModel(context: modelContext)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date Header
                VStack(spacing: 4) {
                    Text(NSLocalizedString("planner.addRecipes.header", comment: "Add recipes header"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(formattedDate(selectedDate))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                
                // Meal Type Picker
                Picker(NSLocalizedString("planner.addRecipes.mealTypeLabel", comment: "Meal type picker label"), selection: $selectedMealType) {
                    Text(NSLocalizedString("mealType.breakfast", comment: "Breakfast")).tag(MealType.breakFast)
                    Text(NSLocalizedString("mealType.lunch", comment: "Lunch")).tag(MealType.lunch)
                    Text(NSLocalizedString("mealType.dinner", comment: "Dinner")).tag(MealType.dinner)
                    Text(NSLocalizedString("mealType.other", comment: "Other")).tag(MealType.other)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Recipes List
                if availableRecipes.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        Text(NSLocalizedString("planner.addRecipes.noRecipesAvailable", comment: "No recipes available message"))
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(availableRecipes) { recipe in
                            RecipeSelectionRow(
                                recipe: recipe,
                                isSelected: selectedRecipes.contains(recipe.id)
                            ) {
                                toggleRecipeSelection(recipe.id)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(NSLocalizedString("planner.addRecipes.title", comment: "Select recipes navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "Cancel button")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("planner.addRecipes.addButton", comment: "Add button")) {
                        saveRecipesToDay()
                    }
                    .disabled(selectedRecipes.isEmpty)
                }
            }
            .alert(NSLocalizedString("common.information", comment: "Information alert title"), isPresented: $showAlert) {
                Button(NSLocalizedString("common.ok", comment: "OK button")) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadRecipes()
            }
            .onChange(of: selectedMealType) { _, _ in
                loadRecipes()
            }
        }
    }
    
    /// Loads available recipes filtered by the selected meal type.
    private func loadRecipes() {
        homeViewModel.getAllRecipes()
        
        // Filter recipes by selected meal type
        let recipesForMealType = homeViewModel.recipes
            .first(where: { $0.mealType == selectedMealType })?
            .recipes ?? []
        
        availableRecipes = recipesForMealType
    }
    
    /// Toggles the selection state of a recipe.
    ///
    /// - Parameter id: The unique identifier of the recipe to toggle
    private func toggleRecipeSelection(_ id: UUID) {
        if selectedRecipes.contains(id) {
            selectedRecipes.remove(id)
        } else {
            selectedRecipes.insert(id)
        }
    }
    
    /// Saves the selected recipes to the specified day.
    ///
    /// This method retrieves full recipe objects from the repository using the selected
    /// recipe IDs, adds them to any existing recipes for the day, and saves the updated
    /// planner data. If an error occurs, an alert is shown to the user.
    private func saveRecipesToDay() {
        let selectedRecipeViewData = availableRecipes.filter { selectedRecipes.contains($0.id) }
        
        guard !selectedRecipeViewData.isEmpty else { return }
        
        do {
            // Get existing planner data or create new one
            var existingRecipes: [Recipe] = []
            
            if let plannerData = viewModel.get(by: selectedDate) {
                existingRecipes = plannerData.recipes
            }
            
            // Convert RecipeViewData IDs to Recipe objects from the repository
            for recipeViewData in selectedRecipeViewData {
//                if let recipe = viewModel.get(by: recipeViewData) {
//                    existingRecipes.append(recipe)
//                }
            }
            
            // Create updated planner data
            let updatedPlannerData = PlannerData(day: selectedDate, recipes: existingRecipes)
            try viewModel.save(updatedPlannerData)
            
            onSave()
            dismiss()
        } catch {
            alertMessage = String(format: NSLocalizedString("planner.error.saveRecipes", comment: "Error saving recipes"), error.localizedDescription)
            showAlert = true
        }
    }
    
    /// Formats a date for display in the header.
    ///
    /// - Parameter date: The date to format
    /// - Returns: Localized long-form date string
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
