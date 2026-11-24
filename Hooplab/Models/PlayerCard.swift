import Foundation
import SwiftUI

public enum PlayerPosition: String, CaseIterable, Identifiable, Codable {
    case pg = "PG"
    case sg = "SG"
    case sf = "SF"
    case pf = "PF"
    case c = "C"

    public var id: String { rawValue }

    public func title(isEn: Bool) -> String {
        switch self {
        case .pg: return isEn ? "Point Guard (PG)" : "Разыгрывающий (PG)"
        case .sg: return isEn ? "Shooting Guard (SG)" : "Атакующий защитник (SG)"
        case .sf: return isEn ? "Small Forward (SF)" : "Лёгкий форвард (SF)"
        case .pf: return isEn ? "Power Forward (PF)" : "Тяжёлый форвард (PF)"
        case .c: return isEn ? "Center (C)" : "Центровой (C)"
        }
    }
}

public struct PlayerStatsSkills: Codable, Hashable {
    public var shooting: Int
    public var finishing: Int
    public var defense: Int
    public var playmaking: Int
    public var athleticism: Int
    public var ovr: Int
    public var tierTitle: String

    public static let initial = PlayerStatsSkills(
        shooting: 60,
        finishing: 60,
        defense: 60,
        playmaking: 60,
        athleticism: 60,
        ovr: 60,
        tierTitle: "Rookie"
    )
}

public struct PlayerBadge: Identifiable, Codable, Hashable {
    public let id: String
    public let emoji: String
    public let titleRu: String
    public let titleEn: String
    public let tier: String
    public let descriptionRu: String
    public let descriptionEn: String
    public var isUnlocked: Bool
    public var progressText: String

    public func localizedTitle(isEn: Bool) -> String {
        isEn ? titleEn : titleRu
    }

    public func localizedDesc(isEn: Bool) -> String {
        isEn ? descriptionEn : descriptionRu
    }
}
