import SwiftUI

public struct ExercisesView: View {
    @EnvironmentObject var dataStore: DataStore

    @State private var activeCategory: ExerciseCategory? = nil
    @State private var searchText = ""
    @State private var selectedLevel: ExerciseLevel = .all
    @State private var selectedExercise: Exercise? = nil

    private var availableCategories: [ExerciseCategory] {
        [.shots, .dribbling, .defense, .technique, .physical, .tactics]
    }

    private var filteredExercises: [Exercise] {
        dataStore.exercises.filter { ex in
            let matchCat = activeCategory == nil || activeCategory?.matches(categoryString: ex.categoryRu) == true || activeCategory?.matches(categoryString: ex.categoryEn) == true
            let matchLvl = selectedLevel.matches(levelString: ex.level)

            if !searchText.isEmpty {
                let q = searchText.lowercased()
                let titleMatch = ex.titleRu.lowercased().contains(q) || ex.titleEn.lowercased().contains(q)
                let descMatch = ex.descriptionRu.lowercased().contains(q) || ex.descriptionEn.lowercased().contains(q)
                return matchCat && matchLvl && (titleMatch || descMatch)
            }
            return matchCat && matchLvl
        }
    }

    private func countForCategory(_ cat: ExerciseCategory) -> Int {
        dataStore.exercises.filter { cat.matches(categoryString: $0.categoryRu) || cat.matches(categoryString: $0.categoryEn) }.count
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .hooplabAurora()

                if let currentCategory = activeCategory {
                    // Category Exercises List (matches activity_category_exercises.xml)
                    categoryDetailView(category: currentCategory)
                } else {
                    // Categories Hub (matches activity_exercises.xml)
                    categoriesHubView
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

    // MARK: - Categories Hub View (activity_exercises.xml)
    private var categoriesHubView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 6) {
                // Main Title
                Text(dataStore.isEnglish ? "Exercises" : "Тренировки")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)
                    .padding(.top, 16)

                // Subtitle
                Text(dataStore.isEnglish ? "Select a category to train" : "Выберите категорию для тренировки")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(HooplabTheme.textSecondary)
                    .padding(.bottom, 12)

                // Search Bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(HooplabTheme.textHint)
                    TextField(dataStore.isEnglish ? "Search exercises..." : "Поиск упражнений...", text: $searchText)
                        .foregroundColor(HooplabTheme.textPrimary)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(HooplabTheme.textHint)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color.white.opacity(0.95))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(HooplabTheme.cardBorder, lineWidth: 1)
                )
                .shadow(color: HooplabTheme.shadowColor, radius: 4, x: 0, y: 1)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

                if !searchText.isEmpty {
                    // Search results view directly
                    VStack(alignment: .leading, spacing: 12) {
                        Text(dataStore.isEnglish ? "Found \(filteredExercises.count) exercises" : "Найдено: \(filteredExercises.count) упр.")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(HooplabTheme.textSecondary)
                            .padding(.horizontal, 16)

                        ForEach(filteredExercises) { ex in
                            ExerciseCardView(exercise: ex) {
                                selectedExercise = ex
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 32)
                } else {
                    // 2-column Grid of Categories (matches item_category_card.xml)
                    let columns = [
                        GridItem(.flexible(), spacing: 14),
                        GridItem(.flexible(), spacing: 14)
                    ]

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(availableCategories) { cat in
                            categoryCard(cat)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private func categoryCard(_ cat: ExerciseCategory) -> some View {
        Button(action: {
            SoundAndHaptics.shared.lightTap()
            activeCategory = cat
        }) {
            ZStack(alignment: .bottomLeading) {
                // Background subtle tinted surface
                RoundedRectangle(cornerRadius: 20)
                    .fill(HooplabTheme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(HooplabTheme.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: HooplabTheme.shadowColor, radius: 6, x: 0, y: 2)

                // Large watermark symbol in top right
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: cat.sfSymbol)
                            .font(.system(size: 54, weight: .ultraLight))
                            .foregroundColor(HooplabTheme.orangePrimary.opacity(0.18))
                            .offset(x: 4, y: 4)
                    }
                    Spacer()
                }

                // Text content at bottom
                VStack(alignment: .leading, spacing: 4) {
                    Text(cat.localized(isEn: dataStore.isEnglish))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)

                    Text(dataStore.isEnglish ? "\(countForCategory(cat)) exercises" : "\(countForCategory(cat)) упражнений")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(HooplabTheme.orangePrimary)
                }
                .padding(14)
            }
            .frame(height: 128)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Category Exercises List View (activity_category_exercises.xml)
    private func categoryDetailView(category: ExerciseCategory) -> some View {
        VStack(spacing: 0) {
            // Header with Back button
            HStack {
                Button(action: {
                    SoundAndHaptics.shared.lightTap()
                    activeCategory = nil
                    selectedLevel = .all
                    searchText = ""
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                        Text(dataStore.isEnglish ? "Categories" : "Категории")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(HooplabTheme.orangePrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(HooplabTheme.orangeSoft)
                    .cornerRadius(12)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(category.localized(isEn: dataStore.isEnglish))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)
                    Text(dataStore.isEnglish ? "Exercises" : "Упражнения")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(HooplabTheme.textSecondary)
                }

                Spacer()

                // Balance placeholder
                Circle()
                    .fill(Color.clear)
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            // Difficulty Filter Chips
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
                                .padding(.vertical, 7)
                                .background(selectedLevel == lvl ? HooplabTheme.orangePrimary : HooplabTheme.cardBg)
                                .foregroundColor(selectedLevel == lvl ? .white : HooplabTheme.textSecondary)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedLevel == lvl ? Color.clear : HooplabTheme.cardBorder, lineWidth: 1)
                                )
                                .shadow(color: HooplabTheme.shadowColor, radius: 3, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }

            // Exercise Cards List
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(filteredExercises) { ex in
                        ExerciseCardView(exercise: ex) {
                            selectedExercise = ex
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
