import SwiftUI

public struct ExercisesView: View {
    @EnvironmentObject var dataStore: DataStore

    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory = .all
    @State private var selectedLevel: ExerciseLevel = .all
    @State private var selectedExercise: Exercise? = nil

    private var filteredExercises: [Exercise] {
        dataStore.exercises.filter { ex in
            let matchCat = selectedCategory.matches(categoryString: ex.category.en)
            let matchLvl = selectedLevel.matches(levelString: ex.level.en)

            if !searchText.isEmpty {
                let q = searchText.lowercased()
                let titleMatch = ex.title.ru.lowercased().contains(q) || ex.title.en.lowercased().contains(q)
                let descMatch = ex.description.ru.lowercased().contains(q) || ex.description.en.lowercased().contains(q)
                return matchCat && matchLvl && (titleMatch || descMatch)
            }
            return matchCat && matchLvl
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                HooplabTheme.bgDark.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Search field
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(HooplabTheme.textMuted)
                            TextField(dataStore.isEnglish ? "Search exercises..." : "Поиск упражнений...", text: $searchText)
                                .foregroundColor(.white)

                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(HooplabTheme.textMuted)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(HooplabTheme.cardDark)
                        .cornerRadius(14)
                        .padding(.horizontal, 16)

                        // Categories Horizontal Scroll
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(ExerciseCategory.allCases) { cat in
                                    Button(action: {
                                        SoundAndHaptics.shared.lightTap()
                                        selectedCategory = cat
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: cat.sfSymbol)
                                                .font(.system(size: 13))
                                            Text(cat.localized(isEn: dataStore.isEnglish))
                                                .font(.system(size: 14, weight: .semibold))
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(selectedCategory == cat ? HooplabTheme.orangePrimary : HooplabTheme.cardDark)
                                        .foregroundColor(selectedCategory == cat ? .white : HooplabTheme.textSecondary)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(selectedCategory == cat ? Color.clear : HooplabTheme.borderDark, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Difficulty Level Filter Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(ExerciseLevel.allCases) { lvl in
                                    Button(action: {
                                        SoundAndHaptics.shared.lightTap()
                                        selectedLevel = lvl
                                    }) {
                                        Text(lvl.localized(isEn: dataStore.isEnglish))
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedLevel == lvl ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                                            .foregroundColor(selectedLevel == lvl ? .white : HooplabTheme.textMuted)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Count header
                        HStack {
                            Text(dataStore.isEnglish ? "CATALOG (\(filteredExercises.count))" : "КАТАЛОГ (\(filteredExercises.count))")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(HooplabTheme.textMuted)
                                .tracking(1)

                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        // Exercises Grid
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            ForEach(filteredExercises) { exercise in
                                ExerciseCardView(exercise: exercise) {
                                    selectedExercise = exercise
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle(dataStore.isEnglish ? "Workouts" : "Тренировки")
            .navigationDestination(item: $selectedExercise) { ex in
                ExerciseDetailView(exercise: ex)
                    .environmentObject(dataStore)
            }
        }
    }
}
