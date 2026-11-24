import SwiftUI
import Combine

public enum WorkoutPhase {
    case ready
    case activeWork
    case resting
    case completed
}

public struct WorkoutTimerView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    public let exercise: Exercise

    @State private var phase: WorkoutPhase = .ready
    @State private var currentSet: Int = 1
    @State private var totalSets: Int = 3
    @State private var restDuration: Int = 45
    @State private var timeRemaining: Int = 45
    @State private var isRunning = false
    @State private var totalDurationSec: Int = 0
    @State private var showCelebration = false

    @State private var timerSubscription: AnyCancellable?

    public var body: some View {
        ZStack {
            HooplabTheme.bgDark.ignoresSafeArea()

            VStack(spacing: 24) {
                // Top Bar
                HStack {
                    Button(action: {
                        stopTimer()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(HooplabTheme.textMuted)
                    }

                    Spacer()

                    VStack {
                        Text(exercise.localizedCategory(isEn: dataStore.isEnglish).uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(exercise.categoryColor)
                        Text(exercise.localizedTitle(isEn: dataStore.isEnglish))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text("🔥 +\(currentSet * 25) XP")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(HooplabTheme.orangePrimary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if phase == .completed {
                    completedView
                } else {
                    activeWorkoutView
                }
            }
        }
        .onAppear {
            self.totalSets = exercise.parsedSetsCount
            self.restDuration = exercise.parsedRestSeconds
            self.timeRemaining = restDuration
        }
        .onDisappear {
            stopTimer()
        }
    }

    private var activeWorkoutView: some View {
        VStack(spacing: 32) {
            // Sets indicator
            HStack(spacing: 8) {
                ForEach(1...totalSets, id: \.self) { idx in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(idx < currentSet ? HooplabTheme.orangePrimary : (idx == currentSet ? Color.white : Color.white.opacity(0.15)))
                        .frame(height: 6)
                }
            }
            .padding(.horizontal, 30)

            VStack(spacing: 8) {
                Text(phase == .resting ? (dataStore.isEnglish ? "REST INTERVAL" : "ВРЕМЯ ОТДЫХА") : (dataStore.isEnglish ? "SET \(currentSet) OF \(totalSets)" : "ПОДХОД \(currentSet) ИЗ \(totalSets)"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(phase == .resting ? .green : HooplabTheme.orangePrimary)
                    .tracking(2)

                Text(phase == .resting ? "\(timeRemaining) сек" : (dataStore.isEnglish ? "Perform Set" : "Выполняйте подход"))
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.white)
            }

            // Circular Timer
            ZStack {
                let progress = phase == .resting ? Double(restDuration - timeRemaining) / Double(max(1, restDuration)) : 1.0
                CircularProgressView(
                    progress: progress,
                    lineWidth: 18,
                    color: phase == .resting ? .green : HooplabTheme.orangePrimary
                )
                .frame(width: 220, height: 220)

                VStack(spacing: 8) {
                    if phase == .resting {
                        Text(formatSeconds(timeRemaining))
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(dataStore.isEnglish ? "to next set" : "до след. подхода")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(HooplabTheme.textMuted)
                    } else {
                        Image(systemName: exercise.sfSymbol)
                            .font(.system(size: 54))
                            .foregroundColor(HooplabTheme.orangePrimary)
                        Text(exercise.localizedSets(isEn: dataStore.isEnglish))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(HooplabTheme.textSecondary)
                    }
                }
            }
            .padding(.vertical, 10)

            Spacer()

            // Control Buttons
            VStack(spacing: 14) {
                if phase == .resting {
                    Button(action: {
                        SoundAndHaptics.shared.mediumTap()
                        skipRest()
                    }) {
                        HStack {
                            Image(systemName: "forward.fill")
                            Text(dataStore.isEnglish ? "Skip Rest" : "Пропустить отдых")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(HooplabTheme.cardDark)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                } else {
                    Button(action: {
                        SoundAndHaptics.shared.success()
                        finishSet()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                            Text(currentSet < totalSets ? (dataStore.isEnglish ? "Done: Next Set" : "Подход выполнен ▶") : (dataStore.isEnglish ? "Finish Workout" : "Завершить тренировку 🎉"))
                                .font(.system(size: 18, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(HooplabTheme.orangeGradient)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .shadow(color: HooplabTheme.orangePrimary.opacity(0.4), radius: 10, y: 5)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(HooplabTheme.orangePrimary.opacity(0.15))
                    .frame(width: 130, height: 130)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 64))
                    .foregroundColor(HooplabTheme.orangePrimary)
            }

            VStack(spacing: 8) {
                Text(dataStore.isEnglish ? "Workout Complete!" : "Тренировка завершена!")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(.white)

                Text(dataStore.isEnglish ? "Great work! You've improved your skills." : "Отличная работа! Навыки игрока улучшены.")
                    .font(.system(size: 15))
                    .foregroundColor(HooplabTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("+\(totalSets * 25 + 50)")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(HooplabTheme.orangePrimary)
                    Text("XP Опыт")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(HooplabTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .hooplabCard()

                VStack(spacing: 4) {
                    Text("\(totalSets)")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.green)
                    Text(dataStore.isEnglish ? "Sets" : "Подходов")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(HooplabTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .hooplabCard()
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: {
                SoundAndHaptics.shared.mediumTap()
                dismiss()
            }) {
                Text(dataStore.isEnglish ? "Awesome!" : "Отлично, к тренировкам")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(HooplabTheme.orangeGradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private func finishSet() {
        if currentSet < totalSets {
            phase = .resting
            timeRemaining = restDuration
            startRestTimer()
        } else {
            completeWorkout()
        }
    }

    private func skipRest() {
        stopTimer()
        currentSet += 1
        phase = .activeWork
    }

    private func startRestTimer() {
        stopTimer()
        isRunning = true
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                totalDurationSec += 1
                if timeRemaining > 1 {
                    timeRemaining -= 1
                    if timeRemaining <= 3 {
                        SoundAndHaptics.shared.timerCountdownBeep()
                    }
                } else {
                    stopTimer()
                    SoundAndHaptics.shared.success()
                    currentSet += 1
                    phase = .activeWork
                }
            }
    }

    private func stopTimer() {
        isRunning = false
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    private func completeWorkout() {
        stopTimer()
        phase = .completed
        SoundAndHaptics.shared.timerCompleteSound()
        dataStore.recordWorkout(exercise: exercise, setsCompleted: totalSets, durationSec: max(60, totalDurationSec))
    }

    private func formatSeconds(_ sec: Int) -> String {
        let m = sec / 60
        let s = sec % 60
        return String(format: "%02d:%02d", m, s)
    }
}
