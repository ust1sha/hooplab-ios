import SwiftUI

public struct HomeView: View {
    @EnvironmentObject var dataStore: DataStore

    @State private var showingQuiz = false
    @State private var showingCourts = false
    @State private var showingLeaderboard = false
    @State private var selectedExercise: Exercise? = nil

    private var workoutOfTheDay: Exercise? {
        dataStore.exercises.first { $0.id == 2 } ?? dataStore.exercises.first
    }

    private var popularExercises: [Exercise] {
        Array(dataStore.exercises.prefix(8))
    }

    private let programs = WorkoutProgramsCatalog.programs

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background & Aurora glowing pastels
                Color.clear
                    .hooplabAurora()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // 1. Top Brand Header
                        topHeader

                        // 2. Fire Streak Card
                        streakCard

                        // 3. Quick Start Horizontal Pills
                        quickStartSection

                        // 4. Hero Banner "Тренировка дня"
                        if let wotd = workoutOfTheDay {
                            heroBanner(wotd)
                        }

                        // 5. Ready Programs Carousel
                        programsSection

                        // 6. Popular Exercises Carousel
                        popularSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingQuiz) {
                QuizSheetView()
                    .environmentObject(dataStore)
            }
            .sheet(isPresented: $showingCourts) {
                NavigationStack {
                    CourtsView()
                        .environmentObject(dataStore)
                }
            }
            .sheet(isPresented: $showingLeaderboard) {
                NavigationStack {
                    LeaderboardSheetView()
                        .environmentObject(dataStore)
                }
            }
            .sheet(item: $selectedExercise) { ex in
                NavigationStack {
                    ExerciseDetailView(exercise: ex)
                        .environmentObject(dataStore)
                }
            }
        }
    }

    // MARK: - 1. Top Header
    private var topHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(dataStore.isEnglish ? "Welcome to HoopLab!" : "Добро пожаловать в HoopLab!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)
                Text(dataStore.isEnglish ? "Track your basketball progress" : "Прокачивай навыки каждый день")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(HooplabTheme.textSecondary)
            }

            Spacer()

            // HoopLab Brand Badge
            ZStack {
                Circle()
                    .fill(HooplabTheme.orangePrimary)
                    .frame(width: 42, height: 42)
                    .shadow(color: HooplabTheme.orangePrimary.opacity(0.35), radius: 6, x: 0, y: 3)

                Image(systemName: "basketball.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - 2. Fire Streak Card (matches streakContainer)
    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Text("🔥")
                        .font(.system(size: 18))
                    Text(dataStore.isEnglish ? "\(dataStore.streakDays) Day Streak" : "\(dataStore.streakDays) дн. серия")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(HooplabTheme.orangePrimary)
                }

                Spacer()

                Text(dataStore.isEnglish ? "Goal: \(dataStore.totalMinutes) / 120 min" : "Цель: \(dataStore.totalMinutes) / 120 мин")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(HooplabTheme.textSecondary)
            }

            // Weekly Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(HooplabTheme.bgNav)
                        .frame(height: 6)

                    let progress = min(1.0, Double(max(10, dataStore.totalMinutes)) / 120.0)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(HooplabTheme.orangePrimary)
                        .frame(width: max(12, geo.size.width * CGFloat(progress)), height: 6)
                }
            }
            .frame(height: 6)

            // 7 Days of the week row
            HStack(spacing: 0) {
                let days = dataStore.isEnglish
                    ? ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                    : ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

                ForEach(0..<days.count, id: \.self) { idx in
                    let isCompleted = idx == 0 || (idx < dataStore.streakDays)
                    ZStack {
                        Circle()
                            .fill(isCompleted ? HooplabTheme.greenAccent : HooplabTheme.bgNav)
                            .frame(width: 32, height: 32)

                        Text(days[idx])
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(isCompleted ? .white : HooplabTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .hooplabCard(padding: 16, cornerRadius: 20)
    }

    // MARK: - 3. Quick Start Section
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dataStore.isEnglish ? "Quick Start" : "Быстрый старт")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    quickPill(title: dataStore.isEnglish ? "Warmup" : "Разминка", icon: "flame.fill", color: HooplabTheme.orangePrimary) {
                        openPillExercise(named: "разминк")
                    }

                    quickPill(title: dataStore.isEnglish ? "Free Throws" : "Штрафные", icon: "scope", color: HooplabTheme.orangePrimary) {
                        openPillExercise(named: "штрафн")
                    }

                    quickPill(title: dataStore.isEnglish ? "Home Dribbling" : "Дриблинг дома", icon: "bolt.fill", color: Color(hex: "D97706")) {
                        openPillExercise(named: "дриблинг")
                    }

                    quickPill(title: dataStore.isEnglish ? "Defense Stance" : "Защитная стойка", icon: "shield.fill", color: Color(hex: "16A34A")) {
                        openPillExercise(named: "защит")
                    }

                    quickPill(title: dataStore.isEnglish ? "Cooldown" : "Заминка", icon: "figure.mind.and.body", color: Color(hex: "9333EA")) {
                        openPillExercise(named: "заминк")
                    }

                    quickPill(title: dataStore.isEnglish ? "Leaderboard" : "Лидерборд", icon: "trophy.fill", color: Color(hex: "EA580C")) {
                        SoundAndHaptics.shared.lightTap()
                        showingLeaderboard = true
                    }

                    quickPill(title: dataStore.isEnglish ? "Courts" : "Площадки", icon: "mappin.circle.fill", color: Color(hex: "2563EB")) {
                        SoundAndHaptics.shared.lightTap()
                        showingCourts = true
                    }
                }
            }
        }
    }

    private func quickPill(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)

                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(HooplabTheme.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color.white.opacity(0.95))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(HooplabTheme.cardBorder, lineWidth: 1)
            )
            .shadow(color: HooplabTheme.shadowColor, radius: 4, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private func openPillExercise(named keyword: String) {
        SoundAndHaptics.shared.lightTap()
        let match = dataStore.exercises.first { (ex: Exercise) -> Bool in
            ex.titleRu.lowercased().contains(keyword) || ex.categoryRu.lowercased().contains(keyword)
        }
        selectedExercise = match ?? dataStore.exercises.first
    }

    // MARK: - 4. Hero Banner (matches section_recommended & bg_hero_card)
    private func heroBanner(_ exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dataStore.isEnglish ? "Workout of the Day" : "Тренировка дня")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)

            ZStack(alignment: .topTrailing) {
                // Background Card
                RoundedRectangle(cornerRadius: 22)
                    .fill(HooplabTheme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(HooplabTheme.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: HooplabTheme.shadowColor, radius: 8, x: 0, y: 3)

                // Kinetic Silhouette Dunk Artwork on Right
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [HooplabTheme.orangePrimary.opacity(0.18), Color.clear],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 140, height: 140)

                        Image(systemName: "figure.basketball")
                            .font(.system(size: 80, weight: .semibold))
                            .foregroundColor(HooplabTheme.orangePrimary.opacity(0.65))
                            .rotationEffect(.degrees(-8))
                    }
                    .padding(.trailing, 10)
                    .padding(.top, 14)
                }

                // Foreground Content
                VStack(alignment: .leading, spacing: 10) {
                    // Badges row
                    HStack(spacing: 6) {
                        Text(dataStore.isEnglish ? "TREND" : "ТРЕНД")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(HooplabTheme.orangePrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(HooplabTheme.orangeSoft)
                            .cornerRadius(6)

                        Text("⏱ 15 МИН")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(HooplabTheme.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(HooplabTheme.bgNav)
                            .cornerRadius(6)

                        Text("⭐ " + exercise.localizedLevel(isEn: dataStore.isEnglish).uppercased())
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(HooplabTheme.levelColor(exercise.levelRu))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(HooplabTheme.levelBgColor(exercise.levelRu))
                            .cornerRadius(6)
                    }

                    // Title
                    Text(exercise.localizedTitle(isEn: dataStore.isEnglish))
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)
                        .padding(.trailing, 90)

                    // Description
                    Text(exercise.localizedDescription(isEn: dataStore.isEnglish))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(HooplabTheme.textSecondary)
                        .lineLimit(2)
                        .padding(.trailing, 90)

                    // CTA Button
                    Button(action: {
                        SoundAndHaptics.shared.mediumTap()
                        selectedExercise = exercise
                    }) {
                        HStack {
                            Spacer()
                            Text(dataStore.isEnglish ? "Start Workout" : "Начать тренировку")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(height: 48)
                        .background(HooplabTheme.orangePrimary)
                        .cornerRadius(14)
                        .shadow(color: HooplabTheme.orangePrimary.opacity(0.35), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(16)
            }
        }
    }

    // MARK: - 5. Programs Section (matches section_programs & item_program_card)
    private var programsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dataStore.isEnglish ? "Workouts & Programs" : "Готовые комплексы")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(programs) { program in
                        programCard(program)
                    }
                }
            }
        }
    }

    private func programCard(_ program: WorkoutProgram) -> some View {
        Button(action: {
            SoundAndHaptics.shared.lightTap()
            if let firstId = program.exerciseIds.first,
               let ex = dataStore.exercises.first(where: { $0.id == firstId }) {
                selectedExercise = ex
            }
        }) {
            ZStack(alignment: .bottomLeading) {
                // Background Gradient
                LinearGradient(
                    colors: [Color(hex: program.gradientColors[0]), Color(hex: program.gradientColors[1])],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Dark gradient scrim
                LinearGradient(
                    colors: [Color.black.opacity(0.15), Color.black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Background symbol watermark
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: program.iconName)
                            .font(.system(size: 64, weight: .ultraLight))
                            .foregroundColor(Color.white.opacity(0.2))
                            .offset(x: 10, y: -10)
                    }
                    Spacer()
                }

                // Card info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(program.tag)
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.22))
                            .cornerRadius(6)

                        Spacer()

                        Text("⏱ \(program.durationMinutes) мин")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    Text(program.titleRu)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text("\(program.exerciseCount) упр • \(program.levelRu)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(14)
            }
            .frame(width: 260, height: 146)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(HooplabTheme.cardBorder.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: HooplabTheme.shadowColor, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 6. Popular Exercises Carousel (matches section_popular)
    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dataStore.isEnglish ? "Popular Exercises" : "Популярные упражнения")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(popularExercises) { exercise in
                        ExerciseCarouselCardView(exercise: exercise) {
                            selectedExercise = exercise
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Leaderboard Sheet View (matches activity_leaderboard.xml)
public struct LeaderboardSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: DataStore

    public struct MockUser: Identifiable {
        public let id = UUID()
        public let rank: Int
        public let name: String
        public let position: String
        public let jersey: Int
        public let ovr: Int
        public let isCurrentUser: Bool
    }

    private var leaderboardUsers: [MockUser] {
        [
            MockUser(rank: 1, name: "Андрей Кириленко", position: "SF", jersey: 47, ovr: 91, isCurrentUser: false),
            MockUser(rank: 2, name: "Алексей Швед", position: "PG", jersey: 1, ovr: 88, isCurrentUser: false),
            MockUser(rank: 3, name: "Виктор Хряпа", position: "PF", jersey: 20, ovr: 85, isCurrentUser: false),
            MockUser(rank: 4, name: dataStore.playerName.isEmpty ? "Вы" : dataStore.playerName, position: dataStore.playerPosition.rawValue, jersey: dataStore.playerJersey, ovr: dataStore.calculateOVR(), isCurrentUser: true),
            MockUser(rank: 5, name: "Виталий Фридзон", position: "SG", jersey: 7, ovr: 83, isCurrentUser: false),
            MockUser(rank: 6, name: "Тимофей Мозгов", position: "C", jersey: 25, ovr: 82, isCurrentUser: false),
            MockUser(rank: 7, name: "Сергей Моня", position: "SF", jersey: 12, ovr: 80, isCurrentUser: false)
        ]
    }

    public var body: some View {
        ZStack {
            Color.clear
                .hooplabAurora()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(HooplabTheme.textSecondary)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text(dataStore.isEnglish ? "Leaderboard" : "Рейтинг атлетов")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(HooplabTheme.textPrimary)
                        Text(dataStore.isEnglish ? "HoopLab Top Players" : "Таблица лидеров HoopLab")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(HooplabTheme.textSecondary)
                    }

                    Spacer()

                    // Balance spacer
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 26, height: 26)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(leaderboardUsers) { user in
                            HStack(spacing: 12) {
                                // Rank
                                Text("#\(user.rank)")
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundColor(user.rank <= 3 ? HooplabTheme.orangePrimary : HooplabTheme.textSecondary)
                                    .frame(width: 36)

                                // Name and info
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 6) {
                                        Text(user.name)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(HooplabTheme.textPrimary)

                                        if user.isCurrentUser {
                                            Text("ВЫ")
                                                .font(.system(size: 10, weight: .heavy))
                                                .foregroundColor(HooplabTheme.orangePrimary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(HooplabTheme.orangeSoft)
                                                .cornerRadius(6)
                                        }
                                    }

                                    Text("\(user.position) • #\(user.jersey)")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(HooplabTheme.textSecondary)
                                }

                                Spacer()

                                // OVR Badge
                                VStack(spacing: 0) {
                                    Text("\(user.ovr)")
                                        .font(.system(size: 18, weight: .heavy))
                                        .foregroundColor(HooplabTheme.textPrimary)
                                    Text("OVR")
                                        .font(.system(size: 8, weight: .heavy))
                                        .foregroundColor(HooplabTheme.textSecondary)
                                }
                                .frame(width: 50, height: 44)
                                .background(user.isCurrentUser ? HooplabTheme.orangeSoft : HooplabTheme.bgNav)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(HooplabTheme.cardBg)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(user.isCurrentUser ? HooplabTheme.orangePrimary : HooplabTheme.cardBorder, lineWidth: user.isCurrentUser ? 1.5 : 1)
                            )
                            .shadow(color: HooplabTheme.shadowColor, radius: 4, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
    }
}
