//
//  RecipeRowView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Foundation
import SwiftUI

/// A row view displaying a recipe with action buttons in the planner.
///
/// `RecipeRowView` presents recipe information in a compact card format with
/// interactive elements for managing the recipe within the planner. It shows
/// the recipe name, favorite status, and cooking availability.
///
/// The view provides two primary actions through visible buttons:
/// - **Move**: Relocate the recipe to a different day
/// - **Delete**: Remove the recipe from the current day's plan
///
/// Visual indicators include:
/// - ❤️ Heart icon for favorite recipes
/// - ✅ Green label if all ingredients are available
/// - ⚠️ Orange label showing count of missing ingredients
///
/// - Note: This view is designed to be used within a `NavigationLink` in the planner,
///   allowing users to tap the row to view full recipe details.
///
/// - Example:
/// ```swift
/// RecipeRowView(
///     recipe: recipeViewData,
///     onMove: { presentMoveSheet() },
///     onDelete: { deleteRecipe() }
/// )
/// ```
struct RecipeRowView: View {
    /// The recipe data to display
    let recipe: RecipeViewData
    
    /// Closure called when the user taps the move button
    let onMove: () -> Void
    
    /// Closure called when the user taps the delete button
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Recipe Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recipe.name)
                        .foregroundStyle(.accent)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    if recipe.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
                HStack(spacing: 8) {
                    if recipe.canCook {
                        Label(NSLocalizedString("planner.recipe.canCook", comment: "Recipe can be cooked label"), systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    } else {
                        Label(
                            String(format: NSLocalizedString("planner.recipe.missingIngredients", comment: "Missing ingredients count"), recipe.missingCount),
                            systemImage: "exclamationmark.circle"
                        )
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Chevron to indicate row is tappable for navigation
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .contextMenu {
            Button {
                onMove()
            } label: {
                Label(NSLocalizedString("planner.recipe.moveToAnotherDay", comment: "Move to another day action"), systemImage: "calendar.badge.clock")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(NSLocalizedString("planner.recipe.delete", comment: "Delete recipe action"), systemImage: "trash")
            }
        }
        .padding(.horizontal)
        .accessibilityIdentifier("planner.recipeRowView.\(recipe.id.uuidString)")
    }
}
