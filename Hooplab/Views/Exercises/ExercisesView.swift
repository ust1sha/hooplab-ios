import SwiftUI

// MARK: - Exercises Category Grid Screen (1:1 Android activity_exercises.xml)
public struct ExercisesView: View {
    @EnvironmentObject var dataStore: DataStore

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public init() {}

    public var body: some View {
        let isEn = dataStore.isEnglish
        let categories = ExerciseCategory.buildItems(from: dataStore.exercises)

        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isEn ? "Drills" : "Упражнения")
                        .font(.geist(HooplabDimens.textDisplay, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)

                    Text(isEn ? "Choose a category" : "Выберите категорию")
                        .font(.geist(HooplabDimens.textBody, weight: .regular))
                        .foregroundColor(HooplabTheme.textSecondary)
                }
                .padding(.top, 6)

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(categories) { item in
                        NavigationLink {
                            CategoryExercisesView(category: item)
                        } label: {
                            CategoryGridCardView(item: item, isEn: isEn)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, HooplabDimens.screenPaddingH)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .hooplabAurora()
    }
}

// MARK: - 1:1 Android item_category_card.xml
private struct CategoryGridCardView: View {
    let item: CategoryCardItem
    let isEn: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 176)
                .clipped()

            LinearGradient(
                colors: [
                    Color.clear,
                    HooplabTheme.scrimEnd.opacity(0.65),
                    HooplabTheme.scrimEnd
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.localizedName(isEn: isEn))
                    .font(.geist(16, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(item.localizedCountText(isEn: isEn))
                    .font(.geist(12, weight: .medium))
                    .foregroundColor(HooplabTheme.textSecondary)
            }
            .padding(14)
        }
        .frame(height: 176)
        .background(HooplabTheme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: HooplabDimens.radiusCard)
                .stroke(HooplabTheme.glassStroke, lineWidth: 1)
        )
    }
}

// MARK: - Filtered Category Exercises List (1:1 Android activity_category_exercises.xml)
public struct CategoryExercisesView: View {
    @EnvironmentObject var dataStore: DataStore
    public let category: CategoryCardItem

    @State private var selectedLevel: ExerciseLevel = .all
    @State private var searchText: String = ""

    public init(category: CategoryCardItem) {
        self.category = category
    }

    public var body: some View {
        let isEn = dataStore.isEnglish
        let filtered = filteredExercises(isEn: isEn)

        VStack(spacing: 0) {
            HooplabTopBar(
                title: category.localizedName(isEn: isEn),
                subtitle: category.localizedCountText(isEn: isEn)
            )

            // Search + Level Filter Chips
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(HooplabTheme.textSecondary)
                    TextField(isEn ? "Search drills..." : "Поиск упражнений...", text: $searchText)
                        .font(.geist(15, weight: .regular))
                        .foregroundColor(HooplabTheme.textPrimary)
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(HooplabTheme.textHint)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(HooplabTheme.bgInput)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(HooplabTheme.glassStroke, lineWidth: 1)
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ExerciseLevel.allCases) { level in
                            let isSelected = (selectedLevel == level)
                            Button {
                                SoundAndHaptics.shared.vibrateClick()
                                selectedLevel = level
                            } label: {
                                Text(level.localized(isEn: isEn))
                                    .font(.geist(13, weight: .semibold))
                                    .foregroundColor(isSelected ? .white : HooplabTheme.textPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? HooplabTheme.primary : HooplabTheme.glassFill)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(
                                            isSelected ? HooplabTheme.primary : HooplabTheme.glassStroke,
                                            lineWidth: 1
                                        )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, HooplabDimens.screenPaddingH)
            .padding(.bottom, 12)

            if filtered.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "basketball")
                        .font(.system(size: 40))
                        .foregroundColor(HooplabTheme.textHint)
                    Text(isEn ? "No drills match the filter" : "Упражнения не найдены")
                        .font(.geist(16, weight: .semibold))
                        .foregroundColor(HooplabTheme.textSecondary)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(filtered) { exercise in
                            NavigationLink {
                                ExerciseDetailView(exercise: exercise)
                            } label: {
                                ExerciseListCardView(
                                    exercise: exercise,
                                    isEn: isEn,
                                    isFavorite: dataStore.isFavorite(id: exercise.id)
                                ) {
                                    dataStore.toggleFavorite(id: exercise.id)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, HooplabDimens.screenPaddingH)
                    .padding(.top, 4)
                    .padding(.bottom, 28)
                }
            }
        }
        .hooplabAurora()
        .toolbar(.hidden, for: .navigationBar)
        .enableSwipeBack()
    }

    private func filteredExercises(isEn: Bool) -> [Exercise] {
        dataStore.exercises.filter { ex in
            guard ex.category.ru == category.ruName else { return false }

            let lvlMatches: Bool = {
                switch selectedLevel {
                case .all:
                    return true
                case .beginner:
                    return ex.level.ru.lowercased().contains("нач") || ex.level.en.lowercased().contains("begin")
                case .intermediate:
                    return ex.level.ru.lowercased().contains("сред") || ex.level.en.lowercased().contains("inter")
                case .advanced:
                    return ex.level.ru.lowercased().contains("прод") || ex.level.en.lowercased().contains("advanc")
                }
            }()

            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let searchMatches = query.isEmpty ||
                ex.localizedTitle(isEn: isEn).lowercased().contains(query) ||
                ex.localizedDesc(isEn: isEn).lowercased().contains(query)

            return lvlMatches && searchMatches
        }
    }
}
