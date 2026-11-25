import Foundation
import SwiftUI

public enum PlayerPosition: String, CaseIterable, Identifiable, Codable {
    case pg = "PG"
    case sg = "SG"
    case sf = "SF"
    case pf = "PF"
    case c = "C"

    public var id: String { rawValue }
    public var code: String { rawValue }

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
        tierTitle: "ROOKIE 🏀"
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

public struct LeaderboardUser: Identifiable, Codable, Hashable {
    public var id: String { uid }
    public let uid: String
    public let name: String
    public let position: String
    public let jerseyNumber: Int
    public let ovr: Int
    public let quizScore: Int
    public var rank: Int
    public let streak: Int
    public var isCurrentUser: Bool

    public var tierTitle: String {
        switch ovr {
        case 93...99: return "HALL OF FAME 👑"
        case 86...92: return "ALL-STAR ⭐"
        case 79...85: return "STARTER ⚡"
        case 72...78: return "RISING STAR 🔥"
        default: return "ROOKIE 🏀"
        }
    }
}

public enum StatsCalculator {
    public static func totalSessions(_ sessions: [WorkoutSession]) -> Int {
        sessions.count
    }

    public static func totalDurationSec(_ sessions: [WorkoutSession]) -> Int {
        sessions.reduce(0) { $0 + $1.durationSec }
    }

    public static func currentStreak(_ sessions: [WorkoutSession]) -> Int {
        if sessions.isEmpty { return 0 }
        let cal = Calendar.current
        let days = Set(sessions.map { cal.startOfDay(for: $0.timestamp) })

        var streak = 0
        var anchor = cal.startOfDay(for: Date())
        if !days.contains(anchor) {
            anchor = cal.date(byAdding: .day, value: -1, to: anchor) ?? anchor
        }
        while days.contains(anchor) {
            streak += 1
            anchor = cal.date(byAdding: .day, value: -1, to: anchor) ?? Date.distantPast
        }
        return streak
    }

    public static func longestStreak(_ sessions: [WorkoutSession]) -> Int {
        if sessions.isEmpty { return 0 }
        let cal = Calendar.current
        let sorted = Set(sessions.map { cal.startOfDay(for: $0.timestamp) }).sorted()
        guard !sorted.isEmpty else { return 0 }
        var best = 1
        var run = 1
        for i in 1..<sorted.count {
            let diff = cal.dateComponents([.day], from: sorted[i - 1], to: sorted[i]).day ?? 0
            run = (diff == 1) ? run + 1 : 1
            if run > best { best = run }
        }
        return best
    }
}

public enum PlayerCardCalculator {
    private static func scaleAttribute(base: Int, points: Double) -> Int {
        let gain: Double
        if points <= 6.0 {
            gain = points * 2.5
        } else if points <= 16.0 {
            gain = 15.0 + (points - 6.0) * 0.9
        } else if points <= 32.0 {
            gain = 24.0 + (points - 16.0) * 0.45
        } else {
            gain = 31.2 + (points - 32.0) * 0.22
        }
        return min(99, max(60, base + Int(gain)))
    }

    public static func calculateSkillsAndOvr(sessions: [WorkoutSession], quizScore: Int) -> PlayerStatsSkills {
        let shots = sessions.filter {
            $0.category.localizedCaseInsensitiveContains("брос") || $0.category.localizedCaseInsensitiveContains("shot")
        }
        let technique = sessions.filter {
            $0.category.localizedCaseInsensitiveContains("техн") ||
            $0.category.localizedCaseInsensitiveContains("дрибл") ||
            $0.category.localizedCaseInsensitiveContains("drib") ||
            $0.category.localizedCaseInsensitiveContains("напад")
        }
        let defense = sessions.filter {
            $0.category.localizedCaseInsensitiveContains("защит") || $0.category.localizedCaseInsensitiveContains("def")
        }
        let iq = sessions.filter {
            $0.category.localizedCaseInsensitiveContains("мышл") ||
            $0.category.localizedCaseInsensitiveContains("iq") ||
            $0.category.localizedCaseInsensitiveContains("прав")
        }
        let fitness = sessions.filter {
            $0.category.localizedCaseInsensitiveContains("физич") ||
            $0.category.localizedCaseInsensitiveContains("размин") ||
            $0.category.localizedCaseInsensitiveContains("fit")
        }

        let shotsMin = Double(shots.reduce(0) { $0 + $1.durationSec }) / 60.0
        let techMin = Double(technique.reduce(0) { $0 + $1.durationSec }) / 60.0
        let defMin = Double(defense.reduce(0) { $0 + $1.durationSec }) / 60.0
        let totalMin = Double(StatsCalculator.totalDurationSec(sessions)) / 60.0

        let shtPts = Double(shots.count) * 2.0 + (shotsMin / 10.0)
        let dnkPts = Double(technique.count) * 2.0 + (techMin / 10.0)
        let defPts = Double(defense.count) * 2.0 + (defMin / 10.0)
        let plyPts = Double(iq.count) * 2.0 + (Double(quizScore) * 1.5)
        let athPts = Double(fitness.count) * 2.0 + (totalMin / 15.0)

        let sht = scaleAttribute(base: 60, points: shtPts)
        let dnk = scaleAttribute(base: 60, points: dnkPts)
        let def = scaleAttribute(base: 60, points: defPts)
        let ply = scaleAttribute(base: 60, points: plyPts)
        let ath = scaleAttribute(base: 60, points: athPts)

        let streak = StatsCalculator.currentStreak(sessions)
        let streakBonus = streak >= 14 ? 3 : (streak >= 7 ? 2 : (streak >= 3 ? 1 : 0))

        let baseOvr = (sht + dnk + def + ply + ath) / 5
        let finalOvr = min(99, max(60, baseOvr + streakBonus))

        let tier: String
        switch finalOvr {
        case 93...99: tier = "HALL OF FAME 👑"
        case 86...92: tier = "ALL-STAR ⭐"
        case 79...85: tier = "STARTER ⚡"
        case 72...78: tier = "RISING STAR 🔥"
        default: tier = "ROOKIE 🏀"
        }

        return PlayerStatsSkills(
            shooting: sht,
            finishing: dnk,
            defense: def,
            playmaking: ply,
            athleticism: ath,
            ovr: finalOvr,
            tierTitle: tier
        )
    }

    public static func evaluateBadges(
        sessions: [WorkoutSession],
        quizScore: Int,
        ovr: Int,
        hasCourtCheckin: Bool
    ) -> [PlayerBadge] {
        let streak = StatsCalculator.currentStreak(sessions)
        let shotsCount = sessions.filter {
            $0.category.localizedCaseInsensitiveContains("брос") || $0.category.localizedCaseInsensitiveContains("shot")
        }.count
        let techniqueCount = sessions.filter {
            $0.category.localizedCaseInsensitiveContains("техн") ||
            $0.category.localizedCaseInsensitiveContains("дрибл") ||
            $0.category.localizedCaseInsensitiveContains("drib")
        }.count
        let defenseCount = sessions.filter {
            $0.category.localizedCaseInsensitiveContains("защит") || $0.category.localizedCaseInsensitiveContains("def")
        }.count
        let totalSessions = sessions.count
        let totalMinutes = StatsCalculator.totalDurationSec(sessions) / 60

        let cal = Calendar.current
        let hasNightSession = sessions.contains {
            let h = cal.component(.hour, from: $0.timestamp)
            return h >= 21 || h < 4
        }
        let hasMorningSession = sessions.contains {
            let h = cal.component(.hour, from: $0.timestamp)
            return (5...9).contains(h)
        }

        var categoriesSet = Set<String>()
        for s in sessions {
            let c = s.category.lowercased()
            if c.contains("брос") || c.contains("shot") { categoriesSet.insert("shot") }
            else if c.contains("техн") || c.contains("дрибл") || c.contains("drib") { categoriesSet.insert("dribble") }
            else if c.contains("защит") || c.contains("def") { categoriesSet.insert("defense") }
            else if c.contains("мышл") || c.contains("iq") || c.contains("прав") { categoriesSet.insert("iq") }
            else if c.contains("физич") || c.contains("размин") || c.contains("fit") { categoriesSet.insert("fitness") }
        }
        let distinctCategories = categoriesSet.count

        return [
            PlayerBadge(id: "sniper", emoji: "🎯", titleRu: "Снайпер", titleEn: "Dead-Eye Sniper", tier: "ЗОЛОТО",
                        descriptionRu: "Выполните 5+ тренировок на точность броска", descriptionEn: "Complete 5+ shooting workouts",
                        isUnlocked: shotsCount >= 5, progressText: "\(shotsCount)/5"),
            PlayerBadge(id: "lockdown", emoji: "🔒", titleRu: "Замок на дуге", titleEn: "Lockdown Defender", tier: "СЕРЕБРО",
                        descriptionRu: "Проведите 5+ тренировок по защите", descriptionEn: "Complete 5+ defensive workouts",
                        isUnlocked: defenseCount >= 5, progressText: "\(defenseCount)/5"),
            PlayerBadge(id: "dribble_master", emoji: "⚡", titleRu: "Мастер дриблинга", titleEn: "Kyrie Handles", tier: "ЗОЛОТО",
                        descriptionRu: "Завершите 5+ тренировок на ведение мяча", descriptionEn: "Complete 5+ ball-handling workouts",
                        isUnlocked: techniqueCount >= 5, progressText: "\(techniqueCount)/5"),
            PlayerBadge(id: "night_owl", emoji: "🌙", titleRu: "Ночной снайпер", titleEn: "Late Night Grinder", tier: "БРОНЗА",
                        descriptionRu: "Завершите тренировку поздно вечером после 21:00", descriptionEn: "Complete a workout session after 9:00 PM",
                        isUnlocked: hasNightSession, progressText: hasNightSession ? "1/1" : "0/1"),
            PlayerBadge(id: "early_bird", emoji: "🌅", titleRu: "Утренняя разминка", titleEn: "Early Bird", tier: "БРОНЗА",
                        descriptionRu: "Завершите тренировку утром до 09:00", descriptionEn: "Complete a morning workout before 9:00 AM",
                        isUnlocked: hasMorningSession, progressText: hasMorningSession ? "1/1" : "0/1"),
            PlayerBadge(id: "on_fire", emoji: "🔥", titleRu: "В огне (On Fire)", titleEn: "On Fire Streak", tier: "СЕРЕБРО",
                        descriptionRu: "Поддерживайте серию тренировок 3 дня подряд", descriptionEn: "Keep a 3-day workout streak",
                        isUnlocked: streak >= 3, progressText: "\(streak)/3 дн."),
            PlayerBadge(id: "iron_streak_7", emoji: "⛓️", titleRu: "Неделя в огне", titleEn: "Iron Week Streak", tier: "ЗОЛОТО",
                        descriptionRu: "Поддерживайте серию тренировок 7 дней без пропусков", descriptionEn: "Keep an uninterrupted 7-day workout streak",
                        isUnlocked: streak >= 7, progressText: "\(streak)/7 дн."),
            PlayerBadge(id: "master_of_all", emoji: "🏅", titleRu: "Универсал", titleEn: "Master of All", tier: "ЗОЛОТО",
                        descriptionRu: "Завершите тренировки во всех 5 направлениях", descriptionEn: "Complete workouts across all 5 basketball categories",
                        isUnlocked: distinctCategories >= 5, progressText: "\(distinctCategories)/5"),
            PlayerBadge(id: "hoop_iq", emoji: "🧠", titleRu: "Баскетбольный IQ", titleEn: "Court Vision IQ", tier: "СЕРЕБРО",
                        descriptionRu: "Ответьте правильно на 8+ вопросов в квизе", descriptionEn: "Answer 8+ questions correctly in the quiz",
                        isUnlocked: quizScore >= 8, progressText: "\(quizScore)/8"),
            PlayerBadge(id: "court_explorer", emoji: "📍", titleRu: "Король площадок", titleEn: "Streetball Pioneer", tier: "БРОНЗА",
                        descriptionRu: "Отметьтесь хотя бы на одной уличной площадке", descriptionEn: "Check in on any streetball court",
                        isUnlocked: hasCourtCheckin, progressText: hasCourtCheckin ? "1/1" : "0/1"),
            PlayerBadge(id: "centurion", emoji: "⏱", titleRu: "Клуб 100 минут", titleEn: "Centurion 100m", tier: "ЗОЛОТО",
                        descriptionRu: "Проведите 100+ минут чистого времени на тренировках", descriptionEn: "Accumulate 100+ total workout minutes",
                        isUnlocked: totalMinutes >= 100, progressText: "\(totalMinutes)/100 мин"),
            PlayerBadge(id: "iron_lungs", emoji: "⚡", titleRu: "Железный атлет", titleEn: "Relentless Motor", tier: "СЕРЕБРО",
                        descriptionRu: "Завершите 10 тренировочных сессий суммарно", descriptionEn: "Complete 10 total workout sessions",
                        isUnlocked: totalSessions >= 10, progressText: "\(totalSessions)/10"),
            PlayerBadge(id: "goat", emoji: "👑", titleRu: "Легенда корта", titleEn: "Hall of Fame Legend", tier: "HOF",
                        descriptionRu: "Прокачайте общий рейтинг игрока до 90+ OVR", descriptionEn: "Upgrade your overall player rating to 90+ OVR",
                        isUnlocked: ovr >= 90, progressText: "\(ovr)/90 OVR")
        ]
    }
}
