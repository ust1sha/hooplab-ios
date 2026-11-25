import SwiftUI

// MARK: - Horizontal Carousel Exercise Card (1:1 Android item_exercise_card.xml: 160x174)
public struct ExerciseCarouselCardView: View {
    public let exercise: Exercise
    public let isEn: Bool

    public init(exercise: Exercise, isEn: Bool) {
        self.exercise = exercise
        self.isEn = isEn
    }

    public var body: some View {
        let lvlColor = HooplabTheme.levelColor(exercise.level)

        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                ExercisePhotoView(exerciseId: exercise.id, categoryRu: exercise.category.ru)
                    .frame(width: 160, height: 100)
                    .clipped()

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.32)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: 160, height: 100)

                // Left 4dp level accent strip
                RoundedRectangle(cornerRadius: 2)
                    .fill(lvlColor)
                    .frame(width: 4, height: 76)
                    .padding(.leading, 0)
            }
            .frame(width: 160, height: 100)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: ExerciseMediaHelper.categorySymbol(exercise.category.ru))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(HooplabTheme.primary)

                    Circle()
                        .fill(lvlColor)
                        .frame(width: 6, height: 6)

                    Text(exercise.localizedLevel(isEn: isEn))
                        .font(.geist(10, weight: .bold))
                        .foregroundColor(lvlColor)
                        .lineLimit(1)
                }

                Text(exercise.localizedTitle(isEn: isEn))
                    .font(.geist(13, weight: .semibold))
                    .foregroundColor(HooplabTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: 160, height: 174)
        .background(HooplabTheme.glassFill)
        .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: HooplabDimens.radiusCard)
                .stroke(HooplabTheme.glassStroke, lineWidth: 1)
        )
    }
}

// MARK: - List Exercise Card (1:1 Android item_exercise_list_card.xml)
public struct ExerciseListCardView: View {
    public let exercise: Exercise
    public let isEn: Bool
    public var isFavorite: Bool = false
    public var onToggleFavorite: (() -> Void)? = nil

    public init(
        exercise: Exercise,
        isEn: Bool,
        isFavorite: Bool = false,
        onToggleFavorite: (() -> Void)? = nil
    ) {
        self.exercise = exercise
        self.isEn = isEn
        self.isFavorite = isFavorite
        self.onToggleFavorite = onToggleFavorite
    }

    public var body: some View {
        let lvlColor = HooplabTheme.levelColor(exercise.level)
        let lvlBg = HooplabTheme.levelBgColor(exercise.level)

        HStack(spacing: 12) {
            // Left vertical level indicator
            Capsule()
                .fill(lvlColor)
                .frame(width: 4, height: 64)

            // 92x72 Exercise Photo
            ExercisePhotoView(exerciseId: exercise.id, categoryRu: exercise.category.ru)
                .frame(width: 92, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Image(systemName: ExerciseMediaHelper.categorySymbol(exercise.category.ru))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(HooplabTheme.primary)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(lvlColor)
                            .frame(width: 6, height: 6)
                        Text(exercise.localizedLevel(isEn: isEn))
                            .font(.geist(10, weight: .bold))
                            .foregroundColor(lvlColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(lvlBg)
                    .clipShape(Capsule())
                }

                Text(exercise.localizedTitle(isEn: isEn))
                    .font(.geist(15, weight: .semibold))
                    .foregroundColor(HooplabTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text("\(exercise.localizedCategory(isEn: isEn)) • \(exercise.localizedSets(isEn: isEn))")
                    .font(.geist(12, weight: .regular))
                    .foregroundColor(HooplabTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let onToggleFavorite {
                Button {
                    SoundAndHaptics.shared.vibrateClick()
                    onToggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isFavorite ? HooplabTheme.favoriteActive : HooplabTheme.favoriteInactive)
                        .padding(6)
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(HooplabTheme.textHint)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(HooplabTheme.glassFill)
        .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: HooplabDimens.radiusCard)
                .stroke(HooplabTheme.glassStroke, lineWidth: 1)
        )
    }
}
