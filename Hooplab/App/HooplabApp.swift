import SwiftUI

@main
struct HooplabApp: App {
    @StateObject private var dataStore = DataStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(dataStore)
                .preferredColorScheme(.light)
        }
    }
}
