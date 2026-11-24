import SwiftUI

public struct ExerciseDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    public let exercise: Exercise

    @State private var showingWorkoutSheet = false

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Banner
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [exercise.categoryColor.opacity(0.3), HooplabTheme.cardDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(exercise.categoryColor.opacity(0.25))
                                    .frame(width: 50, height: 50)
                                Image(systemName: exercise.sfSymbol)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(exercise.categoryColor)
                            }

                            Spacer()

                            Button(action: {
                                SoundAndHaptics.shared.mediumTap()
                                dataStore.toggleFavorite(id: exercise.id)
                            }) {
                                Image(systemName: dataStore.isFavorite(id: exercise.id) ? "heart.fill" : "heart")
                                    .font(.system(size: 22))
                                    .foregroundColor(dataStore.isFavorite(id: exercise.id) ? .red : .white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                            }
                        }

                        HStack(spacing: 8) {
                            Text(exercise.localizedCategory(isEn: dataStore.isEnglish).uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(exercise.categoryColor)
                                .foregroundColor(.white)
                                .cornerRadius(6)

                            Text(exercise.localizedLevel(isEn: dataStore.isEnglish))
                                .font(.system(size: 11, weight: .semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.15))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }

                        Text(exercise.localizedTitle(isEn: dataStore.isEnglish))
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    .padding(20)
                }

                // Start Workout Button
                Button(action: {
                    SoundAndHaptics.shared.mediumTap()
                    showingWorkoutSheet = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                        Text(dataStore.isEnglish ? "Start Workout" : "Начать тренировку")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(HooplabTheme.orangeGradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: HooplabTheme.orangePrimary.opacity(0.4), radius: 10, y: 5)
                }

                // Quick metrics: Sets, Rest
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dataStore.isEnglish ? "SETS & REPS" : "ПОДХОДЫ")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(HooplabTheme.textMuted)
                        Text(exercise.localizedSets(isEn: dataStore.isEnglish))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(HooplabTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .hooplabCard(padding: 14)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(dataStore.isEnglish ? "REST TIME" : "ОТДЫХ")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(HooplabTheme.textMuted)
                        Text(exercise.localizedRest(isEn: dataStore.isEnglish))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(HooplabTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .hooplabCard(padding: 14)
                }

                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text(dataStore.isEnglish ? "Description" : "Описание")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)

                    Text(exercise.localizedDesc(isEn: dataStore.isEnglish))
                        .font(.system(size: 15))
                        .foregroundColor(HooplabTheme.textSecondary)
                        .lineSpacing(4)
                }
                .hooplabCard()

                // Step by Step Execution
                VStack(alignment: .leading, spacing: 14) {
                    Text(dataStore.isEnglish ? "Step-by-step Execution" : "Пошаговая инструкция")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)

                    let steps = exercise.stepsList(isEn: dataStore.isEnglish)
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 14) {
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(HooplabTheme.orangePrimary)
                                .frame(width: 28, height: 28)
                                .background(HooplabTheme.orangePrimary.opacity(0.15))
                                .clipShape(Circle())

                            Text(step)
                                .font(.system(size: 15))
                                .foregroundColor(HooplabTheme.textSecondary)
                                .lineSpacing(3)
                        }
                    }
                }
                .hooplabCard()

                // Muscles involved
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.walk")
                            .foregroundColor(exercise.categoryColor)
                        Text(dataStore.isEnglish ? "Muscles Targeted" : "Задействованные мышцы")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(HooplabTheme.textPrimary)
                    }

                    Text(exercise.localizedMuscles(isEn: dataStore.isEnglish))
                        .font(.system(size: 14))
                        .foregroundColor(HooplabTheme.textSecondary)
                }
                .hooplabCard()

                // Pro Tips & Mistakes
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 20))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(dataStore.isEnglish ? "Coach's Tip" : "Совет тренера")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(HooplabTheme.textPrimary)
                            Text(exercise.localizedTips(isEn: dataStore.isEnglish))
                                .font(.system(size: 14))
                                .foregroundColor(HooplabTheme.textSecondary)
                        }
                    }

                    Divider().background(HooplabTheme.borderDark)

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 20))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(dataStore.isEnglish ? "Common Mistakes" : "Частые ошибки")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(HooplabTheme.textPrimary)

                            let mistakes = exercise.mistakesList(isEn: dataStore.isEnglish)
                            ForEach(mistakes, id: \.self) { m in
                                Text("• \(m)")
                                    .font(.system(size: 14))
                                    .foregroundColor(HooplabTheme.textSecondary)
                            }
                        }
                    }
                }
                .hooplabCard()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(HooplabTheme.bgDark.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingWorkoutSheet) {
            WorkoutTimerView(exercise: exercise)
                .environmentObject(dataStore)
        }
    }
}
