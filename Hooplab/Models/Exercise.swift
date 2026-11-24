import Foundation
import SwiftUI

public struct LocalizedField: Codable, Hashable {
    public let ru: String
    public let en: String

    public init(ru: String, en: String) {
        self.ru = ru
        self.en = en
    }

    public func text(isEn: Bool = false) -> String {
        return isEn ? en : ru
    }
}

public struct ExerciseCatalogResponse: Codable {
    public let exercises: [Exercise]
}

public struct Exercise: Identifiable, Codable, Hashable {
    public let id: Int
    public let title: LocalizedField
    public let description: LocalizedField
    public let level: LocalizedField
    public let category: LocalizedField
    public let imageName: String
    public let steps: LocalizedField
    public let muscles: LocalizedField
    public let sets: LocalizedField
    public let rest: LocalizedField
    public let tips: LocalizedField
    public let mistakes: LocalizedField

    public func localizedTitle(isEn: Bool) -> String { title.text(isEn: isEn) }
    public func localizedDesc(isEn: Bool) -> String { description.text(isEn: isEn) }
    public func localizedLevel(isEn: Bool) -> String { level.text(isEn: isEn) }
    public func localizedCategory(isEn: Bool) -> String { category.text(isEn: isEn) }
    public func localizedMuscles(isEn: Bool) -> String { muscles.text(isEn: isEn) }
    public func localizedSets(isEn: Bool) -> String { sets.text(isEn: isEn) }
    public func localizedRest(isEn: Bool) -> String { rest.text(isEn: isEn) }
    public func localizedTips(isEn: Bool) -> String { tips.text(isEn: isEn) }
    public func localizedMistakes(isEn: Bool) -> String { mistakes.text(isEn: isEn) }

    public func stepsList(isEn: Bool) -> [String] {
        let raw = steps.text(isEn: isEn)
        return raw.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    public func mistakesList(isEn: Bool) -> [String] {
        let raw = mistakes.text(isEn: isEn)
        return raw.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    public var sfSymbol: String {
        let cat = category.en.lowercased()
        if cat.contains("shot") {
            return "figure.basketball"
        } else if cat.contains("dribbl") || cat.contains("technique") {
            return "hand.point.up.braille.fill"
        } else if cat.contains("defen") {
            return "shield.fill"
        } else if cat.contains("physic") {
            return "figure.run"
        } else if cat.contains("tactic") {
            return "map.fill"
        }
        return "basketball.fill"
    }

    public var categoryColor: Color {
        let cat = category.en.lowercased()
        if cat.contains("shot") {
            return Color(red: 1.0, green: 0.42, blue: 0.0) // Orange
        } else if cat.contains("technique") || cat.contains("dribbl") {
            return Color(red: 0.2, green: 0.6, blue: 1.0) // Blue
        } else if cat.contains("defen") {
            return Color(red: 0.2, green: 0.8, blue: 0.4) // Green
        } else if cat.contains("physic") {
            return Color(red: 0.9, green: 0.25, blue: 0.3) // Red/Crimson
        }
        return Color(red: 0.6, green: 0.35, blue: 0.9) // Purple
    }

    public var parsedRestSeconds: Int {
        // e.g. "45–60 сек" or "30 сек"
        let raw = rest.ru
        let numbers = raw.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
        if let first = numbers.first, let val = Int(first) {
            return val
        }
        return 45
    }

    public var parsedSetsCount: Int {
        // e.g. "3 подхода × 10 повторений"
        let raw = sets.ru
        let numbers = raw.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
        if let first = numbers.first, let val = Int(first) {
            return max(1, val)
        }
        return 3
    }
}
