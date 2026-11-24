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

            CourtsView()
                .tabItem {
                    Label(dataStore.isEnglish ? "Courts" : "Площадки", systemImage: "map.fill")
                }
                .tag(2)

            FavoritesView()
                .tabItem {
                    Label(dataStore.isEnglish ? "Favorites" : "Избранное", systemImage: "heart.fill")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label(dataStore.isEnglish ? "Profile" : "Профиль", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(HooplabTheme.orangePrimary)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(HooplabTheme.cardDark)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
