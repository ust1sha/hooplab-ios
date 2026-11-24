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
                HooplabTheme.bgDark.ignoresSafeArea()

                if favoriteExercises.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash.fill")
                            .font(.system(size: 54))
                            .foregroundColor(HooplabTheme.textMuted)

                        Text(dataStore.isEnglish ? "No Favorites Yet" : "В избранном пока пусто")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Text(dataStore.isEnglish ? "Save your favorite exercises to quickly access them anytime." : "Добавляйте упражнения в избранное сердечком, чтобы быстро начинать тренировку.")
                            .font(.system(size: 14))
                            .foregroundColor(HooplabTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            ForEach(favoriteExercises) { exercise in
                                ExerciseCardView(exercise: exercise) {
                                    selectedExercise = exercise
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle(dataStore.isEnglish ? "Favorites" : "Избранное")
            .navigationDestination(item: $selectedExercise) { ex in
                ExerciseDetailView(exercise: ex)
                    .environmentObject(dataStore)
            }
        }
    }
}
