//
//  String+Extensions.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 18/03/26.
//

import Foundation

extension String {
    func normalize() -> Self {
        self.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}
