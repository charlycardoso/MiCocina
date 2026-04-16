//
//  RecipeSelectionRow.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/04/26.
//

import Foundation
import SwiftUI

/// A selectable row view for choosing recipes in the planner.
///
/// `RecipeSelectionRow` presents a recipe in a list with a selection indicator,
/// allowing users to build a collection of recipes to add to their meal plan.
/// The row displays recipe details and provides visual feedback for the selection state.
///
/// Visual elements include:
/// - Recipe name with optional favorite heart icon
/// - Cooking status (can cook vs. missing ingredients)
/// - Selection indicator (filled or empty circle)
///
/// The entire row is tappable, making it easy for users to select or deselect
/// recipes with a single tap.
///
/// - Example:
/// ```swift
/// RecipeSelectionRow(
///     recipe: recipeViewData,
///     isSelected: selectedIDs.contains(recipe.id),
///     onTap: { toggleSelection(recipe.id) }
/// )
/// ```
struct RecipeSelectionRow: View {
    /// The recipe to display
    let recipe: RecipeViewData
    
    /// Whether this recipe is currently selected
    let isSelected: Bool
    
    /// Closure called when the row is tapped
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recipe.name)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    if recipe.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
                if recipe.canCook {
                    Label(NSLocalizedString("planner.recipe.canCook", comment: "Can cook label"), systemImage: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.green)
                } else {
                    Label(
                        String(format: NSLocalizedString("planner.recipe.missingIngredientsLong", comment: "Missing ingredients label"), recipe.missingCount),
                        systemImage: "exclamationmark.circle"
                    )
                    .font(.caption2)
                    .foregroundStyle(.orange)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
            } else {
                Image(systemName: "circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .accessibilityIdentifier("addRecipes.selectionRow.\(recipe.id.uuidString)")
        .onTapGesture {
            onTap()
        }
    }
}
