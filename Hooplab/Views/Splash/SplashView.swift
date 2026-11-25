import SwiftUI
import Lottie

private final class HooplabLottieImageProvider: AnimationImageProvider {
    func imageForAsset(asset: ImageAsset) -> CGImage? {
        let baseName = (asset.name as NSString).deletingPathExtension
        let candidates = [
            Bundle.main.url(forResource: baseName, withExtension: "png", subdirectory: "Lottie/images"),
            Bundle.main.url(forResource: "img_0", withExtension: "png", subdirectory: "Lottie/images"),
            Bundle.main.url(forResource: baseName, withExtension: "png", subdirectory: "Lottie"),
            Bundle.main.url(forResource: "img_0", withExtension: "png")
        ].compactMap { $0 }

        for url in candidates {
            if let img = UIImage(contentsOfFile: url.path)?.cgImage {
                return img
            }
        }
        return nil
    }
}

public struct LottieSplashRepresentable: UIViewRepresentable {
    public func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)
        container.backgroundColor = .clear

        let animationView = LottieAnimationView()
        if let url = Bundle.main.url(forResource: "splash_animation", withExtension: "json", subdirectory: "Lottie")
            ?? Bundle.main.url(forResource: "splash_animation", withExtension: "json") {
            animationView.animation = LottieAnimation.filepath(url.path)
        }
        animationView.imageProvider = HooplabLottieImageProvider()
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        animationView.play()
        return container
    }

    public func updateUIView(_ uiView: UIView, context: Context) {}
}

public struct SplashView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var didScheduleTransition = false

    public init() {}

    public var body: some View {
        ZStack {
            HooplabTheme.splashGradient
                .ignoresSafeArea()

            LottieSplashRepresentable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
        .onAppear {
            guard !didScheduleTransition else { return }
            didScheduleTransition = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    dataStore.completeSplashRouting()
                }
            }
        }
    }
}
