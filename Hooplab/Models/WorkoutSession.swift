import Foundation

public struct WorkoutSession: Identifiable, Codable, Hashable {
    public let id: UUID
    public let exerciseId: Int
    public let exerciseTitle: String
    public let category: String
    public let setsCompleted: Int
    public let durationSec: Int
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        exerciseId: Int,
        exerciseTitle: String,
        category: String,
        setsCompleted: Int = 3,
        durationSec: Int,
        timestamp: Date = Date()
    ) {
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
    public let titleEn: String
    public let descriptionRu: String
    public let descriptionEn: String
    public let durationMinutes: Int
    public let exerciseCount: Int
    public let levelRu: String
    public let levelEn: String
    public let tag: String
    public let imageName: String
    public let exerciseIds: [Int]

    public func localizedTitle(isEn: Bool) -> String { isEn ? titleEn : titleRu }
    public func localizedDescription(isEn: Bool) -> String { isEn ? descriptionEn : descriptionRu }
    public func localizedLevel(isEn: Bool) -> String { isEn ? levelEn : levelRu }
}

public struct WorkoutProgramsCatalog {
    public static let programs: [WorkoutProgram] = [
        WorkoutProgram(
            id: "sniper_warmup",
            titleRu: "Утренняя разминка снайпера",
            titleEn: "Sniper Morning Warmup",
            descriptionRu: "Комплекс для разогрева, постановки броска и баланса перед игрой.",
            descriptionEn: "Essential warmup for shooting mechanics and balance.",
            durationMinutes: 15,
            exerciseCount: 4,
            levelRu: "Средний",
            levelEn: "Intermediate",
            tag: "🎯 СНАЙПЕР",
            imageName: "program_sniper",
            exerciseIds: [1, 5, 11, 14]
        ),
        WorkoutProgram(
            id: "kyrie_dribbling",
            titleRu: "Взрывной дриблинг Кайри",
            titleEn: "Kyrie Explosive Dribbling",
            descriptionRu: "Интенсивная прокачка контроля мяча, кроссоверов и низкого ведения.",
            descriptionEn: "High intensity ball-handling and crossover mastery.",
            durationMinutes: 25,
            exerciseCount: 5,
            levelRu: "Продвинутый",
            levelEn: "Advanced",
            tag: "⚡ ДРИБЛИНГ",
            imageName: "program_dribble",
            exerciseIds: [2, 27, 28, 29, 30]
        ),
        WorkoutProgram(
            id: "lockdown_defense",
            titleRu: "Крепкая защита: работа ног",
            titleEn: "Lockdown Defense: Footwork",
            descriptionRu: "Интервальная нагрузка, защитная стойка, челночный шаг и реакция.",
            descriptionEn: "Interval footwork drills, lateral slides and closeouts.",
            durationMinutes: 30,
            exerciseCount: 5,
            levelRu: "Продвинутый",
            levelEn: "Advanced",
            tag: "🛡️ ЗАЩИТА",
            imageName: "program_defense",
            exerciseIds: [3, 21, 8, 22, 25]
        ),
        WorkoutProgram(
            id: "explosive_vert",
            titleRu: "Взрывной атлетизм и прыжок",
            titleEn: "Explosive Vertical & Power",
            descriptionRu: "Плиометрика, взрывная сила ног и увеличение вертикального прыжка.",
            descriptionEn: "Plyometrics and lower body power to boost your vertical leap.",
            durationMinutes: 20,
            exerciseCount: 4,
            levelRu: "Продвинутый",
            levelEn: "Advanced",
            tag: "🚀 АТЛЕТИЗМ",
            imageName: "program_power",
            exerciseIds: [32, 33, 34, 35]
        )
    ]
}
