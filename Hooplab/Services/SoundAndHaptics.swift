import Foundation
import UIKit
import AudioToolbox

public class SoundAndHaptics {
    public static let shared = SoundAndHaptics()

    private init() {}

    public func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    public func mediumTap() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    public func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1054) // Subtly pleasant system chime
    }

    public func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
        AudioServicesPlaySystemSound(1053) // Subtle alert sound
    }

    public func timerCountdownBeep() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        AudioServicesPlaySystemSound(1057) // Short tick
    }

    public func timerCompleteSound() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1025) // Celebratory fanfare
    }
}
