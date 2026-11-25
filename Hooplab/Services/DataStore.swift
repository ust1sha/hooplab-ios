import Foundation
import Combine
import SwiftUI
import UIKit
import UserNotifications
import CryptoKit

// MARK: - App Routing & Streak Models
public enum AppRoute {
    case splash
    case onboarding
    case auth
    case main
}

public enum MainTab: Int, CaseIterable, Identifiable {
    case home = 0
    case exercises = 1
    case favorites = 2
    case profile = 3

    public var id: Int { rawValue }
}

public struct DayStreakInfo: Identifiable {
    public var id: Int { dayIndex }
    public let dayIndex: Int // 0 = Mon .. 6 = Sun
    public let shortLabel: String
    public let isCompleted: Bool
    public let isToday: Bool
}

public struct MainStreakState {
    public let streakDays: Int
    public let weeklyMinutes: Int
    public let weeklyGoalMinutes: Int
    public let days: [DayStreakInfo]

    public static let empty = MainStreakState(
        streakDays: 0,
        weeklyMinutes: 0,
        weeklyGoalMinutes: 120,
        days: []
    )
}

public struct StatsUiState {
    public let totalSessions: Int
    public let totalDurationSec: Int
    public let streakDays: Int
    public let weekly: [(label: String, count: Int)]
    public let topExercises: [(name: String, count: Int)]
    public let bestStreak: Int
    public let maxSessionsPerDay: Int
    public let longestSessionSec: Int

    public static let empty = StatsUiState(
        totalSessions: 0,
        totalDurationSec: 0,
        streakDays: 0,
        weekly: [],
        topExercises: [],
        bestStreak: 0,
        maxSessionsPerDay: 0,
        longestSessionSec: 0
    )
}

private struct LocalUserAccount: Codable {
    var uid: String
    var name: String
    var email: String
    var passwordHash: String
}

public enum DeleteAccountOutcome {
    case success
    case requiresRecentLogin
    case failure(String)
}

// MARK: - Central Store & Firebase Cloud Sync
@MainActor
public class DataStore: ObservableObject {
    // Navigation & Toast
    @Published public var route: AppRoute = .splash
    @Published public var selectedTab: MainTab = .home
    @Published public var toastMessage: String? = nil

    // Catalog & Data
    @Published public var exercises: [Exercise] = []
    @Published public var favoriteIds: Set<Int> = []
    @Published public var completedSessions: [WorkoutSession] = []
    @Published public var courts: [StreetballCourt] = CourtsData.sampleCourts
    @Published public var checkedInCourtId: String? = nil
    @Published public var leaderboardUsers: [LeaderboardUser] = []

    // User Auth & Profile
    @Published public var userId: String? = nil
    @Published public var userEmail: String? = nil
    @Published public var idToken: String? = nil
    @Published public var playerName: String = "Атлет"
    @Published public var avatarImage: UIImage? = nil

    // Player Card & Gamification
    @Published public var playerPosition: PlayerPosition = .pg
    @Published public var playerJersey: Int = 7
    @Published public var quizScore: Int = 0
    @Published public var answeredQuestionIds: Set<Int> = []
    @Published public var hasCourtCheckin: Bool = false

    // Preferences
    @Published public var isFirstLaunch: Bool = true
    @Published public var isDarkTheme: Bool = false
    @Published public var notificationsEnabled: Bool = true
    @Published public var isEnglish: Bool = false

    // Computed / Cached UI
    @Published public var playerSkills: PlayerStatsSkills = .initial
    @Published public var playerBadges: [PlayerBadge] = []
    @Published public var streakState: MainStreakState = .empty
    @Published public var recommendedExercise: Exercise? = nil

    public let totalQuizQuestionsCount = BasketballQuizData.allQuestions.count
    public let programs = WorkoutProgramsCatalog.programs

    private let firebaseApiKey = "AIzaSyDXg0yHb_N_lfsS1OHZVM2BWpgxY7lquds"
    private let firebaseProjectId = "hoopslab-b4eab"

    private enum Keys {
        static let firstLaunch = "hooplab_is_first_launch"
        static let darkTheme = "hooplab_dark_theme"
        static let notifications = "hooplab_notifications"
        static let language = "hooplab_language_code"
        static let userId = "hooplab_user_id"
        static let userEmail = "hooplab_user_email"
        static let idToken = "hooplab_firebase_id_token"
        static let playerName = "hooplab_player_name"
        static let playerPosition = "hooplab_player_position"
        static let playerJersey = "hooplab_player_jersey"
        static let quizScore = "hooplab_quiz_score"
        static let answeredIds = "hooplab_quiz_answered_ids"
        static let hasCourtCheckin = "hooplab_has_court_checkin"
        static let favoritesPrefix = "hooplab_favorites_"
        static let sessions = "hooplab_sessions_v2"
        static let localAccounts = "hooplab_local_accounts"
        static let customCourts = "hooplab_custom_courts"
    }

    public init() {
        loadPreferences()
        loadExercises()
        loadAvatar()
        refreshDerivedState()
    }

    // MARK: - Toast Helper
    public func showToast(_ msg: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            toastMessage = msg
        }
        Task {
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            await MainActor.run {
                if self.toastMessage == msg {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.toastMessage = nil
                    }
                }
            }
        }
    }

    // MARK: - Launch & Navigation
    public func completeSplashRouting() {
        if isFirstLaunch {
            route = .onboarding
        } else if (userId != nil && !(userId?.isEmpty ?? true)) || (userEmail != nil && !(userEmail?.isEmpty ?? true)) {
            route = .main
            Task { await syncOnForeground() }
        } else {
            route = .auth
        }
    }

    public func finishOnboarding() {
        isFirstLaunch = false
        UserDefaults.standard.set(false, forKey: Keys.firstLaunch)
        route = .auth
    }

    // MARK: - Preferences & Settings
    private func loadPreferences() {
        let ud = UserDefaults.standard
        if ud.object(forKey: Keys.firstLaunch) == nil {
            self.isFirstLaunch = true
        } else {
            self.isFirstLaunch = ud.bool(forKey: Keys.firstLaunch)
        }

        self.isDarkTheme = ud.bool(forKey: Keys.darkTheme)
        self.notificationsEnabled = ud.object(forKey: Keys.notifications) == nil ? true : ud.bool(forKey: Keys.notifications)

        if let savedLang = ud.string(forKey: Keys.language) {
            self.isEnglish = (savedLang == "en")
        } else {
            let sys = Locale.preferredLanguages.first?.lowercased() ?? "ru"
            self.isEnglish = !sys.hasPrefix("ru")
        }

        self.userId = ud.string(forKey: Keys.userId)
        self.userEmail = ud.string(forKey: Keys.userEmail)
        self.idToken = ud.string(forKey: Keys.idToken)
        self.playerName = ud.string(forKey: Keys.playerName) ?? (isEnglish ? "Guest" : "Гость")
        if let posStr = ud.string(forKey: Keys.playerPosition), let pos = PlayerPosition(rawValue: posStr) {
            self.playerPosition = pos
        }
        let j = ud.integer(forKey: Keys.playerJersey)
        self.playerJersey = ud.object(forKey: Keys.playerJersey) == nil ? 7 : j
        self.quizScore = ud.integer(forKey: Keys.quizScore)
        self.hasCourtCheckin = ud.bool(forKey: Keys.hasCourtCheckin)

        if let ansRaw = ud.string(forKey: Keys.answeredIds), !ansRaw.isEmpty {
            self.answeredQuestionIds = Set(ansRaw.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) })
        }

        loadUserScopedFavorites()

        if let data = ud.data(forKey: Keys.sessions),
           let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            self.completedSessions = decoded
        }

        if let customData = ud.data(forKey: Keys.customCourts),
           let custom = try? JSONDecoder().decode([StreetballCourt].self, from: customData) {
            let existingIds = Set(CourtsData.sampleCourts.map { $0.id })
            self.courts = CourtsData.sampleCourts + custom.filter { !existingIds.contains($0.id) }
        }
    }

    public func setLanguage(isEn: Bool) {
        self.isEnglish = isEn
        UserDefaults.standard.set(isEn ? "en" : "ru", forKey: Keys.language)
        refreshDerivedState()
    }

    public func setDarkTheme(_ dark: Bool) {
        self.isDarkTheme = dark
        UserDefaults.standard.set(dark, forKey: Keys.darkTheme)
    }

    public func setNotificationsEnabled(_ enabled: Bool) {
        self.notificationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: Keys.notifications)
        scheduleDailyReminder(enabled: enabled)
        showToast(enabled ? (isEnglish ? "Notifications enabled" : "Уведомления включены") : (isEnglish ? "Notifications disabled" : "Уведомления выключены"))
    }

    private func scheduleDailyReminder(enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["hooplab_daily_streak"])
        guard enabled else { return }

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = self.isEnglish ? "🏀 Your streak is on the line!" : "🏀 Твой стрик под угрозой!"
            let streak = self.streakState.streakDays
            if streak > 0 {
                content.body = self.isEnglish
                    ? "You're on a \(streak)-day streak! Complete a quick workout today to keep it burning."
                    : "У тебя серия из \(streak) дн. подряд! Сделай короткую тренировку сегодня, чтобы не сгорел прогресс."
            } else {
                content.body = self.isEnglish
                    ? "Time to hit the court! Complete a 10-minute warmup or shooting session today."
                    : "Время выйти на корт! Пройди 10-минутную разминку или броски сегодня."
            }
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = 19
            dateComponents.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let req = UNNotificationRequest(identifier: "hooplab_daily_streak", content: content, trigger: trigger)
            center.add(req)
        }
    }

    // MARK: - Catalog & Derived State
    public func loadExercises() {
        self.exercises = ExerciseCatalog.loadExercises()
        if !exercises.isEmpty {
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            let pickIndex = (dayOfYear - 1) % exercises.count
            self.recommendedExercise = exercises[pickIndex]
        }
    }

    public func findExerciseForPill(_ type: String) -> Exercise? {
        switch type {
        case "warmup":
            return exercises.first { $0.id == 36 || $0.titleRu.localizedCaseInsensitiveContains("размин") }
                ?? exercises.first { $0.categoryRu.localizedCaseInsensitiveContains("размин") }
        case "freethrows":
            return exercises.first { $0.id == 5 || $0.titleRu.localizedCaseInsensitiveContains("штрафн") }
                ?? exercises.first { $0.categoryRu.localizedCaseInsensitiveContains("брос") }
        case "dribbling":
            return exercises.first { $0.id == 2 || $0.titleRu.localizedCaseInsensitiveContains("дриблинг") }
                ?? exercises.first { $0.categoryRu.localizedCaseInsensitiveContains("техник") }
        case "defense":
            return exercises.first { $0.id == 3 || $0.titleRu.localizedCaseInsensitiveContains("защит") }
                ?? exercises.first { $0.categoryRu.localizedCaseInsensitiveContains("защит") }
        case "cooldown":
            return exercises.first { $0.id == 37 || $0.titleRu.localizedCaseInsensitiveContains("растяжк") }
                ?? exercises.first { $0.categoryRu.localizedCaseInsensitiveContains("размин") }
        default:
            return exercises.first
        }
    }

    public func refreshDerivedState() {
        let skills = PlayerCardCalculator.calculateSkillsAndOvr(sessions: completedSessions, quizScore: quizScore)
        self.playerSkills = skills
        self.playerBadges = PlayerCardCalculator.evaluateBadges(
            sessions: completedSessions,
            quizScore: quizScore,
            ovr: skills.ovr,
            hasCourtCheckin: hasCourtCheckin
        )
        self.streakState = computeStreakState()
    }

    private func computeStreakState() -> MainStreakState {
        let totalStreak = StatsCalculator.currentStreak(completedSessions)

        var cal = Calendar.current
        cal.firstDayOfWeek = 2 // Monday
        let now = Date()
        let weekday = cal.component(.weekday, from: now) // 1=Sun, 2=Mon..7=Sat
        let todayIdx = (weekday == 1) ? 6 : (weekday - 2)

        let todayStart = cal.startOfDay(for: now)
        guard let mondayStart = cal.date(byAdding: .day, value: -todayIdx, to: todayStart) else {
            return .empty
        }

        let thisWeekSessions = completedSessions.filter { $0.timestamp >= mondayStart }
        let weeklyMinutes = thisWeekSessions.reduce(0) { $0 + $1.durationSec } / 60

        let labelsRu = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        let labelsEn = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

        let days: [DayStreakInfo] = (0...6).map { idx in
            let dayStart = cal.date(byAdding: .day, value: idx, to: mondayStart) ?? mondayStart
            let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            let hasSession = completedSessions.contains { $0.timestamp >= dayStart && $0.timestamp < dayEnd }
            return DayStreakInfo(
                dayIndex: idx,
                shortLabel: isEnglish ? labelsEn[idx] : labelsRu[idx],
                isCompleted: hasSession,
                isToday: idx == todayIdx
            )
        }

        return MainStreakState(
            streakDays: totalStreak,
            weeklyMinutes: weeklyMinutes,
            weeklyGoalMinutes: 120,
            days: days
        )
    }

    public func computeStatsUiState() -> StatsUiState {
        if completedSessions.isEmpty { return .empty }
        let cal = Calendar.current
        let totalDuration = StatsCalculator.totalDurationSec(completedSessions)
        let streak = StatsCalculator.currentStreak(completedSessions)
        let bestStreak = StatsCalculator.longestStreak(completedSessions)

        let df = DateFormatter()
        df.locale = Locale(identifier: isEnglish ? "en_US" : "ru_RU")
        df.dateFormat = "EE"

        let today = cal.startOfDay(for: Date())
        let weekly: [(String, Int)] = (0...6).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: today) ?? today
            let nextDay = cal.date(byAdding: .day, value: 1, to: day) ?? day
            let count = completedSessions.filter { $0.timestamp >= day && $0.timestamp < nextDay }.count
            let label = df.string(from: day).prefix(2).capitalized
            return (String(label), count)
        }

        var titleCounts: [String: Int] = [:]
        var dayCounts: [Date: Int] = [:]
        for s in completedSessions {
            titleCounts[s.exerciseTitle, default: 0] += 1
            dayCounts[cal.startOfDay(for: s.timestamp), default: 0] += 1
        }
        let top = titleCounts.sorted { $0.value > $1.value }.prefix(3).map { ($0.key, $0.value) }
        let maxPerDay = dayCounts.values.max() ?? 0
        let longest = completedSessions.map { $0.durationSec }.max() ?? 0

        return StatsUiState(
            totalSessions: completedSessions.count,
            totalDurationSec: totalDuration,
            streakDays: streak,
            weekly: weekly,
            topExercises: top,
            bestStreak: bestStreak,
            maxSessionsPerDay: maxPerDay,
            longestSessionSec: longest
        )
    }

    // MARK: - Favorites (user-scoped like FavoritesDao)
    private var favStorageKey: String {
        let key = userEmail ?? userId ?? "guest"
        return Keys.favoritesPrefix + key
    }

    private func loadUserScopedFavorites() {
        if let arr = UserDefaults.standard.array(forKey: favStorageKey) as? [Int] {
            self.favoriteIds = Set(arr)
        } else {
            self.favoriteIds = []
        }
    }

    public func isFavorite(id: Int) -> Bool {
        favoriteIds.contains(id)
    }

    @discardableResult
    public func toggleFavorite(id: Int) -> Bool {
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
            UserDefaults.standard.set(Array(favoriteIds), forKey: favStorageKey)
            return false
        } else {
            favoriteIds.insert(id)
            UserDefaults.standard.set(Array(favoriteIds), forKey: favStorageKey)
            showToast(isEnglish ? "Added to favorites" : "Добавлено в избранное")
            return true
        }
    }

    // MARK: - Workouts & Sessions
    public func saveWorkoutSession(exercise: Exercise, durationSec: Int) {
        let session = WorkoutSession(
            exerciseId: exercise.id,
            exerciseTitle: exercise.localizedTitle(isEn: isEnglish),
            category: exercise.category.ru,
            setsCompleted: exercise.parsedSetsCount,
            durationSec: max(1, durationSec),
            timestamp: Date()
        )
        completedSessions.append(session)
        if let encoded = try? JSONEncoder().encode(completedSessions) {
            UserDefaults.standard.set(encoded, forKey: Keys.sessions)
        }
        refreshDerivedState()
        showToast(isEnglish ? "Workout complete! 💪" : "Тренировка завершена! 💪")

        if let uid = userId ?? userEmail {
            Task {
                await syncSessionToFirestore(uid: uid, session: session)
                await syncPlayerCardToFirestore(uid: uid)
            }
        }
    }

    // MARK: - Player Card Updates
    public func setPlayerPosition(_ pos: PlayerPosition) {
        self.playerPosition = pos
        UserDefaults.standard.set(pos.rawValue, forKey: Keys.playerPosition)
        if let uid = userId ?? userEmail {
            Task { await syncPlayerCardToFirestore(uid: uid) }
        }
    }

    public func setJerseyNumber(_ number: Int) {
        let clamped = min(99, max(0, number))
        self.playerJersey = clamped
        UserDefaults.standard.set(clamped, forKey: Keys.playerJersey)
        if let uid = userId ?? userEmail {
            Task { await syncPlayerCardToFirestore(uid: uid) }
        }
    }

    public func nextUnansweredQuestion() -> QuizQuestion? {
        BasketballQuizData.allQuestions.first { !answeredQuestionIds.contains($0.id) }
    }

    public func submitQuizAnswer(questionId: Int, isCorrect: Bool) {
        answeredQuestionIds.insert(questionId)
        UserDefaults.standard.set(answeredQuestionIds.map(String.init).joined(separator: ","), forKey: Keys.answeredIds)
        if isCorrect {
            quizScore += 1
            UserDefaults.standard.set(quizScore, forKey: Keys.quizScore)
            showToast(isEnglish ? "Correct! +XP added to your rating" : "Правильно! +XP к рейтингу")
        } else {
            showToast(isEnglish ? "Incorrect. Read the explanation!" : "Неверно. Изучите пояснение!")
        }
        refreshDerivedState()
        if let uid = userId ?? userEmail {
            Task { await syncPlayerCardToFirestore(uid: uid) }
        }
    }

    // MARK: - Avatar Persistence
    private var avatarFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("hooplab_avatar.jpg")
    }

    private func loadAvatar() {
        if let data = try? Data(contentsOf: avatarFileURL), let img = UIImage(data: data) {
            self.avatarImage = img
        }
    }

    public func saveAvatar(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            showToast(isEnglish ? "Could not save photo" : "Не удалось сохранить фото")
            return
        }
        do {
            try data.write(to: avatarFileURL)
            self.avatarImage = image
            showToast(isEnglish ? "Photo updated" : "Фото обновлено")
        } catch {
            showToast(isEnglish ? "Could not save photo" : "Не удалось сохранить фото")
        }
    }

    // MARK: - Password Hashing (Local Offline Fallback)
    private func hashPassword(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func loadLocalAccounts() -> [LocalUserAccount] {
        guard let data = UserDefaults.standard.data(forKey: Keys.localAccounts),
              let list = try? JSONDecoder().decode([LocalUserAccount].self, from: data) else {
            return []
        }
        return list
    }

    private func saveLocalAccounts(_ list: [LocalUserAccount]) {
        if let encoded = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(encoded, forKey: Keys.localAccounts)
        }
    }

    // MARK: - Firebase Auth REST API + Offline Cache Fallback
    public func login(email: String, password: String) async -> Result<Void, Error> {
        let urlStr = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(firebaseApiKey)"
        if let url = URL(string: urlStr) {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.timeoutInterval = 8
            req.httpBody = try? JSONSerialization.data(withJSONObject: [
                "email": email,
                "password": password,
                "returnSecureToken": true
            ])

            do {
                let (data, response) = try await URLSession.shared.data(for: req)
                if let http = response as? HTTPURLResponse,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if http.statusCode == 200,
                       let uid = json["localId"] as? String,
                       let token = json["idToken"] as? String {
                        let displayName = json["displayName"] as? String
                        finalizeAuthSession(uid: uid, email: email, name: displayName, token: token)
                        // Update local cache
                        var local = loadLocalAccounts()
                        local.removeAll { $0.email.lowercased() == email.lowercased() }
                        local.append(LocalUserAccount(uid: uid, name: displayName ?? email.components(separatedBy: "@").first ?? "Игрок", email: email, passwordHash: hashPassword(password)))
                        saveLocalAccounts(local)
                        await syncOnForeground()
                        return .success(())
                    } else if let errObj = json["error"] as? [String: Any],
                              let msg = errObj["message"] as? String {
                        // Firebase returned explicit auth error (INVALID_LOGIN_CREDENTIALS / EMAIL_NOT_FOUND / INVALID_PASSWORD)
                        let local = loadLocalAccounts()
                        if let cached = local.first(where: { $0.email.lowercased() == email.lowercased() && $0.passwordHash == hashPassword(password) }) {
                            finalizeAuthSession(uid: cached.uid, email: cached.email, name: cached.name, token: nil)
                            return .success(())
                        }
                        return .failure(NSError(domain: "Auth", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: mapFirebaseAuthError(msg)]))
                    }
                }
            } catch {
                // Network error -> fallback to local Room cache
                let local = loadLocalAccounts()
                if let cached = local.first(where: { $0.email.lowercased() == email.lowercased() && $0.passwordHash == hashPassword(password) }) {
                    finalizeAuthSession(uid: cached.uid, email: cached.email, name: cached.name, token: nil)
                    return .success(())
                }
                return .failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: isEnglish ? "Network error or invalid credentials" : "Ошибка сети или неверный email/пароль"]))
            }
        }
        return .failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: isEnglish ? "Invalid email or password" : "Неверный email или пароль"]))
    }

    public func register(name: String, email: String, password: String) async -> Result<Void, Error> {
        let urlStr = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=\(firebaseApiKey)"
        if let url = URL(string: urlStr) {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.timeoutInterval = 8
            req.httpBody = try? JSONSerialization.data(withJSONObject: [
                "email": email,
                "password": password,
                "returnSecureToken": true
            ])

            do {
                let (data, response) = try await URLSession.shared.data(for: req)
                if let http = response as? HTTPURLResponse,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if http.statusCode == 200,
                       let uid = json["localId"] as? String,
                       let token = json["idToken"] as? String {
                        // Update displayName in Firebase Auth
                        await updateFirebaseDisplayName(idToken: token, name: name)
                        finalizeAuthSession(uid: uid, email: email, name: name, token: token)
                        var local = loadLocalAccounts()
                        local.removeAll { $0.email.lowercased() == email.lowercased() }
                        local.append(LocalUserAccount(uid: uid, name: name, email: email, passwordHash: hashPassword(password)))
                        saveLocalAccounts(local)
                        await saveProfileToFirestore(uid: uid, name: name, email: email)
                        return .success(())
                    } else if let errObj = json["error"] as? [String: Any],
                              let msg = errObj["message"] as? String {
                        return .failure(NSError(domain: "Auth", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: mapFirebaseAuthError(msg)]))
                    }
                }
            } catch {
                // Offline fallback
                var local = loadLocalAccounts()
                if local.contains(where: { $0.email.lowercased() == email.lowercased() }) {
                    return .failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: isEnglish ? "User already exists" : "Пользователь уже существует"]))
                }
                let uid = "local_\(UUID().uuidString.prefix(8))"
                local.append(LocalUserAccount(uid: uid, name: name, email: email, passwordHash: hashPassword(password)))
                saveLocalAccounts(local)
                finalizeAuthSession(uid: uid, email: email, name: name, token: nil)
                return .success(())
            }
        }
        return .failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: isEnglish ? "Registration failed" : "Ошибка регистрации"]))
    }

    public func sendPasswordReset(email: String) async -> Result<Void, Error> {
        let urlStr = "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=\(firebaseApiKey)"
        guard let url = URL(string: urlStr) else {
            return .failure(NSError(domain: "Auth", code: -1, userInfo: nil))
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: [
            "requestType": "PASSWORD_RESET",
            "email": email
        ])
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                return .success(())
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let err = (json["error"] as? [String: Any])?["message"] as? String {
                return .failure(NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: mapFirebaseAuthError(err)]))
            }
        } catch {
            return .failure(error)
        }
        return .failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: isEnglish ? "Failed to send reset link" : "Не удалось отправить письмо"]))
    }

    public func updateUserName(_ newName: String) {
        self.playerName = newName
        UserDefaults.standard.set(newName, forKey: Keys.playerName)
        if let email = userEmail {
            var local = loadLocalAccounts()
            if let idx = local.firstIndex(where: { $0.email.lowercased() == email.lowercased() }) {
                local[idx].name = newName
                saveLocalAccounts(local)
            }
        }
        showToast(isEnglish ? "Name updated" : "Имя обновлено")
        Task {
            if let token = idToken {
                await updateFirebaseDisplayName(idToken: token, name: newName)
            }
            if let uid = userId ?? userEmail {
                await saveProfileToFirestore(uid: uid, name: newName, email: userEmail ?? "")
            }
        }
    }

    public func changePassword(currentPassword: String, newPassword: String) async -> Bool {
        if let email = userEmail, let token = idToken {
            // Re-verify current password first
            let check = await login(email: email, password: currentPassword)
            if case .failure = check { return false }

            let urlStr = "https://identitytoolkit.googleapis.com/v1/accounts:update?key=\(firebaseApiKey)"
            if let url = URL(string: urlStr) {
                var req = URLRequest(url: url)
                req.httpMethod = "POST"
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpBody = try? JSONSerialization.data(withJSONObject: [
                    "idToken": self.idToken ?? token,
                    "password": newPassword,
                    "returnSecureToken": true
                ])
                if let (data, resp) = try? await URLSession.shared.data(for: req),
                   let http = resp as? HTTPURLResponse, http.statusCode == 200,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let newToken = json["idToken"] as? String {
                    self.idToken = newToken
                    UserDefaults.standard.set(newToken, forKey: Keys.idToken)
                    var local = loadLocalAccounts()
                    if let idx = local.firstIndex(where: { $0.email.lowercased() == email.lowercased() }) {
                        local[idx].passwordHash = hashPassword(newPassword)
                        saveLocalAccounts(local)
                    }
                    return true
                }
            }
        }
        // Offline local fallback
        if let email = userEmail {
            var local = loadLocalAccounts()
            if let idx = local.firstIndex(where: { $0.email.lowercased() == email.lowercased() }),
               local[idx].passwordHash == hashPassword(currentPassword) {
                local[idx].passwordHash = hashPassword(newPassword)
                saveLocalAccounts(local)
                return true
            }
        }
        return false
    }

    public func logout() {
        self.userId = nil
        self.userEmail = nil
        self.idToken = nil
        UserDefaults.standard.removeObject(forKey: Keys.userId)
        UserDefaults.standard.removeObject(forKey: Keys.userEmail)
        UserDefaults.standard.removeObject(forKey: Keys.idToken)
        showToast(isEnglish ? "You have been logged out" : "Вы вышли из аккаунта")
        route = .auth
        selectedTab = .home
    }

    public func deleteAccount(password: String? = nil) async -> DeleteAccountOutcome {
        if let email = userEmail, let pw = password, !pw.isEmpty {
            let reauth = await login(email: email, password: pw)
            if case .failure(let err) = reauth {
                return .failure(err.localizedDescription)
            }
        }

        if let token = idToken {
            let urlStr = "https://identitytoolkit.googleapis.com/v1/accounts:delete?key=\(firebaseApiKey)"
            if let url = URL(string: urlStr) {
                var req = URLRequest(url: url)
                req.httpMethod = "POST"
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpBody = try? JSONSerialization.data(withJSONObject: ["idToken": token])
                if let (data, resp) = try? await URLSession.shared.data(for: req),
                   let http = resp as? HTTPURLResponse, http.statusCode != 200,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let msg = (json["error"] as? [String: Any])?["message"] as? String {
                    if msg == "CREDENTIAL_TOO_OLD_LOGIN_AGAIN" {
                        return .requiresRecentLogin
                    }
                }
            }
        }

        if let email = userEmail {
            var local = loadLocalAccounts()
            local.removeAll { $0.email.lowercased() == email.lowercased() }
            saveLocalAccounts(local)
        }
        clearAllUserData()
        showToast(isEnglish ? "Account deleted" : "Аккаунт удалён")
        route = .auth
        selectedTab = .home
        return .success
    }

    private func clearAllUserData() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: favStorageKey)
        [
            Keys.userId, Keys.userEmail, Keys.idToken, Keys.playerName,
            Keys.playerPosition, Keys.playerJersey, Keys.quizScore,
            Keys.answeredIds, Keys.hasCourtCheckin, Keys.sessions
        ].forEach { ud.removeObject(forKey: $0) }
        try? FileManager.default.removeItem(at: avatarFileURL)

        userId = nil
        userEmail = nil
        idToken = nil
        playerName = isEnglish ? "Guest" : "Гость"
        avatarImage = nil
        playerPosition = .pg
        playerJersey = 7
        quizScore = 0
        answeredQuestionIds = []
        hasCourtCheckin = false
        favoriteIds = []
        completedSessions = []
        refreshDerivedState()
    }

    private func finalizeAuthSession(uid: String, email: String, name: String?, token: String?) {
        self.userId = uid
        self.userEmail = email
        self.idToken = token
        let ud = UserDefaults.standard
        ud.set(uid, forKey: Keys.userId)
        ud.set(email, forKey: Keys.userEmail)
        if let t = token { ud.set(t, forKey: Keys.idToken) }

        if let n = name, !n.isEmpty {
            self.playerName = n
            ud.set(n, forKey: Keys.playerName)
        } else if playerName == "Гость" || playerName == "Guest" {
            let fallback = email.components(separatedBy: "@").first ?? "Игрок"
            self.playerName = fallback
            ud.set(fallback, forKey: Keys.playerName)
        }

        loadUserScopedFavorites()
        refreshDerivedState()
    }

    private func mapFirebaseAuthError(_ code: String) -> String {
        switch code {
        case "EMAIL_EXISTS": return isEnglish ? "Email is already registered" : "Этот email уже зарегистрирован"
        case "INVALID_LOGIN_CREDENTIALS", "INVALID_PASSWORD", "EMAIL_NOT_FOUND":
            return isEnglish ? "Invalid email or password" : "Неверный email или пароль"
        case "WEAK_PASSWORD":
            return isEnglish ? "Password must be at least 6 characters" : "Пароль должен быть не менее 6 символов"
        case "INVALID_EMAIL":
            return isEnglish ? "Enter a valid email" : "Введите корректный email"
        default:
            return code
        }
    }

    // MARK: - Cloud Firestore REST Sync
    private func updateFirebaseDisplayName(idToken: String, name: String) async {
        let urlStr = "https://identitytoolkit.googleapis.com/v1/accounts:update?key=\(firebaseApiKey)"
        guard let url = URL(string: urlStr) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: [
            "idToken": idToken,
            "displayName": name,
            "returnSecureToken": false
        ])
        _ = try? await URLSession.shared.data(for: req)
    }

    private func syncOnForeground() async {
        guard let uid = userId ?? userEmail else { return }
        if let cloudName = await fetchProfileNameFromFirestore(uid: uid), cloudName != playerName {
            self.playerName = cloudName
            UserDefaults.standard.set(cloudName, forKey: Keys.playerName)
        }
        await syncPlayerCardToFirestore(uid: uid)
    }

    private func firestoreBaseURL() -> String {
        "https://firestore.googleapis.com/v1/projects/\(firebaseProjectId)/databases/(default)/documents"
    }

    private func saveProfileToFirestore(uid: String, name: String, email: String) async {
        let urlStr = "\(firestoreBaseURL())/users/\(uid)?updateMask.fieldPaths=name&updateMask.fieldPaths=email"
        guard let url = URL(string: urlStr) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let t = idToken { req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
        var fields: [String: Any] = ["name": ["stringValue": name]]
        if !email.isEmpty { fields["email"] = ["stringValue": email] }
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["fields": fields])
        _ = try? await URLSession.shared.data(for: req)
    }

    private func syncPlayerCardToFirestore(uid: String) async {
        let urlStr = "\(firestoreBaseURL())/users/\(uid)?updateMask.fieldPaths=name&updateMask.fieldPaths=position&updateMask.fieldPaths=jerseyNumber&updateMask.fieldPaths=ovr&updateMask.fieldPaths=quizScore&updateMask.fieldPaths=streak"
        guard let url = URL(string: urlStr) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let t = idToken { req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
        let fields: [String: Any] = [
            "name": ["stringValue": playerName],
            "position": ["stringValue": playerPosition.code],
            "jerseyNumber": ["integerValue": "\(playerJersey)"],
            "ovr": ["integerValue": "\(playerSkills.ovr)"],
            "quizScore": ["integerValue": "\(quizScore)"],
            "streak": ["integerValue": "\(streakState.streakDays)"]
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["fields": fields])
        _ = try? await URLSession.shared.data(for: req)
    }

    private func syncSessionToFirestore(uid: String, session: WorkoutSession) async {
        let urlStr = "\(firestoreBaseURL())/users/\(uid)/sessions"
        guard let url = URL(string: urlStr) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let t = idToken { req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
        let tsMs = Int64(session.timestamp.timeIntervalSince1970 * 1000)
        let fields: [String: Any] = [
            "exerciseId": ["integerValue": "\(session.exerciseId)"],
            "exerciseTitle": ["stringValue": session.exerciseTitle],
            "category": ["stringValue": session.category],
            "sets": ["stringValue": "\(session.setsCompleted)"],
            "durationSec": ["integerValue": "\(session.durationSec)"],
            "timestamp": ["integerValue": "\(tsMs)"]
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["fields": fields])
        _ = try? await URLSession.shared.data(for: req)
    }

    private func fetchProfileNameFromFirestore(uid: String) async -> String? {
        let urlStr = "\(firestoreBaseURL())/users/\(uid)"
        guard let url = URL(string: urlStr) else { return nil }
        var req = URLRequest(url: url)
        req.timeoutInterval = 4
        if let t = idToken { req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
        guard let (data, resp) = try? await URLSession.shared.data(for: req),
              let http = resp as? HTTPURLResponse, http.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let fields = json["fields"] as? [String: Any],
              let nameObj = fields["name"] as? [String: Any],
              let name = nameObj["stringValue"] as? String, !name.isEmpty else {
            return nil
        }
        return name
    }

    // MARK: - Leaderboard Fetch (Firestore + Live Current User)
    public func loadLeaderboard() async {
        let currentUid = userId ?? userEmail ?? "current_user"
        var list: [LeaderboardUser] = []

        if let url = URL(string: "\(firestoreBaseURL())/users?pageSize=50") {
            var req = URLRequest(url: url)
            req.timeoutInterval = 5
            if let t = idToken { req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
            if let (data, resp) = try? await URLSession.shared.data(for: req),
               let http = resp as? HTTPURLResponse, http.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let docs = json["documents"] as? [[String: Any]] {
                for doc in docs {
                    guard let docName = doc["name"] as? String,
                          let uid = docName.components(separatedBy: "/").last,
                          let fields = doc["fields"] as? [String: Any] else { continue }
                    let name = (fields["name"] as? [String: Any])?["stringValue"] as? String ?? "Атлет"
                    let pos = (fields["position"] as? [String: Any])?["stringValue"] as? String ?? "PG"
                    let jersey = Int((fields["jerseyNumber"] as? [String: Any])?["integerValue"] as? String ?? "7") ?? 7
                    let ovr = Int((fields["ovr"] as? [String: Any])?["integerValue"] as? String ?? "60") ?? 60
                    let quiz = Int((fields["quizScore"] as? [String: Any])?["integerValue"] as? String ?? "0") ?? 0
                    let streak = Int((fields["streak"] as? [String: Any])?["integerValue"] as? String ?? "0") ?? 0

                    list.append(LeaderboardUser(
                        uid: uid,
                        name: name,
                        position: pos,
                        jerseyNumber: jersey,
                        ovr: ovr,
                        quizScore: quiz,
                        rank: 0,
                        streak: streak,
                        isCurrentUser: (uid == currentUid)
                    ))
                }
            }
        }

        let currentModel = LeaderboardUser(
            uid: currentUid,
            name: playerName.isEmpty ? (isEnglish ? "You" : "Вы") : playerName,
            position: playerPosition.code,
            jerseyNumber: playerJersey,
            ovr: playerSkills.ovr,
            quizScore: quizScore,
            rank: 0,
            streak: streakState.streakDays,
            isCurrentUser: true
        )

        if let idx = list.firstIndex(where: { $0.uid == currentUid }) {
            list[idx] = currentModel
        } else {
            list.append(currentModel)
        }

        let sorted = list.sorted {
            if $0.ovr != $1.ovr { return $0.ovr > $1.ovr }
            if $0.quizScore != $1.quizScore { return $0.quizScore > $1.quizScore }
            return $0.streak > $1.streak
        }.prefix(50)

        self.leaderboardUsers = sorted.enumerated().map { idx, u in
            var copy = u
            copy.rank = idx + 1
            copy.isCurrentUser = (u.uid == currentUid)
            return copy
        }
    }

    // MARK: - Streetball Courts (Static + Firestore + Check-in)
    public func refreshCourts() async {
        let currentUid = userId ?? userEmail
        var map = Dictionary(uniqueKeysWithValues: CourtsData.sampleCourts.map { ($0.id, $0) })

        if let customData = UserDefaults.standard.data(forKey: Keys.customCourts),
           let custom = try? JSONDecoder().decode([StreetballCourt].self, from: customData) {
            for c in custom { map[c.id] = c }
        }

        if let url = URL(string: "\(firestoreBaseURL())/courts?pageSize=100") {
            var req = URLRequest(url: url)
            req.timeoutInterval = 4
            if let t = idToken { req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
            if let (data, resp) = try? await URLSession.shared.data(for: req),
               let http = resp as? HTTPURLResponse, http.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let docs = json["documents"] as? [[String: Any]] {
                for doc in docs {
                    guard let docName = doc["name"] as? String,
                          let id = docName.components(separatedBy: "/").last,
                          let fields = doc["fields"] as? [String: Any],
                          let name = (fields["name"] as? [String: Any])?["stringValue"] as? String else { continue }
                    let addr = (fields["address"] as? [String: Any])?["stringValue"] as? String ?? ""
                    let surfRu = (fields["surfaceTypeRu"] as? [String: Any])?["stringValue"] as? String ?? "Резиновая крошка"
                    let surfEn = (fields["surfaceTypeEn"] as? [String: Any])?["stringValue"] as? String ?? "Rubber Cushion"
                    let rims = Int((fields["rimsCount"] as? [String: Any])?["integerValue"] as? String ?? "2") ?? 2
                    let light = (fields["hasLighting"] as? [String: Any])?["booleanValue"] as? Bool ?? true
                    let lat = (fields["latitude"] as? [String: Any])?["doubleValue"] as? Double ?? 0.0
                    let lng = (fields["longitude"] as? [String: Any])?["doubleValue"] as? Double ?? 0.0
                    let city = (fields["city"] as? [String: Any])?["stringValue"] as? String ?? "Город"
                    let arrValues = ((fields["activePlayers"] as? [String: Any])?["arrayValue"] as? [String: Any])?["values"] as? [[String: Any]] ?? []
                    let players = arrValues.compactMap { $0["stringValue"] as? String }
                    let checkedIn = (currentUid != nil && players.contains(currentUid!)) || (id == checkedInCourtId)

                    let baseCount = map[id]?.activePlayersCount ?? 0
                    map[id] = StreetballCourt(
                        id: id,
                        name: name,
                        address: addr,
                        surfaceTypeRu: surfRu,
                        surfaceTypeEn: surfEn,
                        rimsCount: rims,
                        hasLighting: light,
                        latitude: lat,
                        longitude: lng,
                        activePlayersCount: max(baseCount, players.count),
                        isUserCheckedIn: checkedIn,
                        city: city
                    )
                }
            }
        }

        self.courts = CourtsData.sampleCourts.map { sample in
            var c = map[sample.id] ?? sample
            c.isUserCheckedIn = (c.id == checkedInCourtId) || c.isUserCheckedIn
            return c
        } + map.values.filter { c in !CourtsData.sampleCourts.contains(where: { $0.id == c.id }) }
    }

    public func toggleCourtCheckIn(_ court: StreetballCourt) {
        if checkedInCourtId == court.id {
            checkedInCourtId = nil
            if let idx = courts.firstIndex(where: { $0.id == court.id }) {
                courts[idx].isUserCheckedIn = false
                courts[idx].activePlayersCount = max(0, courts[idx].activePlayersCount - 1)
            }
        } else {
            if let prev = checkedInCourtId, let prevIdx = courts.firstIndex(where: { $0.id == prev }) {
                courts[prevIdx].isUserCheckedIn = false
                courts[prevIdx].activePlayersCount = max(0, courts[prevIdx].activePlayersCount - 1)
            }
            checkedInCourtId = court.id
            hasCourtCheckin = true
            UserDefaults.standard.set(true, forKey: Keys.hasCourtCheckin)
            if let idx = courts.firstIndex(where: { $0.id == court.id }) {
                courts[idx].isUserCheckedIn = true
                courts[idx].activePlayersCount += 1
            }
            refreshDerivedState()
        }
    }

    public func addCustomCourt(name: String, city: String, address: String, surface: String, rims: Int, hasLighting: Bool, lat: Double?, lng: Double?) async {
        let newCourt = StreetballCourt(
            id: "dyn_\(Int(Date().timeIntervalSince1970 * 1000))",
            name: name,
            address: address,
            surfaceTypeRu: surface,
            surfaceTypeEn: surface,
            rimsCount: rims,
            hasLighting: hasLighting,
            latitude: lat ?? 55.7558,
            longitude: lng ?? 37.6173,
            activePlayersCount: 1,
            isUserCheckedIn: false,
            city: city.isEmpty ? "Мой город" : city
        )
        courts.insert(newCourt, at: 0)

        var savedCustom: [StreetballCourt] = []
        if let customData = UserDefaults.standard.data(forKey: Keys.customCourts),
           let decoded = try? JSONDecoder().decode([StreetballCourt].self, from: customData) {
            savedCustom = decoded
        }
        savedCustom.insert(newCourt, at: 0)
        if let encoded = try? JSONEncoder().encode(savedCustom) {
            UserDefaults.standard.set(encoded, forKey: Keys.customCourts)
        }

        // Best-effort Firestore push
        if let url = URL(string: "\(firestoreBaseURL())/courts") {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let t = idToken { req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
            let fields: [String: Any] = [
                "name": ["stringValue": newCourt.name],
                "address": ["stringValue": newCourt.address],
                "surfaceTypeRu": ["stringValue": newCourt.surfaceTypeRu],
                "surfaceTypeEn": ["stringValue": newCourt.surfaceTypeEn],
                "rimsCount": ["integerValue": "\(newCourt.rimsCount)"],
                "hasLighting": ["booleanValue": newCourt.hasLighting],
                "latitude": ["doubleValue": newCourt.latitude],
                "longitude": ["doubleValue": newCourt.longitude],
                "city": ["stringValue": newCourt.city],
                "createdAt": ["integerValue": "\(Int64(Date().timeIntervalSince1970 * 1000))"]
            ]
            req.httpBody = try? JSONSerialization.data(withJSONObject: ["fields": fields])
            if let (_, resp) = try? await URLSession.shared.data(for: req),
               let http = resp as? HTTPURLResponse, http.statusCode == 200 {
                showToast(isEnglish ? "Court added!" : "Площадка успешно добавлена!")
                return
            }
        }
        showToast(isEnglish ? "Court saved locally" : "Площадка сохранена локально")
    }
}
