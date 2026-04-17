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
    /// The normalization process:
    /// 1. **Removes diacritical marks** (accents, tildes, etc.)
    /// 2. **Converts to lowercase** for case-insensitive matching
    /// 3. **Filters to keep only letters and spaces**
    /// 4. **Trims whitespace** from both ends
    /// 5. **Stems each word** to unify plural/singular forms
    ///    (e.g., "lemons"→"lemon", "cebollas"→"cebolla", "limones"→"limon")
    ///
    /// - Returns: A normalized version of the string
    func normalize() -> Self {
        // 1. Remove case + accents
        let folded = self
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)

        // 2. Keep ONLY A–Z letters and spaces
        let filtered = folded.unicodeScalars
            .filter { CharacterSet.letters.contains($0) || $0 == " " }
            .map { Character($0) }

        // 3. Lowercase and trim
        let base = String(filtered).lowercased().trimmingCharacters(in: .whitespaces)

        // 4. Stem each word to collapse plural/singular to a shared base form
        return base.split(separator: " ").map { String($0).stemmed() }.joined(separator: " ")
    }

    /// Strips common plural suffixes from a single already-normalized (lowercase, accent-free) word.
    /// Covers English and Spanish food ingredient patterns.
    private func stemmed() -> String {
        guard count > 3 else { return self }
        // "oes" → "o": tomatoes→tomato, potatoes→potato
        if hasSuffix("oes"), count > 4 { return String(dropLast(2)) }
        // "ies" → "y": berries→berry, cherries→cherry
        if hasSuffix("ies"), count > 4 { return String(dropLast(3)) + "y" }
        // "ones" → "on": limones→limon, melones→melon (Spanish plurals of "ón"-ending words)
        if hasSuffix("ones"), count > 6 { return String(dropLast(2)) }
        // Trailing "s": lemons→lemon, cebollas→cebolla, oranges→orange, tomates→tomate
        if hasSuffix("s") { return String(dropLast(1)) }
        return self
    }
}
