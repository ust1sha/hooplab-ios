import SwiftUI

public struct MainTabView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedTab: Int = 0

    public var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(dataStore.isEnglish ? "Home" : "Главная", systemImage: "house.fill")
                }
                .tag(0)

            ExercisesView()
                .tabItem {
                    Label(dataStore.isEnglish ? "Workouts" : "Тренировки", systemImage: "figure.basketball")
                }
                .tag(1)

            FavoritesView()
                .tabItem {
                    Label(dataStore.isEnglish ? "Favorites" : "Избранное", systemImage: "heart.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label(dataStore.isEnglish ? "Profile" : "Профиль", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(HooplabTheme.orangePrimary)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(Color.white.opacity(0.95))

            // Unselected items tint #64748B
            let normalColor = UIColor(Color(hex: "64748B"))
            let selectedColor = UIColor(Color(hex: "EA580C"))

            appearance.stackedLayoutAppearance.normal.iconColor = normalColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]

            appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
