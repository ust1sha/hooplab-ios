import SwiftUI

public struct HomeView: View {
    @EnvironmentObject var dataStore: DataStore

    @State private var showingQuiz = false
    @State private var selectedExercise: Exercise? = nil

    private var workoutOfTheDay: Exercise? {
        dataStore.exercises.first { $0.id == 1 } ?? dataStore.exercises.first
    }

    private var recentFavorites: [Exercise] {
        Array(dataStore.exercises.filter { dataStore.isFavorite(id: $0.id) }.prefix(3))
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                HooplabTheme.bgDark.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // Top Brand Bar
                        headerBar

                        // Workout of the Day Banner
                        if let wotd = workoutOfTheDay {
                            workoutOfTheDayCard(wotd)
                        }

                        // Quick Stats Row
                        statsRow

                        // Quiz Banner
                        quizPromoCard

                        // Popular Categories Grid
                        categoriesSection

                        // Recommended Exercises
                        recommendedSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingQuiz) {
                QuizSheetView()
                    .environmentObject(dataStore)
            }
            .navigationDestination(item: $selectedExercise) { ex in
                ExerciseDetailView(exercise: ex)
                    .environmentObject(dataStore)
            }
        }
    }

    private var headerBar: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "basketball.fill")
                    .font(.system(size: 26))
                    .foregroundColor(HooplabTheme.orangePrimary)

                Text("HOOPLAB")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(1)
            }

            Spacer()

            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 15))
                    Text("\(dataStore.streakDays)")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)

                HStack(spacing: 4) {
                    Text("⚡")
                        .font(.system(size: 14))
                    Text("\(dataStore.totalXP)")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(HooplabTheme.orangePrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(HooplabTheme.orangePrimary.opacity(0.15))
                .cornerRadius(12)
            }
        }
    }

    private func workoutOfTheDayCard(_ exercise: Exercise) -> some View {
        Button(action: {
            SoundAndHaptics.shared.mediumTap()
            selectedExercise = exercise
        }) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.95, green: 0.35, blue: 0.0), Color(red: 0.2, green: 0.08, blue: 0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                            Text(dataStore.isEnglish ? "WORKOUT OF THE DAY" : "ТРЕНИРОВКА ДНЯ")
                                .font(.system(size: 11, weight: .black))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.35))
                        .foregroundColor(.white)
                        .cornerRadius(20)

                        Spacer()

                        Image(systemName: exercise.sfSymbol)
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    Text(exercise.localizedTitle(isEn: dataStore.isEnglish))
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.white)

                    Text(exercise.localizedSets(isEn: dataStore.isEnglish) + " • " + exercise.localizedRest(isEn: dataStore.isEnglish))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))

                    HStack {
                        Text(dataStore.isEnglish ? "Start Now" : "Начать сейчас")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(10)

                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .padding(18)
            }
        }
        .buttonStyle(.plain)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statBox(
                icon: "checkmark.circle.fill",
                iconColor: .green,
                value: "\(dataStore.completedSessions.count)",
                title: dataStore.isEnglish ? "Workouts" : "Тренировок"
            )

            let totalMins = dataStore.completedSessions.reduce(0) { $0 + $1.durationSec } / 60
            statBox(
                icon: "timer",
                iconColor: .blue,
                value: "\(totalMins) м",
                title: dataStore.isEnglish ? "Minutes" : "Минут"
            )

            let ovr = dataStore.calculateSkills().ovr
            statBox(
                icon: "crown.fill",
                iconColor: .yellow,
                value: "\(ovr)",
                title: dataStore.isEnglish ? "Player OVR" : "Рейтинг OVR"
            )
        }
    }

    private func statBox(icon: String, iconColor: Color, value: String, title: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)

            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(HooplabTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .hooplabCard(padding: 12)
    }

    private var quizPromoCard: some View {
        Button(action: {
            SoundAndHaptics.shared.mediumTap()
            showingQuiz = true
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(HooplabTheme.orangePrimary.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(HooplabTheme.orangePrimary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(dataStore.isEnglish ? "Basketball IQ Quiz" : "Баскетбольный IQ-Квиз")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(dataStore.isEnglish ? "Check your knowledge of rules & tactics" : "Проверь свои знания правил и тактики")
                        .font(.system(size: 12))
                        .foregroundColor(HooplabTheme.textSecondary)
                }

                Spacer()

                Text(dataStore.isEnglish ? "Play" : "Играть")
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(HooplabTheme.orangePrimary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .hooplabCard(padding: 14)
        }
        .buttonStyle(.plain)
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dataStore.isEnglish ? "TRAINING CATEGORIES" : "КАТЕГОРИИ ТРЕНИРОВОК")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(HooplabTheme.textMuted)
                .tracking(1)

            let cats: [ExerciseCategory] = [.shots, .dribbling, .defense, .technique, .physical]
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(cats) { cat in
                    let count = dataStore.exercises.filter { cat.matches(categoryString: $0.category.en) }.count
                    HStack(spacing: 10) {
                        Image(systemName: cat.sfSymbol)
                            .font(.system(size: 18))
                            .foregroundColor(HooplabTheme.orangePrimary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(cat.localized(isEn: dataStore.isEnglish))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(count) \(dataStore.isEnglish ? "exercises" : "упражнений")")
                                .font(.system(size: 11))
                                .foregroundColor(HooplabTheme.textMuted)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(HooplabTheme.cardDark)
                    .cornerRadius(12)
                }
            }
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dataStore.isEnglish ? "POPULAR EXERCISES" : "ПОПУЛЯРНЫЕ УПРАЖНЕНИЯ")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(HooplabTheme.textMuted)
                    .tracking(1)

                Spacer()
            }

            let topExercises = Array(dataStore.exercises.prefix(4))
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                ForEach(topExercises) { exercise in
                    ExerciseCardView(exercise: exercise) {
                        selectedExercise = exercise
                    }
                }
            }
        }
    }
}
