//
//  String+Extensions.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 18/03/26.
//

import Foundation

extension String {
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
