import Foundation
import UIKit
import AudioToolbox

public class SoundAndHaptics {
    public static let shared = SoundAndHaptics()
    public var isMuted: Bool = false

    private init() {}

    public func vibrateClick() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

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

    public func playStartWhistle() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1005)
    }

    public func playCountdownTick() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1057)
    }

    public func playSetComplete() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1054)
    }

    public func playWorkoutComplete() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1025)
    }

    public func success() {
        playSetComplete()
    }

    public func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1053)
    }

    public func timerCountdownBeep() {
        playCountdownTick()
    }

    public func timerCompleteSound() {
        playWorkoutComplete()
    }
}
