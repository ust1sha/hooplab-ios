import SwiftUI
import UIKit

public struct MainTabView: View {
    @EnvironmentObject var dataStore: DataStore

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    switch dataStore.selectedTab {
                    case .home:
                        HomeView()
                    case .exercises:
                        ExercisesView()
                    case .favorites:
                        FavoritesView()
                    case .profile:
                        ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    HooplabBottomNav(
                        selectedTab: $dataStore.selectedTab,
                        isEn: dataStore.isEnglish
                    )
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(HooplabTheme.primary)
    }
}

// MARK: - Android 1:1 Glass Bottom Navigation Bar (matches item_bottom_nav.xml & bg_nav_glass.xml)
public struct HooplabBottomNav: View {
    @Binding var selectedTab: MainTab
    let isEn: Bool

    public var body: some View {
        HStack(spacing: 0) {
            navItem(
                tab: .home,
                icon: "house",
                activeIcon: "house.fill",
                title: isEn ? "Home" : "Главная"
            )
            navItem(
                tab: .exercises,
                icon: "basketball",
                activeIcon: "basketball.fill",
                title: isEn ? "Drills" : "Упражнения"
            )
            navItem(
                tab: .favorites,
                icon: "star",
                activeIcon: "star.fill",
                title: isEn ? "Saved" : "Избранное"
            )
            navItem(
                tab: .profile,
                icon: "person",
                activeIcon: "person.fill",
                title: isEn ? "Profile" : "Профиль"
            )
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: HooplabDimens.radiusSheet,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: HooplabDimens.radiusSheet
            )
            .fill(HooplabTheme.bgNav.opacity(0.92))
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: HooplabDimens.radiusSheet,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: HooplabDimens.radiusSheet
                )
                .fill(.ultraThinMaterial)
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: HooplabDimens.radiusSheet,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: HooplabDimens.radiusSheet
                )
                .stroke(HooplabTheme.glassStroke.opacity(0.85), lineWidth: 1)
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private func navItem(tab: MainTab, icon: String, activeIcon: String, title: String) -> some View {
        let isSelected = (selectedTab == tab)
        return Button {
            if selectedTab != tab {
                SoundAndHaptics.shared.vibrateClick()
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    selectedTab = tab
                }
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(HooplabTheme.fireBg)
                            .frame(width: 48, height: 28)
                    }
                    Image(systemName: isSelected ? activeIcon : icon)
                        .font(.system(size: 18, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? HooplabTheme.primary : HooplabTheme.textSecondary)
                }
                .frame(height: 28)

                Text(title)
                    .font(.geist(11, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? HooplabTheme.primary : HooplabTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Header & Swipe-Back Support for Child Screens
public struct HooplabTopBar: View {
    @Environment(\.dismiss) private var dismiss
    public let title: String
    public var subtitle: String? = nil
    public var trailingView: AnyView? = nil

    public init(title: String, subtitle: String? = nil, trailingView: AnyView? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.trailingView = trailingView
    }

    public var body: some View {
        HStack(spacing: 12) {
            Button {
                SoundAndHaptics.shared.vibrateClick()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(HooplabTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(HooplabTheme.glassFill)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(HooplabTheme.glassStroke, lineWidth: 1))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.geist(20, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)
                    .lineLimit(1)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.geist(12, weight: .regular))
                        .foregroundColor(HooplabTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let trailingView {
                trailingView
            }
        }
        .padding(.horizontal, HooplabDimens.screenPaddingH)
        .padding(.vertical, 10)
    }
}

// MARK: - Swipe-Back Support for Custom Header Screens (Xcode 15/16 compatible)
private struct InteractivePopGestureEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PopController { PopController() }
    func updateUIViewController(_ uiViewController: PopController, context: Context) {}

    final class PopController: UIViewController, UIGestureRecognizerDelegate {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            navigationController?.interactivePopGestureRecognizer?.delegate = self
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            (navigationController?.viewControllers.count ?? 0) > 1
        }
    }
}

public extension View {
    func enableSwipeBack() -> some View {
        background(InteractivePopGestureEnabler())
    }
}
