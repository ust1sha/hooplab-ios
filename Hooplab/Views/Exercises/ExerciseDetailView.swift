import SwiftUI

public struct ExerciseDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    public let exercise: Exercise

    @State private var showingWorkoutTimer = false

    public var body: some View {
        ZStack {
            Color.clear
                .hooplabAurora()

            VStack(spacing: 0) {
                // Top Custom Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(HooplabTheme.textSecondary)
                    }

                    Spacer()

                    Text(exercise.localizedCategory(isEn: dataStore.isEnglish))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)

                    Spacer()

                    Button(action: {
                        SoundAndHaptics.shared.mediumTap()
                        dataStore.toggleFavorite(id: exercise.id)
                    }) {
                        Image(systemName: dataStore.isFavorite(id: exercise.id) ? "heart.fill" : "heart")
                            .font(.system(size: 24))
                            .foregroundColor(dataStore.isFavorite(id: exercise.id) ? HooplabTheme.orangePrimary : HooplabTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // 1. Hero Demonstration Card
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(
                                    LinearGradient(
                                        colors: [exercise.categoryColor.opacity(0.18), exercise.categoryColor.opacity(0.06)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 190)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(HooplabTheme.cardBorder, lineWidth: 1)
                                )

                            // Watermark Icon
                            HStack {
                                Spacer()
                                Image(systemName: exercise.sfSymbol)
                                    .font(.system(size: 80, weight: .ultraLight))
                                    .foregroundColor(exercise.categoryColor.opacity(0.35))
                                    .padding(.trailing, 16)
                            }

                            // Bottom Badge
                            Text(dataStore.isEnglish ? "TRAINING DEMO" : "ТРЕНИРОВОЧНАЯ ДЕМОНСТРАЦИЯ")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(HooplabTheme.textPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .padding(14)
                        }

                        // 2. Title & Chips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Text(exercise.localizedCategory(isEn: dataStore.isEnglish).uppercased())
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundColor(exercise.categoryColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(exercise.categoryColor.opacity(0.15))
                                    .cornerRadius(6)

                                Text("⭐ " + exercise.localizedLevel(isEn: dataStore.isEnglish).uppercased())
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundColor(HooplabTheme.levelColor(exercise.levelRu))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(HooplabTheme.levelBgColor(exercise.levelRu))
                                    .cornerRadius(6)
                            }

                            Text(exercise.localizedTitle(isEn: dataStore.isEnglish))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(HooplabTheme.textPrimary)
                        }

                        // 3. CTA "Начать тренировку" Button
                        Button(action: {
                            SoundAndHaptics.shared.mediumTap()
                            showingWorkoutTimer = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text(dataStore.isEnglish ? "Start Workout" : "Начать тренировку")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(HooplabTheme.orangePrimary)
                            .cornerRadius(16)
                            .shadow(color: HooplabTheme.orangePrimary.opacity(0.35), radius: 8, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)

                        // 4. Three Metrics Cards (Sets, Reps, Rest)
                        HStack(spacing: 10) {
                            metricBox(
                                label: dataStore.isEnglish ? "SETS" : "ПОДХОДЫ",
                                val: "\(exercise.sets)",
                                icon: "arrow.triangle.2.circlepath"
                            )
                            metricBox(
                                label: dataStore.isEnglish ? "REPS" : "ПОВТОРЫ",
                                val: exercise.reps,
                                icon: "repeat"
                            )
                            metricBox(
                                label: dataStore.isEnglish ? "REST" : "ОТДЫХ",
                                val: exercise.localizedRest(isEn: dataStore.isEnglish),
                                icon: "timer"
                            )
                        }

                        // 5. Description Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text(dataStore.isEnglish ? "Overview" : "Описание")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(HooplabTheme.textPrimary)

                            Text(exercise.localizedDescription(isEn: dataStore.isEnglish))
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(HooplabTheme.textSecondary)
                                .lineSpacing(4)
                        }
                        .hooplabCard(padding: 16, cornerRadius: 18)

                        // 6. Execution Steps
                        VStack(alignment: .leading, spacing: 12) {
                            Text(dataStore.isEnglish ? "Technique & Steps" : "Техника выполнения")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(HooplabTheme.textPrimary)

                            ForEach(Array(exercise.localizedInstructions(isEn: dataStore.isEnglish).enumerated()), id: \.offset) { idx, step in
                                HStack(alignment: .top, spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(HooplabTheme.orangeSoft)
                                            .frame(width: 24, height: 24)
                                        Text("\(idx + 1)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(HooplabTheme.orangePrimary)
                                    }

                                    Text(step)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(HooplabTheme.textPrimary)
                                        .lineSpacing(3)
                                }
                            }
                        }
                        .hooplabCard(padding: 16, cornerRadius: 18)

                        // 7. Coach Tip
                        if let tip = exercise.localizedTip(isEn: dataStore.isEnglish), !tip.isEmpty {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "D97706"))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(dataStore.isEnglish ? "Coach's Tip" : "Совет тренера")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(HooplabTheme.textPrimary)
                                    Text(tip)
                                        .font(.system(size: 13))
                                        .foregroundColor(HooplabTheme.textSecondary)
                                        .lineSpacing(3)
                                }
                            }
                            .hooplabCard(padding: 14, cornerRadius: 18)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .fullScreenCover(isPresented: $showingWorkoutTimer) {
            WorkoutTimerView(exercise: exercise)
                .environmentObject(dataStore)
        }
    }

    private func metricBox(label: String, val: String, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(label)
                    .font(.system(size: 10, weight: .heavy))
            }
            .foregroundColor(HooplabTheme.textSecondary)

            Text(val)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(HooplabTheme.cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(HooplabTheme.cardBorder, lineWidth: 1)
        )
        .shadow(color: HooplabTheme.shadowColor, radius: 4, x: 0, y: 1)
    }
}
