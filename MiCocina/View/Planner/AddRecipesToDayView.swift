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
    @State private var searchText: String = ""

    private var displayedRecipes: [RecipeViewData] {
        let sorted = availableRecipes.sorted { $0.canCook && !$1.canCook }
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
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
                
                // Meal Type Picker
                Picker(NSLocalizedString("planner.addRecipes.mealTypeLabel", comment: "Meal type picker label"), selection: $selectedMealType) {
                    Text(NSLocalizedString("mealType.breakfast", comment: "Breakfast")).tag(MealType.breakFast)
                    Text(NSLocalizedString("mealType.lunch", comment: "Lunch")).tag(MealType.lunch)
                    Text(NSLocalizedString("mealType.dinner", comment: "Dinner")).tag(MealType.dinner)
                    Text(NSLocalizedString("mealType.other", comment: "Other")).tag(MealType.other)
                }
                .pickerStyle(.segmented)
                .padding()
                .accessibilityIdentifier("addRecipes.mealTypePicker")
                
                // Recipes List
                if displayedRecipes.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: searchText.isEmpty ? "fork.knife.circle" : "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        Text(searchText.isEmpty
                             ? NSLocalizedString("planner.addRecipes.noRecipesAvailable", comment: "")
                             : NSLocalizedString("homeContent.noSearchResults", comment: ""))
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .accessibilityIdentifier("addRecipes.emptyState")
                } else {
                    List {
                        ForEach(displayedRecipes) { recipe in
                            RecipeSelectionRow(
                                recipe: recipe,
                                isSelected: selectedRecipes.contains(recipe.id)
                            ) {
                                toggleRecipeSelection(recipe.id)
                            }
                            .accessibilityIdentifier("addRecipes.recipeRow.\(recipe.id.uuidString)")
                        }
                    }
                    .listStyle(.plain)
                    .accessibilityIdentifier("addRecipes.recipesList")
                }
            }
            .navigationTitle(NSLocalizedString("planner.addRecipes.title", comment: "Select recipes navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: Text("homeContent.searchPrompt"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "Cancel button")) {
                        dismiss()
                    }
                    .accessibilityIdentifier("addRecipes.cancelButton")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("planner.addRecipes.addButton", comment: "Add button")) {
                        saveRecipesToDay()
                    }
                    .disabled(selectedRecipes.isEmpty)
                    .accessibilityIdentifier("addRecipes.addButton")
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
        availableRecipes = viewModel.getRecipes(by: selectedMealType)
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
    /// This method retrieves existing SDRecipe storage objects and updates the planner
    /// by directly working with SwiftData relationships. This avoids creating duplicate
    /// recipe entries in the database.
    private func saveRecipesToDay() {
        let selectedRecipeIDs = Array(selectedRecipes)
        
        guard !selectedRecipeIDs.isEmpty else { return }
        
        do {
            let calendar = Calendar.current
            let normalizedDay = calendar.startOfDay(for: selectedDate)
            
            // Fetch existing planner for this day
            let plannerDescriptor = FetchDescriptor<SDPlannerData>(
                predicate: #Predicate<SDPlannerData> { $0.day == normalizedDay }
            )
            
            let existingPlanner = try modelContext.fetch(plannerDescriptor).first
            
            // Fetch the SDRecipe objects for the selected recipe IDs
            let recipeDescriptor = FetchDescriptor<SDRecipe>(
                predicate: #Predicate<SDRecipe> { recipe in
                    selectedRecipeIDs.contains(recipe.id)
                }
            )
            
            let selectedSDRecipes = try modelContext.fetch(recipeDescriptor)
            
            // Update or create planner
            if let planner = existingPlanner {
                // Add new recipes, avoiding duplicates
                for sdRecipe in selectedSDRecipes {
                    if !planner.recipes.contains(where: { $0.id == sdRecipe.id }) {
                        planner.recipes.append(sdRecipe)
                    }
                }
            } else {
                // Create new planner with selected recipes
                let newPlanner = SDPlannerData(
                    day: normalizedDay,
                    recipes: selectedSDRecipes
                )
                modelContext.insert(newPlanner)
            }
            
            try modelContext.save()
            
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
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
