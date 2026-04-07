//
//  Item.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Foundation
import SwiftData

/// A simple data model for storing timestamped items in the database.
///
/// `Item` is a SwiftData model currently used as a placeholder in the MiCocina application.
/// This model was part of the initial Xcode template and can be removed once all
/// functionality has been migrated to the recipe domain models (`Recipe`, `Ingredient`, etc.).
///
/// - Important: This model is considered legacy and should be replaced with proper
///   domain models for production use. It serves no purpose in the recipe discovery feature.
///
/// - Note: To remove this model from the app:
///   1. Remove this file
///   2. Remove `Item.self` from the Schema in `MiCocinaApp.swift`
///   3. Update `ContentView` to use proper recipe UI components
@Model
final class Item {
    /// The timestamp associated with this item
    var timestamp: Date
    
    /// Initializes a new item with a timestamp.
    ///
    /// - Parameter timestamp: The timestamp for the item
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
