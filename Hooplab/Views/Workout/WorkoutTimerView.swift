import SwiftUI

// MARK: - Interactive Training & Interval Timer Screen (1:1 Android activity_training.xml + TrainingActivity.kt)
public struct WorkoutTimerView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss

    public let exercise: Exercise

    private enum TrainingPhase {
        case ready
        case working
        case resting
        case completed
    }

    @State private var phase: TrainingPhase = .ready
    @State private var currentSet: Int = 1
    @State private var activeSetSeconds: Int = 0
    @State private var restRemainingSeconds: Int = 45
    @State private var totalWorkoutSeconds: Int = 0
    @State private var isMuted: Bool = SoundAndHaptics.shared.isMuted
    @State private var showFinishConfirm: Bool = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public init(exercise: Exercise) {
        self.exercise = exercise
    }

    private var totalSets: Int {
        max(1, exercise.parsedSetsCount)
    }

    private var defaultRest: Int {
        max(10, exercise.parsedRestSeconds)
    }

    public var body: some View {
        let isEn = dataStore.isEnglish

        VStack(spacing: 0) {
            // Top bar with Back, Title, Mute toggle, Level chip
            HooplabTopBar(
                title: exercise.localizedTitle(isEn: isEn),
                subtitle: exercise.localizedCategory(isEn: isEn),
                trailingView: AnyView(
                    HStack(spacing: 8) {
                        Button {
                            SoundAndHaptics.shared.vibrateClick()
                            isMuted.toggle()
                            SoundAndHaptics.shared.isMuted = isMuted
                        } label: {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(isMuted ? HooplabTheme.textSecondary : HooplabTheme.primary)
                                .frame(width: 40, height: 40)
                                .background(HooplabTheme.glassFill)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(HooplabTheme.glassStroke, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                )
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Interactive Interval Timer Card
                    timerCard(isEn: isEn)

                    // Exercise Photo
                    ExercisePhotoView(exerciseId: exercise.id, categoryRu: exercise.category.ru)
                        .frame(height: 165)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusCard))
                        .overlay(
                            RoundedRectangle(cornerRadius: HooplabDimens.radiusCard)
                                .stroke(HooplabTheme.glassStroke, lineWidth: 1)
                        )

                    // Sets & Rest summary
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(isEn ? "🎯 TARGET SETS" : "🎯 ПОДХОДЫ")
                                .font(.geist(11, weight: .bold))
                                .foregroundColor(HooplabTheme.primary)
                            Text(exercise.localizedSets(isEn: isEn))
                                .font(.geist(14, weight: .semibold))
                                .foregroundColor(HooplabTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .hooplabCard(padding: 14)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(isEn ? "⏱️ REST TIME" : "⏱️ ОТДЫХ")
                                .font(.geist(11, weight: .bold))
                                .foregroundColor(HooplabTheme.primary)
                            Text(exercise.localizedRest(isEn: isEn))
                                .font(.geist(14, weight: .semibold))
                                .foregroundColor(HooplabTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .hooplabCard(padding: 14)
                    }

                    // Muscles
                    VStack(alignment: .leading, spacing: 6) {
                        Text(isEn ? "💪 MUSCLES" : "💪 МЫШЦЫ")
                            .font(.geist(12, weight: .bold))
                            .foregroundColor(HooplabTheme.primary)
                        Text(exercise.localizedMuscles(isEn: isEn))
                            .font(.geist(14, weight: .regular))
                            .foregroundColor(HooplabTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .hooplabCard(padding: 16)

                    // Technique steps
                    let steps = exercise.stepsList(isEn: isEn)
                    if !steps.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(isEn ? "📋 TECHNIQUE" : "📋 ТЕХНИКА ВЫПОЛНЕНИЯ")
                                .font(.geist(12, weight: .bold))
                                .foregroundColor(HooplabTheme.primary)

                            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.geist(13, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(HooplabTheme.primary)
                                        .clipShape(Circle())

                                    Text(step)
                                        .font(.geist(14, weight: .regular))
                                        .foregroundColor(HooplabTheme.textPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .hooplabCard(padding: 16)
                    }

                    // Tips & Mistakes
                    let tips = exercise.localizedTips(isEn: isEn)
                    if !tips.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(isEn ? "💡 COACH TIP" : "💡 СОВЕТ ТРЕНЕРА")
                                .font(.geist(12, weight: .bold))
                                .foregroundColor(HooplabTheme.primary)
                            Text(tips)
                                .font(.geist(14, weight: .regular))
                                .foregroundColor(HooplabTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .hooplabCard(padding: 16, strokeColor: HooplabTheme.primary.opacity(0.4))
                    }

                    let mistakes = exercise.mistakesList(isEn: isEn)
                    if !mistakes.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(isEn ? "⚠️ MISTAKES TO AVOID" : "⚠️ ОШИБКИ")
                                .font(.geist(12, weight: .bold))
                                .foregroundColor(HooplabTheme.error)

                            ForEach(Array(mistakes.enumerated()), id: \.offset) { _, m in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(HooplabTheme.error)
                                        .padding(.top, 2)
                                    Text(m)
                                        .font(.geist(14, weight: .regular))
                                        .foregroundColor(HooplabTheme.textPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .hooplabCard(padding: 16, strokeColor: HooplabTheme.error.opacity(0.35))
                    }
                }
                .padding(.horizontal, HooplabDimens.screenPaddingH)
                .padding(.top, 4)
                .padding(.bottom, 20)
            }

            // Bottom Finish Workout CTA
            VStack {
                Button {
                    SoundAndHaptics.shared.vibrateClick()
                    if phase == .completed {
                        completeAndSaveWorkout(isEn: isEn)
                    } else {
                        showFinishConfirm = true
                    }
                } label: {
                    Text(isEn ? "Finish & Save Workout" : "Завершить тренировку")
                        .font(.geist(16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: HooplabDimens.buttonHeight)
                        .background(phase == .completed ? HooplabTheme.accentSecondary : HooplabTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusButton))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HooplabDimens.screenPaddingH)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(HooplabTheme.bgNav.opacity(0.85))
        }
        .hooplabAurora()
        .toolbar(.hidden, for: .navigationBar)
        .enableSwipeBack()
        .onReceive(timer) { _ in
            handleTimerTick()
        }
        .alert(
            isEn ? "Complete Workout?" : "Завершить тренировку?",
            isPresented: $showFinishConfirm
        ) {
            Button(isEn ? "Save & Finish" : "Сохранить и выйти") {
                completeAndSaveWorkout(isEn: isEn)
            }
            Button(isEn ? "Continue" : "Продолжить", role: .cancel) {}
        } message: {
            Text(
                isEn
                ? "Your workout progress and stats will be saved."
                : "Прогресс тренировки и статистика будут сохранены."
            )
        }
    }

    // MARK: - Interactive Interval Timer Card
    private func timerCard(isEn: Bool) -> some View {
        let phaseTitle: String = {
            switch phase {
            case .ready:
                return isEn ? "READY • SET 1 OF \(totalSets)" : "ГОТОВНОСТЬ • ПОДХОД 1 ИЗ \(totalSets)"
            case .working:
                return isEn ? "ACTIVE • SET \(currentSet) OF \(totalSets)" : "В РАБОТЕ • ПОДХОД \(currentSet) ИЗ \(totalSets)"
            case .resting:
                return isEn ? "REST BREAK" : "ОТДЫХ"
            case .completed:
                return isEn ? "WORKOUT COMPLETE ✅" : "ТРЕНИРОВКА ЗАВЕРШЕНА ✅"
            }
        }()

        let timerString: String = {
            switch phase {
            case .ready:
                return formatSeconds(totalWorkoutSeconds)
            case .working:
                return formatSeconds(activeSetSeconds)
            case .resting:
                return formatSeconds(restRemainingSeconds)
            case .completed:
                return formatSeconds(totalWorkoutSeconds)
            }
        }()

        let subtext: String = {
            switch phase {
            case .ready:
                return isEn ? "Tap below to start set 1" : "Нажмите ниже, чтобы начать подход 1"
            case .working:
                return isEn ? "Keep intensity high! Finish when done" : "Держите высокий темп! Нажмите по завершении"
            case .resting:
                return isEn ? "Catch your breath before set \(min(totalSets, currentSet + 1))" : "Восстановите дыхание перед подходом \(min(totalSets, currentSet + 1))"
            case .completed:
                return isEn ? "Great hustle! Tap Finish & Save below" : "Отличная работа! Нажмите Завершить ниже"
            }
        }()

        let accentColor: Color = {
            switch phase {
            case .ready, .working: return HooplabTheme.primary
            case .resting: return Color(hex: "3B82F6")
            case .completed: return HooplabTheme.accentSecondary
            }
        }()

        let completedFraction: Double = {
            switch phase {
            case .ready: return 0
            case .working: return Double(currentSet - 1) / Double(totalSets)
            case .resting: return Double(currentSet) / Double(totalSets)
            case .completed: return 1.0
            }
        }()

        return VStack(spacing: 14) {
            // Phase Badge
            Text(phaseTitle)
                .font(.geist(11, weight: .bold))
                .foregroundColor(accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(accentColor.opacity(0.16))
                .clipShape(Capsule())

            // Set Dots Indicator
            HStack(spacing: 10) {
                ForEach(1...totalSets, id: \.self) { idx in
                    let isDone = (phase == .completed) || (idx < currentSet) || (phase == .resting && idx == currentSet)
                    let isActive = (phase == .working && idx == currentSet) || (phase == .ready && idx == 1)

                    ZStack {
                        Circle()
                            .fill(isDone ? HooplabTheme.accentSecondary : (isActive ? HooplabTheme.primary : HooplabTheme.streakDayPending))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle().stroke(
                                    isActive ? HooplabTheme.primary : HooplabTheme.glassStroke,
                                    lineWidth: isActive ? 2 : 1
                                )
                            )

                        if isDone {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(HooplabTheme.streakDayTextDone)
                        } else {
                            Text("\(idx)")
                                .font(.geist(12, weight: .bold))
                                .foregroundColor(isActive ? .white : HooplabTheme.textSecondary)
                        }
                    }
                }
            }

            // Large Tabular Timer
            Text(timerString)
                .font(.system(size: 46, weight: .heavy, design: .monospaced))
                .foregroundColor(HooplabTheme.textPrimary)

            Text(subtext)
                .font(.geist(13, weight: .medium))
                .foregroundColor(HooplabTheme.textSecondary)
                .multilineTextAlignment(.center)

            // Action Controls
            switch phase {
            case .ready:
                Button {
                    SoundAndHaptics.shared.playStartWhistle()
                    activeSetSeconds = 0
                    withAnimation { phase = .working }
                } label: {
                    Text(isEn ? "Start Set 1" : "Начать подход 1")
                        .font(.geist(15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(HooplabTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

            case .working:
                Button {
                    finishActiveSet()
                } label: {
                    Text(
                        currentSet >= totalSets
                        ? (isEn ? "Complete Final Set" : "Завершить финальный подход")
                        : (isEn ? "Finish Set \(currentSet)" : "Завершить подход \(currentSet)")
                    )
                    .font(.geist(15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(HooplabTheme.accentSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

            case .resting:
                HStack(spacing: 10) {
                    Button {
                        SoundAndHaptics.shared.vibrateClick()
                        restRemainingSeconds += 15
                    } label: {
                        Text(isEn ? "+15 sec" : "+15 сек")
                            .font(.geist(14, weight: .bold))
                            .foregroundColor(HooplabTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(HooplabTheme.bgInput)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(HooplabTheme.glassStroke, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        SoundAndHaptics.shared.playStartWhistle()
                        advanceToNextSet()
                    } label: {
                        Text(isEn ? "Skip Rest" : "Пропустить отдых")
                            .font(.geist(14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(HooplabTheme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }

            case .completed:
                Text(
                    isEn
                    ? "Total Time: \(formatSeconds(totalWorkoutSeconds)) • All \(totalSets) sets complete!"
                    : "Общее время: \(formatSeconds(totalWorkoutSeconds)) • Все \(totalSets) подходов выполнены!"
                )
                .font(.geist(14, weight: .semibold))
                .foregroundColor(HooplabTheme.accentSecondary)
            }

            // Session Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(HooplabTheme.nbaSkillTrack)
                        .frame(height: 6)
                    Capsule()
                        .fill(accentColor)
                        .frame(width: max(0, geo.size.width * completedFraction), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: completedFraction)
                }
            }
            .frame(height: 6)
            .padding(.top, 4)
        }
        .hooplabCard(padding: 18, strokeColor: accentColor.opacity(0.45))
    }

    // MARK: - Timer Logic
    private func handleTimerTick() {
        switch phase {
        case .ready, .completed:
            break
        case .working:
            activeSetSeconds += 1
            totalWorkoutSeconds += 1
        case .resting:
            totalWorkoutSeconds += 1
            if restRemainingSeconds > 1 {
                restRemainingSeconds -= 1
                if restRemainingSeconds <= 3 {
                    SoundAndHaptics.shared.playCountdownTick()
                }
            } else {
                SoundAndHaptics.shared.playStartWhistle()
                advanceToNextSet()
            }
        }
    }

    private func finishActiveSet() {
        if currentSet >= totalSets {
            SoundAndHaptics.shared.playWorkoutComplete()
            withAnimation { phase = .completed }
        } else {
            SoundAndHaptics.shared.playSetComplete()
            restRemainingSeconds = defaultRest
            withAnimation { phase = .resting }
        }
    }

    private func advanceToNextSet() {
        currentSet = min(totalSets, currentSet + 1)
        activeSetSeconds = 0
        withAnimation { phase = .working }
    }

    private func completeAndSaveWorkout(isEn: Bool) {
        SoundAndHaptics.shared.playWorkoutComplete()
        let finalDuration = max(45, totalWorkoutSeconds)
        dataStore.saveWorkoutSession(exercise: exercise, durationSec: finalDuration)
        dataStore.showToast(
            isEn
            ? "Workout saved! Stats & Player Card updated 🔥"
            : "Тренировка сохранена! Статистика и карточка обновлены 🔥"
        )
        dismiss()
    }

    private func formatSeconds(_ totalSec: Int) -> String {
        let mins = totalSec / 60
        let secs = totalSec % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
