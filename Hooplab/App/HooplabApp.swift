import SwiftUI

@main
struct HooplabApp: App {
    @StateObject private var dataStore = DataStore()

    var body: some Scene {
        WindowGroup {
            ZStack {
                switch dataStore.route {
                case .splash:
                    SplashView()
                        .transition(.opacity)
                case .onboarding:
                    OnboardingView()
                        .transition(.opacity)
                case .auth:
                    AuthView()
                        .transition(.opacity)
                case .main:
                    MainTabView()
                        .transition(.opacity)
                }

                // Floating Toast Banner (matches Android Toast behavior)
                if let toast = dataStore.toastMessage {
                    VStack {
                        Spacer()
                        Text(toast)
                            .font(.geist(14, weight: .semibold))
                            .foregroundColor(HooplabTheme.textPrimary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(HooplabTheme.glassFill)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(HooplabTheme.glassStroke, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 10, y: 4)
                            .padding(.horizontal, 24)
                            .padding(.bottom, dataStore.route == .main ? 92 : 36)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .allowsHitTesting(false)
                    .zIndex(999)
                }
            }
            .environmentObject(dataStore)
            .preferredColorScheme(dataStore.isDarkTheme ? .dark : .light)
        }
    }
}
