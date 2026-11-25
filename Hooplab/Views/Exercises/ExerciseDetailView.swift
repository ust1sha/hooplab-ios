import SwiftUI

// MARK: - Exercise Detail Screen (1:1 Android activity_exercise_detail.xml)
public struct ExerciseDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    public let exercise: Exercise

    public init(exercise: Exercise) {
        self.exercise = exercise
    }

    public var body: some View {
        let isEn = dataStore.isEnglish
        let isFav = dataStore.isFavorite(id: exercise.id)
        let lvlColor = HooplabTheme.levelColor(exercise.level)
        let lvlBg = HooplabTheme.levelBgColor(exercise.level)

        VStack(spacing: 0) {
            HooplabTopBar(
                title: exercise.localizedCategory(isEn: isEn),
                trailingView: AnyView(
                    Button {
                        SoundAndHaptics.shared.vibrateClick()
                        dataStore.toggleFavorite(id: exercise.id)
                    } label: {
                        Image(systemName: isFav ? "star.fill" : "star")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(isFav ? HooplabTheme.favoriteActive : HooplabTheme.textSecondary)
                            .frame(width: 40, height: 40)
                            .background(HooplabTheme.glassFill)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(HooplabTheme.glassStroke, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                )
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Hero Technique Image
                    ZStack(alignment: .bottomLeading) {
                        ExercisePhotoView(exerciseId: exercise.id, categoryRu: exercise.category.ru)
                            .frame(height: 210)
                            .frame(maxWidth: .infinity)
                            .clipped()

                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.65)],
                            startPoint: .center,
                            endPoint: .bottom
                        )

                        HStack(spacing: 6) {
                            Image(systemName: "figure.basketball")
                                .font(.system(size: 12, weight: .bold))
                            Text(isEn ? "Technique Demo" : "Демонстрация техники")
                                .font(.geist(12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.55))
                        .clipShape(Capsule())
                        .padding(14)
                    }
                    .frame(height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusCard))
                    .overlay(
                        RoundedRectangle(cornerRadius: HooplabDimens.radiusCard)
                            .stroke(HooplabTheme.glassStroke, lineWidth: 1)
                    )

                    // Title + Category & Level
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.localizedTitle(isEn: isEn))
                            .font(.geist(24, weight: .bold))
                            .foregroundColor(HooplabTheme.textPrimary)

                        HStack(spacing: 8) {
                            Text(exercise.localizedCategory(isEn: isEn))
                                .font(.geist(13, weight: .semibold))
                                .foregroundColor(HooplabTheme.primary)

                            Circle()
                                .fill(HooplabTheme.textHint)
                                .frame(width: 4, height: 4)

                            HStack(spacing: 4) {
                                Circle()
                                    .fill(lvlColor)
                                    .frame(width: 7, height: 7)
                                Text(exercise.localizedLevel(isEn: isEn))
                                    .font(.geist(12, weight: .bold))
                                    .foregroundColor(lvlColor)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(lvlBg)
                            .clipShape(Capsule())
                        }
                    }

                    // 2-Column Sets & Rest Grid
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(isEn ? "🎯 WORKLOAD" : "🎯 НАГРУЗКА")
                                .font(.geist(11, weight: .bold))
                                .foregroundColor(HooplabTheme.primary)
                            Text(exercise.localizedSets(isEn: isEn))
                                .font(.geist(14, weight: .semibold))
                                .foregroundColor(HooplabTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .hooplabCard(padding: 14)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(isEn ? "⏱️ REST" : "⏱️ ОТДЫХ")
                                .font(.geist(11, weight: .bold))
                                .foregroundColor(HooplabTheme.primary)
                            Text(exercise.localizedRest(isEn: isEn))
                                .font(.geist(14, weight: .semibold))
                                .foregroundColor(HooplabTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .hooplabCard(padding: 14)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isEn ? "Description" : "Описание")
                            .font(.geist(16, weight: .bold))
                            .foregroundColor(HooplabTheme.textPrimary)
                        Text(exercise.localizedDesc(isEn: isEn))
                            .font(.geist(14, weight: .regular))
                            .foregroundColor(HooplabTheme.textSecondary)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .hooplabCard(padding: 16)

                    // Target Muscles
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isEn ? "💪 TARGET MUSCLES" : "💪 ЗАДЕЙСТВОВАННЫЕ МЫШЦЫ")
                            .font(.geist(12, weight: .bold))
                            .foregroundColor(HooplabTheme.primary)
                        Text(exercise.localizedMuscles(isEn: isEn))
                            .font(.geist(14, weight: .medium))
                            .foregroundColor(HooplabTheme.textPrimary)
                            .lineSpacing(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .hooplabCard(padding: 16)

                    // Steps
                    let steps = exercise.stepsList(isEn: isEn)
                    if !steps.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(isEn ? "📋 STEP-BY-STEP TECHNIQUE" : "📋 ПОШАГОВАЯ ТЕХНИКА")
                                .font(.geist(12, weight: .bold))
                                .foregroundColor(HooplabTheme.primary)

                            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.geist(12, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(HooplabTheme.primary)
                                        .clipShape(Circle())

                                    Text(step)
                                        .font(.geist(14, weight: .regular))
                                        .foregroundColor(HooplabTheme.textPrimary)
                                        .lineSpacing(3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .hooplabCard(padding: 16)
                    }

                    // Coach Tips
                    let tips = exercise.localizedTips(isEn: isEn)
                    if !tips.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(isEn ? "💡 COACH'S TIP" : "💡 СОВЕТ ТРЕНЕРА")
                                .font(.geist(12, weight: .bold))
                                .foregroundColor(HooplabTheme.primary)
                            Text(tips)
                                .font(.geist(14, weight: .regular))
                                .foregroundColor(HooplabTheme.textPrimary)
                                .lineSpacing(3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .hooplabCard(padding: 16, strokeColor: HooplabTheme.primary.opacity(0.45))
                    }

                    // Common Mistakes
                    let mistakes = exercise.mistakesList(isEn: isEn)
                    if !mistakes.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(isEn ? "⚠️ COMMON MISTAKES" : "⚠️ ЧАСТЫЕ ОШИБКИ")
                                .font(.geist(12, weight: .bold))
                                .foregroundColor(HooplabTheme.error)

                            ForEach(Array(mistakes.enumerated()), id: \.offset) { _, mistake in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(HooplabTheme.error)
                                        .padding(.top, 2)
                                    Text(mistake)
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
                .padding(.top, 6)
                .padding(.bottom, 20)
            }

            // Bottom Start Workout CTA
            VStack {
                NavigationLink {
                    WorkoutTimerView(exercise: exercise)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(isEn ? "Start Workout" : "Начать тренировку")
                            .font(.geist(16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: HooplabDimens.buttonHeight)
                    .background(HooplabTheme.primary)
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
    }
}
