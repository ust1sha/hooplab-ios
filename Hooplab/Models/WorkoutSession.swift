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
