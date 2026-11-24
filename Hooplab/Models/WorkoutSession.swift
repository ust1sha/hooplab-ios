import Foundation

public struct WorkoutSession: Identifiable, Codable, Hashable {
    public let id: UUID
    public let exerciseId: Int
    public let exerciseTitle: String
    public let category: String
    public let setsCompleted: Int
    public let durationSec: Int
    public let timestamp: Date

    public init(id: UUID = UUID(), exerciseId: Int, exerciseTitle: String, category: String, setsCompleted: Int, durationSec: Int, timestamp: Date = Date()) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseTitle = exerciseTitle
        self.category = category
        self.setsCompleted = setsCompleted
        self.durationSec = durationSec
        self.timestamp = timestamp
    }
}

public struct WorkoutProgram: Identifiable {
    public let id: String
    public let titleRu: String
    public let descriptionRu: String
    public let durationMinutes: Int
    public let exerciseCount: Int
    public let levelRu: String
    public let tag: String
    public let iconName: String
    public let exerciseIds: [Int]
    public let gradientColors: [String]

    public init(
        id: String,
        titleRu: String,
        descriptionRu: String,
        durationMinutes: Int,
        exerciseCount: Int,
        levelRu: String,
        tag: String,
        iconName: String,
        exerciseIds: [Int],
        gradientColors: [String]
    ) {
        self.id = id
        self.titleRu = titleRu
        self.descriptionRu = descriptionRu
        self.durationMinutes = durationMinutes
        self.exerciseCount = exerciseCount
        self.levelRu = levelRu
        self.tag = tag
        self.iconName = iconName
        self.exerciseIds = exerciseIds
        self.gradientColors = gradientColors
    }
}

public struct WorkoutProgramsCatalog {
    public static let programs: [WorkoutProgram] = [
        WorkoutProgram(
            id: "sniper_warmup",
            titleRu: "Утренняя разминка снайпера",
            descriptionRu: "Комплекс для разогрева, постановки броска и баланса перед игрой.",
            durationMinutes: 15,
            exerciseCount: 4,
            levelRu: "Средний",
            tag: "🎯 СНАЙПЕР",
            iconName: "scope",
            exerciseIds: [1, 5, 11, 14],
            gradientColors: ["#EA580C", "#9A3412"]
        ),
        WorkoutProgram(
            id: "kyrie_dribbling",
            titleRu: "Взрывной дриблинг Кайри",
            descriptionRu: "Интенсивная прокачка контроля мяча, кроссоверов и низкого ведения.",
            durationMinutes: 25,
            exerciseCount: 5,
            levelRu: "Продвинутый",
            tag: "⚡ ДРИБЛИНГ",
            iconName: "bolt.fill",
            exerciseIds: [2, 27, 28, 29, 30],
            gradientColors: ["#D97706", "#78350F"]
        ),
        WorkoutProgram(
            id: "lockdown_defense",
            titleRu: "Крепкая защита: работа ног",
            descriptionRu: "Интервальная нагрузка, защитная стойка, челночный шаг и реакция.",
            durationMinutes: 30,
            exerciseCount: 5,
            levelRu: "Продвинутый",
            tag: "🛡️ ЗАЩИТА",
            iconName: "shield.fill",
            exerciseIds: [3, 21, 8, 22, 25],
            gradientColors: ["#16A34A", "#14532D"]
        ),
        WorkoutProgram(
            id: "explosive_vert",
            titleRu: "Взрывной атлетизм и прыжок",
            descriptionRu: "Плиометрика, взрывная сила ног и увеличение вертикального прыжка.",
            durationMinutes: 20,
            exerciseCount: 4,
            levelRu: "Продвинутый",
            tag: "🚀 АТЛЕТИЗМ",
            iconName: "figure.jumprope",
            exerciseIds: [32, 33, 34, 35],
            gradientColors: ["#9333EA", "#581C87"]
        )
    ]
}
