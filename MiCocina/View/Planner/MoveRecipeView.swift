//
//  MoveRecipeView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Foundation
import SwiftUI

/// A sheet view for moving a recipe to a different day in the planner.
///
/// `MoveRecipeView` provides an interface for users to select a new date for a planned
/// recipe. It displays the recipe being moved, the current date, and a graphical date
/// picker for choosing the destination date.
///
/// The view includes:
/// - Recipe name and current date display
/// - Graphical calendar picker for intuitive date selection
/// - Disabled state management (button is disabled until a date is selected)
/// - Cancellation option
///
/// After the user confirms the move, the view calls the provided closure with the
/// selected date, allowing the parent view to handle the actual move operation.
///
/// - Example:
/// ```swift
/// MoveRecipeView(
///     viewModel: plannerViewModel,
///     recipe: selectedRecipe,
///     currentDate: Date(),
///     onMove: { newDate in
///         moveRecipeToDate(newDate)
///     }
/// )
/// ```
struct MoveRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PlannerViewModel
    
    /// The recipe to be moved
    let recipe: RecipeViewData
    
    /// The current date of the recipe
    let currentDate: Date
    
    /// Closure called when the user confirms the move with the selected date
    let onMove: (Date) -> Void
    
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Recipe Info
                VStack(spacing: 8) {
                    Text(NSLocalizedString("planner.moveRecipe.title", comment: "Move recipe title"))
                        .font(.headline)
                    
                    Text(recipe.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(String(format: NSLocalizedString("planner.moveRecipe.from", comment: "From date label"), formattedDate(currentDate)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                
                Divider()
                
                // Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("planner.moveRecipe.selectNewDay", comment: "Select new day label"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    DatePicker(
                        NSLocalizedString("planner.moveRecipe.newDate", comment: "New date picker label"),
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Move Button
                Button {
                    onMove(selectedDate)
                } label: {
                    Text(NSLocalizedString("planner.moveRecipe.moveButton", comment: "Move recipe button"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("planner.moveRecipe.navigationTitle", comment: "Move recipe navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "Cancel button")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// Formats a date for display.
    ///
    /// - Parameter date: The date to format
    /// - Returns: Localized medium-length date string
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
