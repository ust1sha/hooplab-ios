import SwiftUI

public struct HooplabTheme {
    public static let orangePrimary = Color(red: 1.0, green: 0.42, blue: 0.0) // #FF6B00
    public static let orangeGlow = Color(red: 1.0, green: 0.55, blue: 0.2)
    public static let orangeDark = Color(red: 0.8, green: 0.28, blue: 0.0)

    public static let bgDark = Color(red: 0.07, green: 0.07, blue: 0.08) // #121214
    public static let cardDark = Color(red: 0.12, green: 0.12, blue: 0.14) // #1E1E24
    public static let surfaceDark = Color(red: 0.16, green: 0.16, blue: 0.18) // #29292E
    public static let borderDark = Color.white.opacity(0.08)

    public static let textPrimary = Color.white
    public static let textSecondary = Color.white.opacity(0.65)
    public static let textMuted = Color.white.opacity(0.4)

    public static let orangeGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.48, blue: 0.1), Color(red: 0.95, green: 0.25, blue: 0.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let courtGradient = LinearGradient(
        colors: [Color(red: 0.16, green: 0.16, blue: 0.2), Color(red: 0.09, green: 0.09, blue: 0.11)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

public struct HooplabCardModifier: ViewModifier {
    public var padding: CGFloat = 16
    public var cornerRadius: CGFloat = 16

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(HooplabTheme.cardDark)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(HooplabTheme.borderDark, lineWidth: 1)
            )
    }
}

public extension View {
    func hooplabCard(padding: CGFloat = 16, cornerRadius: CGFloat = 16) -> some View {
        self.modifier(HooplabCardModifier(padding: padding, cornerRadius: cornerRadius))
    }
}
