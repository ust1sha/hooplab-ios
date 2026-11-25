import SwiftUI
import UIKit
import ImageIO

// MARK: - Color Hex & Adaptive Light/Dark Support
public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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

    static func adaptive(light: String, dark: String) -> Color {
        let lightColor = UIColor(Color(hex: light))
        let darkColor = UIColor(Color(hex: dark))
        return Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? darkColor : lightColor
        })
    }
}

// MARK: - Geist Typography
public enum GeistWeight {
    case regular, medium, semibold, bold

    var postScriptName: String {
        switch self {
        case .regular: return "Geist-Regular"
        case .medium: return "Geist-Medium"
        case .semibold: return "Geist-SemiBold"
        case .bold: return "Geist-Bold"
        }
    }
}

public extension Font {
    static func geist(_ size: CGFloat, weight: GeistWeight = .regular) -> Font {
        .custom(weight.postScriptName, size: size)
    }
}

// MARK: - Dimens (matches values/dimens.xml)
public enum HooplabDimens {
    public static let space1: CGFloat = 4
    public static let space2: CGFloat = 8
    public static let space3: CGFloat = 12
    public static let space4: CGFloat = 16
    public static let space5: CGFloat = 20
    public static let space6: CGFloat = 24
    public static let space8: CGFloat = 32
    public static let space12: CGFloat = 48

    public static let screenPaddingH: CGFloat = 20
    public static let cardPadding: CGFloat = 20

    public static let radiusField: CGFloat = 14
    public static let radiusCard: CGFloat = 20
    public static let radiusButton: CGFloat = 14
    public static let radiusChip: CGFloat = 12
    public static let radiusSheet: CGFloat = 28

    public static let buttonHeight: CGFloat = 56
    public static let inputHeight: CGFloat = 56

    public static let textDisplay: CGFloat = 34
    public static let textHeadline: CGFloat = 24
    public static let textH2: CGFloat = 22
    public static let textSection: CGFloat = 20
    public static let textNum: CGFloat = 28
    public static let textTitle: CGFloat = 17
    public static let textBody: CGFloat = 15
    public static let textCaption: CGFloat = 12
    public static let textButton: CGFloat = 15
}

// MARK: - Exact Light/Dark Theme Tokens (matches colors.xml & values-night/colors.xml)
public struct HooplabTheme {
    // Text
    public static let textPrimary = Color.adaptive(light: "0F172A", dark: "F8FAFC")
    public static let textSecondary = Color.adaptive(light: "64748B", dark: "94A3B8")
    public static let textHint = Color.adaptive(light: "94A3B8", dark: "64748B")
    public static let textOnAccent = Color.white

    // Surfaces
    public static let bgMain = Color.adaptive(light: "F1F5F9", dark: "0B0E14")
    public static let surfaceElevated = Color.adaptive(light: "FFFFFF", dark: "121721")
    public static let bgNav = Color.adaptive(light: "E2E8F0", dark: "121721")
    public static let bgInput = Color.adaptive(light: "E2E8F0", dark: "121721")

    // Accents
    public static let primary = Color.adaptive(light: "EA580C", dark: "FF5500")
    public static let orangePrimary = primary
    public static let fireOrange = primary
    public static let fireBg = Color.adaptive(light: "26EA580C", dark: "26FF5500")
    public static let orangeSoft = fireBg
    public static let accentSecondary = Color.adaptive(light: "16A34A", dark: "A3FF12")
    public static let greenAccent = accentSecondary
    public static let streakDayCompleted = accentSecondary

    // Borders & Glass
    public static let glassStroke = Color.adaptive(light: "CBD5E1", dark: "2E3A4F")
    public static let cardBorder = glassStroke
    public static let divider = glassStroke
    public static let glassFill = Color.adaptive(light: "E6FFFFFF", dark: "BF1A212E")
    public static let cardBg = glassFill
    public static let error = Color.adaptive(light: "E5484D", dark: "FF6369")

    // Aurora Blobs
    public static let auroraTop = Color.adaptive(light: "EAEFF5", dark: "0E121A")
    public static let aurora1 = Color.adaptive(light: "D6E4FB", dark: "1A2338")
    public static let aurora2 = Color.adaptive(light: "EBE0FB", dark: "251838")
    public static let aurora3 = Color.adaptive(light: "FBE6DC", dark: "331524")

    // Levels
    public static let levelBeginner = Color.adaptive(light: "15803D", dark: "9BFF6A")
    public static let levelBeginnerBg = Color.adaptive(light: "2615803D", dark: "269BFF6A")
    public static let levelIntermediate = Color.adaptive(light: "D97706", dark: "FF9F43")
    public static let levelIntermediateBg = Color.adaptive(light: "26D97706", dark: "26FF9F43")
    public static let levelAdvanced = Color.adaptive(light: "9333EA", dark: "D946EF")
    public static let levelAdvancedBg = Color.adaptive(light: "269333EA", dark: "26D946EF")

    // Streak & Stats
    public static let streakDayPending = Color.adaptive(light: "E2E8F0", dark: "121721")
    public static let streakDayTextDone = Color.adaptive(light: "FFFFFF", dark: "0B0E14")
    public static let streakDayTextPending = Color.adaptive(light: "64748B", dark: "94A3B8")
    public static let favoriteActive = primary
    public static let favoriteInactive = Color.adaptive(light: "CBD2DA", dark: "3A4049")
    public static let nbaSkillTrack = Color.adaptive(light: "E2E8F0", dark: "121721")

    // Category scrim
    public static let scrimEnd = Color.adaptive(light: "E6FFFFFF", dark: "E60B0E14")

    public static func levelColor(_ level: String) -> Color {
        let l = level.lowercased()
        if l.contains("нач") || l.contains("begin") { return levelBeginner }
        if l.contains("прод") || l.contains("advanc") || l.contains("hard") { return levelAdvanced }
        return levelIntermediate
    }

    public static func levelColor(_ field: LocalizedField) -> Color {
        levelColor(field.ru)
    }

    public static func levelBgColor(_ level: String) -> Color {
        let l = level.lowercased()
        if l.contains("нач") || l.contains("begin") { return levelBeginnerBg }
        if l.contains("прод") || l.contains("advanc") || l.contains("hard") { return levelAdvancedBg }
        return levelIntermediateBg
    }

    public static func levelBgColor(_ field: LocalizedField) -> Color {
        levelBgColor(field.ru)
    }

    // Gradients
    public static let splashGradient = LinearGradient(
        colors: [Color(hex: "FFA500"), Color(hex: "CC5500")],
        startPoint: .top,
        endPoint: .bottom
    )

    public static let onboardingButtonGradient = LinearGradient(
        colors: [Color(hex: "3D2015"), Color(hex: "2B1810")],
        startPoint: .bottomLeading,
        endPoint: .topTrailing
    )

    public static let ovrBadgeGradient = LinearGradient(
        colors: [Color(hex: "D97706"), Color(hex: "F59E0B"), Color(hex: "FBBF24")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Glass Card Modifier (matches glass_card.xml: 0dp elevation + crisp 1dp border)
public struct HooplabCardModifier: ViewModifier {
    public var padding: CGFloat = 16
    public var cornerRadius: CGFloat = HooplabDimens.radiusCard
    public var strokeColor: Color? = nil

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(HooplabTheme.glassFill)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor ?? HooplabTheme.glassStroke, lineWidth: 1)
            )
    }
}

// MARK: - Aurora + Court Lines Background Modifier (matches drawable/bg_aurora.xml)
public struct AuroraBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                colors: [HooplabTheme.auroraTop, HooplabTheme.bgMain],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                ZStack {
                    // Blob 1: Top-Left Blue
                    RadialGradient(
                        colors: [HooplabTheme.aurora1, HooplabTheme.aurora1.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.75
                    )
                    .frame(width: geo.size.width * 1.4, height: geo.size.width * 1.4)
                    .position(x: geo.size.width * 0.08, y: geo.size.height * 0.04)

                    // Blob 2: Top-Right Lavender
                    RadialGradient(
                        colors: [HooplabTheme.aurora2, HooplabTheme.aurora2.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.75
                    )
                    .frame(width: geo.size.width * 1.4, height: geo.size.width * 1.4)
                    .position(x: geo.size.width * 0.94, y: geo.size.height * 0.10)

                    // Blob 3: Center Blue
                    RadialGradient(
                        colors: [HooplabTheme.aurora1, HooplabTheme.aurora1.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.65
                    )
                    .frame(width: geo.size.width * 1.2, height: geo.size.width * 1.2)
                    .position(x: geo.size.width * 0.45, y: geo.size.height * 0.40)

                    // Blob 4: Bottom-Right Peach
                    RadialGradient(
                        colors: [HooplabTheme.aurora3, HooplabTheme.aurora3.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.75
                    )
                    .frame(width: geo.size.width * 1.4, height: geo.size.width * 1.4)
                    .position(x: geo.size.width * 0.86, y: geo.size.height * 0.90)

                    // Blob 5: Bottom-Left Lavender
                    RadialGradient(
                        colors: [HooplabTheme.aurora2, HooplabTheme.aurora2.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.65
                    )
                    .frame(width: geo.size.width * 1.2, height: geo.size.width * 1.2)
                    .position(x: geo.size.width * 0.10, y: geo.size.height * 0.86)

                    // Layer 6: Universal basketball court lines overlay
                    Image("bg_court_lines")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                        .opacity(colorScheme == .dark ? 0.10 : 0.45)
                        .allowsHitTesting(false)
                }
            }
            .ignoresSafeArea()

            content
        }
    }
}

public extension View {
    func hooplabCard(padding: CGFloat = 16, cornerRadius: CGFloat = HooplabDimens.radiusCard, strokeColor: Color? = nil) -> some View {
        modifier(HooplabCardModifier(padding: padding, cornerRadius: cornerRadius, strokeColor: strokeColor))
    }

    func hooplabAurora() -> some View {
        modifier(AuroraBackgroundModifier())
    }
}

// MARK: - Native Bundle WebP & PNG Image Loader (matches ExerciseMediaHelper.kt)
public final class HooplabMediaCache {
    public static let shared = HooplabMediaCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 80
    }

    public func webpImage(named name: String) -> UIImage? {
        if let cached = cache.object(forKey: name as NSString) {
            return cached
        }
        let candidates = [
            Bundle.main.url(forResource: name, withExtension: "webp", subdirectory: "Media"),
            Bundle.main.url(forResource: name, withExtension: "webp")
        ].compactMap { $0 }

        for url in candidates {
            if let img = UIImage(contentsOfFile: url.path) {
                cache.setObject(img, forKey: name as NSString)
                return img
            }
            if let src = CGImageSourceCreateWithURL(url as CFURL, nil),
               let cgImg = CGImageSourceCreateImageAtIndex(src, 0, nil) {
                let img = UIImage(cgImage: cgImg)
                cache.setObject(img, forKey: name as NSString)
                return img
            }
        }
        return nil
    }
}

public struct ExercisePhotoView: View {
    public let exerciseId: Int
    public let categoryRu: String

    public init(exerciseId: Int, categoryRu: String) {
        self.exerciseId = exerciseId
        self.categoryRu = categoryRu
    }

    public var body: some View {
        if let uiImage = HooplabMediaCache.shared.webpImage(named: "ex_\(exerciseId)") {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Image(ExerciseMediaHelper.categoryAssetName(categoryRu))
                .resizable()
                .scaledToFill()
        }
    }
}

public struct ProgramPhotoView: View {
    public let imageName: String

    public init(imageName: String) {
        self.imageName = imageName
    }

    public var body: some View {
        if let uiImage = HooplabMediaCache.shared.webpImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Image("cat_shots")
                .resizable()
                .scaledToFill()
        }
    }
}

public enum ExerciseMediaHelper {
    public static func categoryAssetName(_ category: String) -> String {
        let norm = category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if norm.contains("брос") || norm.contains("shot") { return "cat_shots" }
        if norm.contains("техн") || norm.contains("techniq") || norm.contains("дрибл") { return "cat_technique" }
        if norm.contains("защит") || norm.contains("defen") { return "cat_defense" }
        if norm.contains("напад") || norm.contains("offen") { return "cat_offense" }
        if norm.contains("физ") || norm.contains("fit") || norm.contains("силов") { return "cat_fitness" }
        if norm.contains("размин") || norm.contains("растяж") || norm.contains("warm") { return "cat_warmup" }
        if norm.contains("мышл") || norm.contains("iq") || norm.contains("такт") || norm.contains("tactic") { return "cat_tactics" }
        if norm.contains("прав") || norm.contains("rule") { return "cat_rules" }
        if norm.contains("игр") || norm.contains("соревн") || norm.contains("game") { return "cat_games" }
        return "cat_shots"
    }

    public static func categorySymbol(_ category: String) -> String {
        let norm = category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if norm.contains("брос") || norm.contains("shot") { return "figure.basketball" }
        if norm.contains("техн") || norm.contains("techniq") || norm.contains("дрибл") { return "basketball.fill" }
        if norm.contains("защит") || norm.contains("defen") { return "checkmark.shield.fill" }
        if norm.contains("напад") || norm.contains("offen") { return "arrow.forward.circle.fill" }
        if norm.contains("физ") || norm.contains("fit") || norm.contains("силов") { return "figure.run" }
        if norm.contains("размин") || norm.contains("растяж") || norm.contains("warm") { return "flame.fill" }
        if norm.contains("мышл") || norm.contains("iq") || norm.contains("такт") || norm.contains("tactic") { return "brain.head.profile" }
        if norm.contains("прав") || norm.contains("rule") { return "book.closed.fill" }
        if norm.contains("игр") || norm.contains("соревн") || norm.contains("game") { return "trophy.fill" }
        return "basketball.fill"
    }
}
