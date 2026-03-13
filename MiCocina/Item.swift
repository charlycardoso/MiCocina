//
//  Item.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 13/03/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
