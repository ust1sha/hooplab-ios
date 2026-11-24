import Foundation
import SwiftUI

public enum ExerciseCategory: String, CaseIterable, Identifiable {
    case all = "all"
    case shots = "shots"
    case dribbling = "dribbling"
    case defense = "defense"
    case technique = "technique"
    case physical = "physical"
    case tactics = "tactics"

    public var id: String { rawValue }

    public func localized(isEn: Bool) -> String {
        switch self {
        case .all: return isEn ? "All" : "Все"
        case .shots: return isEn ? "Shots" : "Броски"
        case .dribbling: return isEn ? "Dribbling" : "Дриблинг"
        case .defense: return isEn ? "Defense" : "Защита"
        case .technique: return isEn ? "Technique" : "Техника"
        case .physical: return isEn ? "Physical" : "Физика"
        case .tactics: return isEn ? "Tactics" : "Тактика"
        }
    }

    public var sfSymbol: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .shots: return "figure.basketball"
        case .dribbling: return "hand.point.up.braille.fill"
        case .defense: return "shield.fill"
        case .technique: return "flame.fill"
        case .physical: return "figure.run"
        case .tactics: return "map.fill"
        }
    }

    public func matches(categoryString: String) -> Bool {
        if self == .all { return true }
        let lower = categoryString.lowercased()
        switch self {
        case .shots: return lower.contains("брос") || lower.contains("shot")
        case .dribbling: return lower.contains("дрибл") || lower.contains("dribbl")
        case .defense: return lower.contains("защит") || lower.contains("defen")
        case .technique: return lower.contains("техник") || lower.contains("techniq")
        case .physical: return lower.contains("физич") || lower.contains("физик") || lower.contains("physic")
        case .tactics: return lower.contains("тактик") || lower.contains("tactic")
        case .all: return true
        }
    }
}

public enum ExerciseLevel: String, CaseIterable, Identifiable {
    case all = "all"
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"

    public var id: String { rawValue }

    public func localized(isEn: Bool) -> String {
        switch self {
        case .all: return isEn ? "All" : "Все"
        case .beginner: return isEn ? "Beginner" : "Начальный"
        case .intermediate: return isEn ? "Intermediate" : "Средний"
        case .advanced: return isEn ? "Advanced" : "Продвинутый"
        }
    }

    public func matches(levelString: String) -> Bool {
        if self == .all { return true }
        let lower = levelString.lowercased()
        switch self {
        case .beginner: return lower.contains("нач") || lower.contains("begin")
        case .intermediate: return lower.contains("сред") || lower.contains("intermed")
        case .advanced: return lower.contains("прод") || lower.contains("advanc")
        case .all: return true
        }
    }
}
