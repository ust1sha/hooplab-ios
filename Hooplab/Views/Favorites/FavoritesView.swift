import SwiftUI

public struct FavoritesView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedExercise: Exercise? = nil

    private var favoriteExercises: [Exercise] {
        dataStore.exercises.filter { dataStore.isFavorite(id: $0.id) }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .hooplabAurora()

                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dataStore.isEnglish ? "Favorites" : "Избранное")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(HooplabTheme.textPrimary)
                        Text(dataStore.isEnglish ? "Saved exercises for quick access" : "Сохраненные упражнения для быстрых тренировок")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(HooplabTheme.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 12)

                    if favoriteExercises.isEmpty {
                        Spacer()
                        VStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(HooplabTheme.orangeSoft)
                                    .frame(width: 80, height: 80)

                                Image(systemName: "heart.slash.fill")
                                    .font(.system(size: 38))
                                    .foregroundColor(HooplabTheme.orangePrimary)
                            }

                            Text(dataStore.isEnglish ? "No Favorites Yet" : "В избранном пока пусто")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(HooplabTheme.textPrimary)

                            Text(dataStore.isEnglish ? "Tap the heart icon on any exercise card to save it here for fast training." : "Нажимайте на сердечко у карточки любого упражнения, чтобы добавить его сюда.")
                                .font(.system(size: 14))
                                .foregroundColor(HooplabTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 36)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(favoriteExercises) { exercise in
                                    ExerciseCardView(exercise: exercise) {
                                        selectedExercise = exercise
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedExercise) { ex in
                NavigationStack {
                    ExerciseDetailView(exercise: ex)
                        .environmentObject(dataStore)
                }
            }
        }
    }
}
