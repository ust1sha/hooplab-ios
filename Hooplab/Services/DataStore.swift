import Foundation
import Combine
import SwiftUI

public class DataStore: ObservableObject {
    @Published public var exercises: [Exercise] = []
    @Published public var favoriteIds: Set<Int> = []
    @Published public var completedSessions: [WorkoutSession] = []
    @Published public var streakDays: Int = 1
    @Published public var isEnglish: Bool = false
    @Published public var playerName: String = "Baller"
    @Published public var playerPosition: PlayerPosition = .pg
    @Published public var quizHighScore: Int = 0
    @Published public var totalXP: Int = 150

    private let favoritesKey = "hooplab_favorites"
    private let sessionsKey = "hooplab_sessions"
    private let streakKey = "hooplab_streak"
    private let langKey = "hooplab_lang_en"
    private let xpKey = "hooplab_xp"
    private let quizScoreKey = "hooplab_quiz_high_score"
    private let positionKey = "hooplab_player_position"

    public init() {
        loadPersistedData()
        loadExercises()
    }

    public func loadExercises() {
        self.exercises = ExerciseCatalog.loadExercises()
    }

    public func isFavorite(id: Int) -> Bool {
        favoriteIds.contains(id)
    }

    public func toggleFavorite(id: Int) {
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
        } else {
            favoriteIds.insert(id)
        }
        saveFavorites()
    }

    public func recordWorkout(exercise: Exercise, setsCompleted: Int, durationSec: Int) {
        let session = WorkoutSession(
            exerciseId: exercise.id,
            exerciseTitle: exercise.localizedTitle(isEn: isEnglish),
            category: exercise.category.en,
            setsCompleted: setsCompleted,
            durationSec: durationSec
        )
        completedSessions.append(session)
        totalXP += setsCompleted * 25 + 50
        streakDays = max(1, streakDays)
        saveSessions()
    }

    public func recordQuizCompletion(score: Int) {
        if score > quizHighScore {
            quizHighScore = score
            UserDefaults.standard.set(quizHighScore, forKey: quizScoreKey)
        }
        totalXP += score * 20
        UserDefaults.standard.set(totalXP, forKey: xpKey)
    }

    public func calculateSkills() -> PlayerStatsSkills {
        var shooting = 60
        var finishing = 60
        var defense = 60
        var playmaking = 60
        var athleticism = 60

        for session in completedSessions {
            let cat = session.category.lowercased()
            let bonus = session.setsCompleted * 2
            if cat.contains("shot") {
                shooting += bonus
            } else if cat.contains("dribbl") || cat.contains("technique") {
                playmaking += bonus
            } else if cat.contains("defen") {
                defense += bonus
            } else if cat.contains("physic") {
                athleticism += bonus
            } else {
                finishing += bonus
            }
        }

        shooting = min(99, shooting)
        finishing = min(99, finishing)
        defense = min(99, defense)
        playmaking = min(99, playmaking)
        athleticism = min(99, athleticism)

        let avg = (shooting + finishing + defense + playmaking + athleticism) / 5
        let tier: String
        switch avg {
        case 90...99: tier = "Superstar"
        case 80...89: tier = "All-Star"
        case 70...79: tier = "Starter"
        default: tier = "Rookie"
        }

        return PlayerStatsSkills(
            shooting: shooting,
            finishing: finishing,
            defense: defense,
            playmaking: playmaking,
            athleticism: athleticism,
            ovr: avg,
            tierTitle: tier
        )
    }

    public var badges: [PlayerBadge] {
        let count = completedSessions.count
        return [
            PlayerBadge(
                id: "b1",
                emoji: "🏀",
                titleRu: "Первый бросок",
                titleEn: "First Shot",
                tier: "Bronze",
                descriptionRu: "Завершите свою первую тренировку",
                descriptionEn: "Complete your first workout",
                isUnlocked: count >= 1,
                progressText: "\(min(count, 1))/1"
            ),
            PlayerBadge(
                id: "b2",
                emoji: "🔥",
                titleRu: "В ударе",
                titleEn: "On Fire",
                tier: "Silver",
                descriptionRu: "Поддерживайте стрик тренировок 3 дня",
                descriptionEn: "Maintain a 3-day workout streak",
                isUnlocked: streakDays >= 3,
                progressText: "\(min(streakDays, 3))/3"
            ),
            PlayerBadge(
                id: "b3",
                emoji: "🎯",
                titleRu: "Снайпер",
                titleEn: "Sharp Shooter",
                tier: "Gold",
                descriptionRu: "Наберите 8+ очков в баскетбольном квизе",
                descriptionEn: "Score 8+ in basketball quiz",
                isUnlocked: quizHighScore >= 8,
                progressText: "\(min(quizHighScore, 8))/8"
            ),
            PlayerBadge(
                id: "b4",
                emoji: "👑",
                titleRu: "Легенда площадки",
                titleEn: "Court Legend",
                tier: "Hall of Fame",
                descriptionRu: "Завершите 10 тренировок",
                descriptionEn: "Complete 10 workouts",
                isUnlocked: count >= 10,
                progressText: "\(min(count, 10))/10"
            )
        ]
    }

    private func loadPersistedData() {
        if let favs = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] {
            self.favoriteIds = Set(favs)
        }
        self.streakDays = max(1, UserDefaults.standard.integer(forKey: streakKey))
        self.isEnglish = UserDefaults.standard.bool(forKey: langKey)
        let xp = UserDefaults.standard.integer(forKey: xpKey)
        self.totalXP = xp > 0 ? xp : 150
        self.quizHighScore = UserDefaults.standard.integer(forKey: quizScoreKey)

        if let posStr = UserDefaults.standard.string(forKey: positionKey),
           let pos = PlayerPosition(rawValue: posStr) {
            self.playerPosition = pos
        }

        if let data = UserDefaults.standard.data(forKey: sessionsKey) {
            if let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
                self.completedSessions = decoded
            }
        }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIds), forKey: favoritesKey)
    }

    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(completedSessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
        UserDefaults.standard.set(streakDays, forKey: streakKey)
        UserDefaults.standard.set(totalXP, forKey: xpKey)
    }

    public func setLanguage(isEn: Bool) {
        self.isEnglish = isEn
        UserDefaults.standard.set(isEn, forKey: langKey)
    }

    public func setPosition(_ pos: PlayerPosition) {
        self.playerPosition = pos
        UserDefaults.standard.set(pos.rawValue, forKey: positionKey)
    }
}
