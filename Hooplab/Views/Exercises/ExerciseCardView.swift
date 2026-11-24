import SwiftUI

public struct ExerciseCardView: View {
    @EnvironmentObject var dataStore: DataStore
    public let exercise: Exercise
    public var onSelect: () -> Void

    public var body: some View {
        Button(action: {
            SoundAndHaptics.shared.lightTap()
            onSelect()
        }) {
            VStack(alignment: .leading, spacing: 10) {
                // Top row: category icon and favorite heart
                HStack(alignment: .top) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(exercise.categoryColor.opacity(0.15))
                            .frame(width: 40, height: 40)

                        Image(systemName: exercise.sfSymbol)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(exercise.categoryColor)
                    }

                    Spacer()

                    Button(action: {
                        SoundAndHaptics.shared.mediumTap()
                        dataStore.toggleFavorite(id: exercise.id)
                    }) {
                        Image(systemName: dataStore.isFavorite(id: exercise.id) ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(dataStore.isFavorite(id: exercise.id) ? HooplabTheme.orangePrimary : Color(hex: "CBD2DA"))
                            .padding(6)
                    }
                    .buttonStyle(.plain)
                }

                // Title and category
                VStack(alignment: .leading, spacing: 3) {
                    Text(exercise.localizedTitle(isEn: dataStore.isEnglish))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(exercise.localizedCategory(isEn: dataStore.isEnglish))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(exercise.categoryColor)
                }

                // Level chip and duration/reps
                HStack(spacing: 6) {
                    Text(exercise.localizedLevel(isEn: dataStore.isEnglish))
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(HooplabTheme.levelBgColor(exercise.level))
                        .foregroundColor(HooplabTheme.levelColor(exercise.level))
                        .cornerRadius(6)

                    Spacer()

                    HStack(spacing: 3) {
                        Image(systemName: "timer")
                            .font(.system(size: 11))
                        Text(exercise.localizedRest(isEn: dataStore.isEnglish))
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(HooplabTheme.textSecondary)
                }
            }
            .hooplabCard(padding: 14, cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}

// Compact card for Horizontal Carousels on Home screen (matches item_exercise_card.xml)
public struct ExerciseCarouselCardView: View {
    @EnvironmentObject var dataStore: DataStore
    public let exercise: Exercise
    public var onSelect: () -> Void

    public var body: some View {
        Button(action: {
            SoundAndHaptics.shared.lightTap()
            onSelect()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Top photo / icon banner with vertical difficulty strip
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [exercise.categoryColor.opacity(0.18), exercise.categoryColor.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 92)

                    // Vertical neon indicator capsule
                    RoundedRectangle(cornerRadius: 2)
                        .fill(HooplabTheme.levelColor(exercise.level))
                        .frame(width: 4, height: 26)
                        .padding(.leading, 8)
                        .padding(.top, 8)

                    // Category icon in center
                    Image(systemName: exercise.sfSymbol)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(exercise.categoryColor)
                        .frame(maxWidth: .infinity, maxHeight: 92)

                    // Favorite button in top right
                    HStack {
                        Spacer()
                        Button(action: {
                            SoundAndHaptics.shared.mediumTap()
                            dataStore.toggleFavorite(id: exercise.id)
                        }) {
                            Image(systemName: dataStore.isFavorite(id: exercise.id) ? "heart.fill" : "heart")
                                .font(.system(size: 15))
                                .foregroundColor(dataStore.isFavorite(id: exercise.id) ? HooplabTheme.orangePrimary : Color(hex: "94A3B8"))
                                .padding(6)
                                .background(Color.white.opacity(0.85))
                                .clipShape(Circle())
                        }
                        .padding(6)
                    }
                }

                // Bottom metadata
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(exercise.localizedLevel(isEn: dataStore.isEnglish).uppercased())
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(HooplabTheme.levelColor(exercise.level))

                        Spacer()

                        Text("⏱ \(exercise.reps)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(HooplabTheme.textSecondary)
                    }

                    Text(exercise.localizedTitle(isEn: dataStore.isEnglish))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)
                        .lineLimit(2)
                        .frame(height: 34, alignment: .topLeading)
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 10)
            }
            .frame(width: 160, height: 172)
            .background(HooplabTheme.cardBg)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(HooplabTheme.cardBorder, lineWidth: 1)
            )
            .shadow(color: HooplabTheme.shadowColor, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
