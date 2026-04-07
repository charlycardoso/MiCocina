//
//  String+Extensions.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 18/03/26.
//

import Foundation

extension String {
    /// Normalizes a string for consistent ingredient matching.
    ///
    /// Normalization is essential for recipe matching because it ensures that
    /// variations of the same ingredient (different cases, accents, etc.) are
    /// treated as the same item. For example, "tomato", "Tomato", and "tomate"
    /// are all normalized to "tomato".
    ///
    /// The normalization process:
    /// 1. **Removes diacritical marks** (accents, tildes, etc.)
    /// 2. **Converts to lowercase** for case-insensitive matching
    /// 3. **Filters to keep only letters and spaces**
    /// 4. **Trims whitespace** from both ends
    ///
    /// This approach handles international ingredient names gracefully while
    /// maintaining readability.
    ///
    /// - Returns: A normalized version of the string
    ///
    /// - Example:
    /// ```swift
    /// "Chéddar".normalize()           // "cheddar"
    /// "TOMATO".normalize()            // "tomato"
    /// "Mozzarella di Bufala".normalize() // "mozzarella di bufala"
    /// "Épinards".normalize()          // "epinards"
    /// ```
    ///
    /// - Note: Removes all non-letter characters except spaces
    func normalize() -> Self {
        // 1. Remove case + accents
        let folded = self
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)

        // 2. Keep ONLY A–Z letters and spaces
        let filtered = folded.unicodeScalars
            .filter { CharacterSet.letters.contains($0) || $0 == " " }
            .map { Character($0) }

        // 3. Join, lowercase, and trim leading/trailing whitespace
        return String(filtered).lowercased().trimmingCharacters(in: .whitespaces)
    }
}
