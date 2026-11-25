import Foundation
import SwiftUI

public struct CategoryCardItem: Identifiable, Hashable {
    public var id: String { ruName }
    public let ruName: String
    public let enName: String
    public let imageName: String
    public let count: Int

    public func localizedName(isEn: Bool) -> String {
        isEn ? enName : ruName
    }

    public func localizedCountText(isEn: Bool) -> String {
        if isEn {
            return count == 1 ? "1 exercise" : "\(count) exercises"
        } else {
            let mod10 = count % 10
            let mod100 = count % 100
            if mod10 == 1 && mod100 != 11 {
                return "\(count) упражнение"
            } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
                return "\(count) упражнения"
            } else {
                return "\(count) упражнений"
            }
        }
    }
}

public enum ExerciseCategory: String, CaseIterable, Identifiable {
    case shots = "Броски"
    case technique = "Техника"
    case defense = "Защита"
    case offense = "Нападение"
    case fitness = "Физическая подготовка"
    case warmup = "Разминка и растяжка"
    case tactics = "Игровое мышление"
    case rules = "Правила"
    case games = "Игры и соревнования"

    public var id: String { rawValue }

    public func localized(isEn: Bool) -> String {
        if !isEn { return rawValue }
        switch self {
        case .shots: return "Shots"
        case .technique: return "Technique"
        case .defense: return "Defense"
        case .offense: return "Offense"
        case .fitness: return "Fitness"
        case .warmup: return "Warm-up & Stretching"
        case .tactics: return "Game IQ"
        case .rules: return "Rules"
        case .games: return "Games"
        }
    }

    public var assetName: String {
        switch self {
        case .shots: return "cat_shots"
        case .technique: return "cat_technique"
        case .defense: return "cat_defense"
        case .offense: return "cat_offense"
        case .fitness: return "cat_fitness"
        case .warmup: return "cat_warmup"
        case .tactics: return "cat_tactics"
        case .rules: return "cat_rules"
        case .games: return "cat_games"
        }
    }

    public static func buildItems(from exercises: [Exercise]) -> [CategoryCardItem] {
        let grouped = Dictionary(grouping: exercises, by: { $0.category.ru })
        return grouped.keys.sorted().map { ruCat in
            let list = grouped[ruCat] ?? []
            let enCat = list.first?.category.en ?? ruCat
            let asset = ExerciseMediaHelper.categoryAssetName(ruCat)
            return CategoryCardItem(ruName: ruCat, enName: enCat, imageName: asset, count: list.count)
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
