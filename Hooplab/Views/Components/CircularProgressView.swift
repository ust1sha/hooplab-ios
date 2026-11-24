import SwiftUI

public struct CircularProgressView: View {
    public var progress: Double
    public var lineWidth: CGFloat = 14
    public var color: Color = HooplabTheme.orangePrimary

    public init(progress: Double, lineWidth: CGFloat = 14, color: Color = HooplabTheme.orangePrimary) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.color = color
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.7), color]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear(duration: 0.5), value: progress)
        }
    }
}
