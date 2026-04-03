//
//  MealType.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 19/03/26.
//

enum MealType: Comparable {
    case breakFast
    case lunch
    case dinner
    case other

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

    static func < (lhs: MealType, rhs: MealType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    static func rawValue(_ rawValue: String) -> Self {
        switch rawValue.lowercased() {
        case "breakfast": .breakFast
        case "lunch": .lunch
        case "dinner": .dinner
        default: .other
        }
    }
}
