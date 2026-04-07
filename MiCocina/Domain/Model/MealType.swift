//
//  MealType.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

/// An enumeration representing different meal types in the MiCocina application.
///
/// `MealType` is used to categorize recipes by the time of day they are typically
/// consumed. It conforms to `Comparable` to enable consistent sorting of recipes
/// in the user interface.
///
/// The enum provides:
/// - Type-safe meal categorization
/// - Comparable protocol for sorting
/// - Raw value conversion for storage
/// - Factory method for creating instances from string values
///
/// - Example:
/// ```swift
/// let mealType = MealType.lunch
/// let rawValue = mealType.rawValue    // "lunch"
/// let restored = MealType.rawValue("lunch")  // .lunch
/// ```
enum MealType: Comparable {
    /// Meals typically consumed in the morning
    case breakFast
    
    /// Meals typically consumed at midday
    case lunch
    
    /// Meals typically consumed in the evening
    case dinner
    
    /// Meals that don't fit into the above categories
    case other

    /// The raw string representation of the meal type.
    ///
    /// This property converts the enum case to its string representation,
    /// which is used for persistence and comparison operations.
    ///
    /// - Returns: A string representation of the meal type
    var rawValue: String {
        switch self {
        case .breakFast:
            return "breakFast"
        case .lunch:
            return "lunch"
        case .dinner:
            return "dinner"
        case .other:
            return "other"
        }
    }

    /// Compares two meal types lexicographically by their raw string values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side meal type
    ///   - rhs: The right-hand side meal type
    /// - Returns: `true` if the left meal type is less than the right meal type
    static func < (lhs: MealType, rhs: MealType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Creates a `MealType` from a raw string value.
    ///
    /// Converts a string representation (case-insensitive) to the corresponding
    /// meal type. If the string doesn't match any known meal type, returns `.other`.
    ///
    /// - Parameter rawValue: A string representation of a meal type (case-insensitive)
    /// - Returns: The corresponding `MealType` case, or `.other` if no match is found
    ///
    /// - Example:
    /// ```swift
    /// let type1 = MealType.rawValue("breakfast")  // .breakFast
    /// let type2 = MealType.rawValue("LUNCH")      // .lunch
    /// let type3 = MealType.rawValue("unknown")    // .other
    /// ```
    static func rawValue(_ rawValue: String) -> Self {
        switch rawValue.lowercased() {
        case "breakfast": .breakFast
        case "lunch": .lunch
        case "dinner": .dinner
        default: .other
        }
    }
}
