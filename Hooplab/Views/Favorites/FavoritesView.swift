import SwiftUI

// MARK: - Favorites Screen (1:1 Android activity_favorites.xml)
public struct FavoritesView: View {
    @EnvironmentObject var dataStore: DataStore

    public init() {}

    public var body: some View {
        let isEn = dataStore.isEnglish
        let saved = dataStore.exercises.filter { dataStore.favoriteIds.contains($0.id) }

        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(isEn ? "Favorites" : "Избранное")
                    .font(.geist(HooplabDimens.textDisplay, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)

                Text(
                    isEn
                    ? "\(saved.count) saved drills"
                    : "Сохранено упражнений: \(saved.count)"
                )
                .font(.geist(HooplabDimens.textBody, weight: .regular))
                .foregroundColor(HooplabTheme.textSecondary)
            }
            .padding(.horizontal, HooplabDimens.screenPaddingH)
            .padding(.top, 16)
            .padding(.bottom, 14)

            if saved.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(HooplabTheme.fireBg)
                            .frame(width: 84, height: 84)
                        Image(systemName: "star.fill")
                            .font(.system(size: 36))
                            .foregroundColor(HooplabTheme.primary)
                    }

                    Text(
                        isEn
                        ? "You don't have any favorite exercises yet.\nAdd your favorite drills to easily come back to them!"
                        : "У вас пока нет избранных упражнений.\nДобавляйте любимые упражнения, чтобы быстро к ним возвращаться!"
                    )
                    .font(.geist(15, weight: .regular))
                    .foregroundColor(HooplabTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                    Button {
                        SoundAndHaptics.shared.vibrateClick()
                        dataStore.selectedTab = .exercises
                    } label: {
                        Text(isEn ? "Browse Drills" : "Перейти к упражнениям")
                            .font(.geist(15, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .frame(height: 48)
                            .background(HooplabTheme.primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(saved) { exercise in
                            NavigationLink {
                                ExerciseDetailView(exercise: exercise)
                            } label: {
                                ExerciseListCardView(
                                    exercise: exercise,
                                    isEn: isEn,
                                    isFavorite: true
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        dataStore.toggleFavorite(id: exercise.id)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, HooplabDimens.screenPaddingH)
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
            }
        }
        .hooplabAurora()
    }
}
