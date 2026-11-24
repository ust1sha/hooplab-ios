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
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(exercise.categoryColor.opacity(0.2))
                            .frame(width: 44, height: 44)

                        Image(systemName: exercise.sfSymbol)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(exercise.categoryColor)
                    }

                    Spacer()

                    Button(action: {
                        SoundAndHaptics.shared.mediumTap()
                        dataStore.toggleFavorite(id: exercise.id)
                    }) {
                        Image(systemName: dataStore.isFavorite(id: exercise.id) ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(dataStore.isFavorite(id: exercise.id) ? .red : HooplabTheme.textMuted)
                            .padding(6)
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.localizedTitle(isEn: dataStore.isEnglish))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(exercise.localizedCategory(isEn: dataStore.isEnglish))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(exercise.categoryColor)
                }

                HStack(spacing: 8) {
                    Text(exercise.localizedLevel(isEn: dataStore.isEnglish))
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(HooplabTheme.textSecondary)
                        .cornerRadius(6)

                    Spacer()

                    HStack(spacing: 3) {
                        Image(systemName: "timer")
                            .font(.system(size: 11))
                        Text(exercise.localizedRest(isEn: dataStore.isEnglish))
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(HooplabTheme.textMuted)
                }
            }
            .hooplabCard(padding: 14, cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }
}
