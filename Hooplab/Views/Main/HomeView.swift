import SwiftUI

public struct HomeView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedProgram: WorkoutProgram? = nil
    @State private var navigatedExercise: Exercise? = nil

    public init() {}

    public var body: some View {
        let isEn = dataStore.isEnglish

        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HooplabDimens.space5) {
                headerSection(isEn: isEn)

                streakCardSection(isEn: isEn)

                quickPillsSection(isEn: isEn)

                if let recommended = dataStore.recommendedExercise {
                    heroBannerSection(exercise: recommended, isEn: isEn)
                }

                programsSection(isEn: isEn)

                popularExercisesSection(isEn: isEn)
            }
            .padding(.horizontal, HooplabDimens.screenPaddingH)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .hooplabAurora()
        .sheet(item: $selectedProgram) { program in
            ProgramExercisesSheet(program: program, isEn: isEn) { chosenExercise in
                selectedProgram = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    navigatedExercise = chosenExercise
                }
            }
            .environmentObject(dataStore)
        }
        .navigationDestination(isPresented: Binding(
            get: { navigatedExercise != nil },
            set: { if !$0 { navigatedExercise = nil } }
        )) {
            if let ex = navigatedExercise {
                ExerciseDetailView(exercise: ex)
            }
        }
    }

    // MARK: - 1. Header
    private func headerSection(isEn: Bool) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(isEn ? "Welcome back," : "Добро пожаловать,")
                    .font(.geist(15, weight: .medium))
                    .foregroundColor(HooplabTheme.textSecondary)

                Text("\(dataStore.playerName)!")
                    .font(.geist(26, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            Image("ic_hooplab_badge")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 4)
    }

    // MARK: - 2. Fire Streak & Weekly Progress Card
    private func streakCardSection(isEn: Bool) -> some View {
        let streak = dataStore.streakState
        let progress = min(1.0, Double(streak.weeklyMinutes) / Double(max(1, streak.weeklyGoalMinutes)))

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 18))
                    .foregroundColor(HooplabTheme.fireOrange)

                Text(
                    isEn
                    ? "\(streak.streakDays) day streak"
                    : "\(streak.streakDays) дн. подряд"
                )
                .font(.geist(17, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)

                Spacer()

                Text("\(streak.weeklyMinutes) / \(streak.weeklyGoalMinutes) " + (isEn ? "min" : "мин"))
                    .font(.geist(13, weight: .semibold))
                    .foregroundColor(HooplabTheme.primary)
            }

            // Mon..Sun circles
            HStack(spacing: 0) {
                ForEach(streak.days) { day in
                    VStack(spacing: 6) {
                        Text(day.shortLabel)
                            .font(.geist(11, weight: day.isToday ? .bold : .medium))
                            .foregroundColor(day.isToday ? HooplabTheme.primary : HooplabTheme.textSecondary)

                        ZStack {
                            Circle()
                                .fill(day.isCompleted ? HooplabTheme.streakDayCompleted : HooplabTheme.streakDayPending)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle().stroke(
                                        day.isToday && !day.isCompleted ? HooplabTheme.primary : Color.clear,
                                        lineWidth: 1.5
                                    )
                                )

                            if day.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(HooplabTheme.streakDayTextDone)
                            } else {
                                Circle()
                                    .fill(day.isToday ? HooplabTheme.primary : HooplabTheme.textHint.opacity(0.45))
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Weekly goal progress bar
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(HooplabTheme.nbaSkillTrack)
                            .frame(height: 8)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [HooplabTheme.primary, HooplabTheme.accentSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(progress > 0 ? 12 : 0, geo.size.width * progress), height: 8)
                    }
                }
                .frame(height: 8)

                Text(
                    isEn
                    ? "Weekly goal: \(streak.weeklyMinutes) of \(streak.weeklyGoalMinutes) min"
                    : "Недельная цель: \(streak.weeklyMinutes) из \(streak.weeklyGoalMinutes) мин"
                )
                .font(.geist(11, weight: .medium))
                .foregroundColor(HooplabTheme.textSecondary)
            }
        }
        .hooplabCard(padding: 16)
    }

    // MARK: - 3. Quick Start Horizontal Pills
    private func quickPillsSection(isEn: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                pillExerciseButton(title: isEn ? "🔥 Warmup" : "🔥 Разминка", key: "warmup")
                pillExerciseButton(title: isEn ? "🎯 Free Throws" : "🎯 Штрафные", key: "freethrows")
                pillExerciseButton(title: isEn ? "⚡ Dribbling" : "⚡ Дриблинг", key: "dribbling")
                pillExerciseButton(title: isEn ? "🛡️ Defense" : "🛡️ Защита", key: "defense")

                NavigationLink {
                    LeaderboardView()
                } label: {
                    quickPillLabel(isEn ? "🏆 Top-50" : "🏆 Топ-50")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    CourtsView()
                } label: {
                    quickPillLabel(isEn ? "📍 Courts" : "📍 Площадки")
                }
                .buttonStyle(.plain)

                pillExerciseButton(title: isEn ? "❄️ Cooldown" : "❄️ Заминка", key: "cooldown")
            }
            .padding(.vertical, 2)
        }
    }

    private func pillExerciseButton(title: String, key: String) -> some View {
        Group {
            if let ex = dataStore.findExerciseForPill(key) {
                NavigationLink {
                    ExerciseDetailView(exercise: ex)
                } label: {
                    quickPillLabel(title)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func quickPillLabel(_ title: String) -> some View {
        Text(title)
            .font(.geist(13, weight: .semibold))
            .foregroundColor(HooplabTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(HooplabTheme.glassFill)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(HooplabTheme.glassStroke, lineWidth: 1))
    }

    // MARK: - 4. Hero Banner (Kinetic Dunk - matches bg_hero_card.xml)
    private func heroBannerSection(exercise: Exercise, isEn: Bool) -> some View {
        NavigationLink {
            ExerciseDetailView(exercise: exercise)
        } label: {
            ZStack(alignment: .bottomTrailing) {
                // Dark kinetic surface + orange glow
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "141923"), Color(hex: "1E1722")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RadialGradient(
                    colors: [Color(hex: "FF5500").opacity(0.35), Color.clear],
                    center: .trailing,
                    startRadius: 8,
                    endRadius: 170
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))

                Image("ic_hero_kinetic_dunk")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 118, height: 118)
                    .padding(.trailing, 4)
                    .padding(.bottom, 4)
                    .opacity(0.95)

                VStack(alignment: .leading, spacing: 8) {
                    Text(isEn ? "🔥 WORKOUT OF THE DAY" : "🔥 ХИТ ДНЯ")
                        .font(.geist(11, weight: .bold))
                        .foregroundColor(Color(hex: "FF7A33"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "FF5500").opacity(0.22))
                        .clipShape(Capsule())

                    Text(exercise.localizedTitle(isEn: isEn))
                        .font(.geist(20, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text("\(exercise.localizedCategory(isEn: isEn)) • \(exercise.localizedSets(isEn: isEn))")
                        .font(.geist(13, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(isEn ? "START NOW" : "НАЧАТЬ СЕЙЧАС")
                            .font(.geist(13, weight: .bold))
                        Image(systemName: "play.fill")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hex: "FF5500"))
                    .clipShape(Capsule())
                    .padding(.top, 4)
                }
                .padding(18)
                .padding(.trailing, 92)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color(hex: "FF5500").opacity(0.38), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 5. Workout Programs Section (260x146 cards with program_*.webp)
    private func programsSection(isEn: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isEn ? "Training Programs" : "Программы тренировок")
                .font(.geist(HooplabDimens.textSection, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(dataStore.programs) { program in
                        Button {
                            SoundAndHaptics.shared.vibrateClick()
                            selectedProgram = program
                        } label: {
                            ZStack(alignment: .bottomLeading) {
                                ProgramPhotoView(imageName: program.imageName)
                                    .frame(width: 260, height: 146)
                                    .clipped()

                                LinearGradient(
                                    colors: [Color.black.opacity(0.18), Color.black.opacity(0.84)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )

                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Text(program.tag)
                                            .font(.geist(10, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.black.opacity(0.45))
                                            .clipShape(Capsule())

                                        Spacer()

                                        Text(isEn ? "START" : "СТАРТ")
                                            .font(.geist(10, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 9)
                                            .padding(.vertical, 4)
                                            .background(Color(hex: "FF5500"))
                                            .clipShape(Capsule())
                                    }

                                    Spacer()

                                    Text(program.localizedTitle(isEn: isEn))
                                        .font(.geist(16, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)

                                    Text(
                                        isEn
                                        ? "\(program.durationMinutes) min • \(program.exerciseCount) drills • \(program.localizedLevel(isEn: true))"
                                        : "\(program.durationMinutes) мин • \(program.exerciseCount) упр. • \(program.localizedLevel(isEn: false))"
                                    )
                                    .font(.geist(12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                                }
                                .padding(14)
                            }
                            .frame(width: 260, height: 146)
                            .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusCard))
                            .overlay(
                                RoundedRectangle(cornerRadius: HooplabDimens.radiusCard)
                                    .stroke(HooplabTheme.glassStroke.opacity(0.45), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - 6. Popular Exercises Carousel
    private func popularExercisesSection(isEn: Bool) -> some View {
        let popular = Array(dataStore.exercises.prefix(8))

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isEn ? "Popular Drills" : "Популярные упражнения")
                    .font(.geist(HooplabDimens.textSection, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)

                Spacer()

                Button {
                    SoundAndHaptics.shared.vibrateClick()
                    dataStore.selectedTab = .exercises
                } label: {
                    Text(isEn ? "All" : "Все")
                        .font(.geist(14, weight: .semibold))
                        .foregroundColor(HooplabTheme.primary)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(popular) { exercise in
                        NavigationLink {
                            ExerciseDetailView(exercise: exercise)
                        } label: {
                            ExerciseCarouselCardView(exercise: exercise, isEn: isEn)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Program Exercises Sheet
private struct ProgramExercisesSheet: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss

    let program: WorkoutProgram
    let isEn: Bool
    let onSelectExercise: (Exercise) -> Void

    var body: some View {
        let drills = dataStore.exercises.filter { program.exerciseIds.contains($0.id) }

        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .bottomLeading) {
                        ProgramPhotoView(imageName: program.imageName)
                            .frame(height: 170)
                            .frame(maxWidth: .infinity)
                            .clipped()

                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(program.tag)
                                .font(.geist(11, weight: .bold))
                                .foregroundColor(Color(hex: "FF7A33"))
                            Text(program.localizedTitle(isEn: isEn))
                                .font(.geist(22, weight: .bold))
                                .foregroundColor(.white)
                            Text(program.localizedDescription(isEn: isEn))
                                .font(.geist(13, weight: .regular))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(16)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Text(isEn ? "Drills in program" : "Упражнения в программе")
                        .font(.geist(17, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)

                    ForEach(drills) { ex in
                        Button {
                            SoundAndHaptics.shared.vibrateClick()
                            onSelectExercise(ex)
                        } label: {
                            ExerciseListCardView(exercise: ex, isEn: isEn)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(HooplabDimens.screenPaddingH)
            }
            .hooplabAurora()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEn ? "Close" : "Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(HooplabTheme.primary)
                }
            }
        }
    }
}
