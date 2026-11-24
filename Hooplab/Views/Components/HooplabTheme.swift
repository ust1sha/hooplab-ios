import SwiftUI

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

public struct HooplabTheme {
    // Exact Android Colors from colors.xml
    public static let bgMain = Color(hex: "F1F5F9")
    public static let bgNav = Color(hex: "E2E8F0")
    public static let surfaceElevated = Color.white

    // Cards & Glass
    public static let cardBg = Color.white.opacity(0.92)
    public static let cardBorder = Color(hex: "CBD5E1")
    public static let shadowColor = Color.black.opacity(0.04)

    // Text
    public static let textPrimary = Color(hex: "0F172A")
    public static let textSecondary = Color(hex: "64748B")
    public static let textHint = Color(hex: "94A3B8")
    public static let textOnAccent = Color.white

    // Accents
    public static let orangePrimary = Color(hex: "EA580C")
    public static let orangeSoft = Color(hex: "EA580C").opacity(0.15)
    public static let greenAccent = Color(hex: "16A34A")
    public static let streakGreen = Color(hex: "16A34A")

    // Aurora Pastels
    public static let aurora1 = Color(hex: "D6E4FB")
    public static let aurora2 = Color(hex: "EBE0FB")
    public static let aurora3 = Color(hex: "FBE6DC")

    // Levels
    public static let beginner = Color(hex: "15803D")
    public static let beginnerBg = Color(hex: "15803D").opacity(0.15)

    public static let intermediate = Color(hex: "D97706")
    public static let intermediateBg = Color(hex: "D97706").opacity(0.15)

    public static let advanced = Color(hex: "9333EA")
    public static let advancedBg = Color(hex: "9333EA").opacity(0.15)

    public static func levelColor(_ level: String) -> Color {
        switch level.lowercased() {
        case "начальный", "beginner": return beginner
        case "средний", "intermediate": return intermediate
        case "продвинутый", "advanced": return advanced
        default: return orangePrimary
        }
    }

    public static func levelColor(_ field: LocalizedField) -> Color {
        levelColor(field.ru)
    }

    public static func levelBgColor(_ level: String) -> Color {
        switch level.lowercased() {
        case "начальный", "beginner": return beginnerBg
        case "средний", "intermediate": return intermediateBg
        case "продвинутый", "advanced": return advancedBg
        default: return orangeSoft
        }
    }

    public static func levelBgColor(_ field: LocalizedField) -> Color {
        levelBgColor(field.ru)
    }

    public static let orangeGradient = LinearGradient(
        colors: [Color(hex: "FB923C"), Color(hex: "EA580C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

public struct HooplabCardModifier: ViewModifier {
    public var padding: CGFloat = 16
    public var cornerRadius: CGFloat = 20

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(HooplabTheme.cardBg)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(HooplabTheme.cardBorder, lineWidth: 1)
            )
            .shadow(color: HooplabTheme.shadowColor, radius: 8, x: 0, y: 3)
    }
}

public struct AuroraBackgroundModifier: ViewModifier {
    public func body(content: Content) -> some View {
        ZStack {
            HooplabTheme.bgMain
                .ignoresSafeArea()

            // Subtle glowing Aurora Blobs matching Android layout
            GeometryReader { geo in
                Circle()
                    .fill(HooplabTheme.aurora1.opacity(0.6))
                    .frame(width: geo.size.width * 0.9, height: geo.size.width * 0.9)
                    .blur(radius: 60)
                    .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.1)

                Circle()
                    .fill(HooplabTheme.aurora3.opacity(0.5))
                    .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                    .blur(radius: 50)
                    .offset(x: geo.size.width * 0.3, y: geo.size.height * 0.15)

                Circle()
                    .fill(HooplabTheme.aurora2.opacity(0.5))
                    .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                    .blur(radius: 50)
                    .offset(x: geo.size.width * 0.1, y: geo.size.height * 0.5)
            }
            .ignoresSafeArea()

            content
        }
    }
}

public extension View {
    func hooplabCard(padding: CGFloat = 16, cornerRadius: CGFloat = 20) -> some View {
        self.modifier(HooplabCardModifier(padding: padding, cornerRadius: cornerRadius))
    }

    func hooplabAurora() -> some View {
        self.modifier(AuroraBackgroundModifier())
    }
}
