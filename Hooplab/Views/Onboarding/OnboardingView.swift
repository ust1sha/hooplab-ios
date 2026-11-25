import SwiftUI

public struct OnboardingView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var currentPage: Int = 0

    public init() {}

    public var body: some View {
        ZStack {
            HooplabTheme.splashGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    onboardingPage(
                        imageName: "onb_01",
                        title: dataStore.isEnglish ? "Your pocket coach." : "Ваш карманный коуч.",
                        body: dataStore.isEnglish
                            ? "A personalized training program that adapts to your level: from beginner to team captain."
                            : "Персональная программа тренировок, которая подстраивается под ваш уровень: от новичка до капитана команды.",
                        isLast: false,
                        paddingH: 32
                    )
                    .tag(0)

                    onboardingPage(
                        imageName: "onb_02",
                        title: dataStore.isEnglish ? "Play smarter." : "Играйте умнее.",
                        body: dataStore.isEnglish
                            ? "Tactical schemes, correct positioning and defense tips. Understand the game as well as you feel the ball."
                            : "Тактические схемы, правильное позиционирование и лайфхаки по защите. Понимайте игру так же хорошо, как чувствуете мяч.",
                        isLast: false,
                        paddingH: 32
                    )
                    .tag(1)

                    onboardingPage(
                        imageName: "onb_03",
                        title: dataStore.isEnglish ? "Track your growth." : "Следите за ростом.",
                        body: dataStore.isEnglish
                            ? "Keep shot statistics, track records and visually watch your efficiency on the court grow."
                            : "Ведите статистику бросков, отслеживайте рекорды и визуально наблюдайте, как растет ваша эффективность на площадке.",
                        isLast: true,
                        paddingH: 16
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Custom bottom indicator (matches Android TabLayout white indicator)
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.35))
                            .frame(width: index == currentPage ? 28 : 10, height: 3)
                            .animation(.easeInOut(duration: 0.25), value: currentPage)
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }

    private func onboardingPage(imageName: String, title: String, body: String, isLast: Bool, paddingH: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, paddingH)
                .frame(maxHeight: 340)

            Spacer(minLength: 20)

            Text(title)
                .font(.geist(HooplabDimens.textDisplay, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text(body)
                .font(.geist(HooplabDimens.textBody, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 16)

            Spacer(minLength: 24)

            Button(action: {
                SoundAndHaptics.shared.vibrateClick()
                if isLast {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        dataStore.finishOnboarding()
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                }
            }) {
                Text(isLast
                     ? (dataStore.isEnglish ? "Let's win!" : "Вперед к победам!")
                     : (dataStore.isEnglish ? "Next" : "Далее"))
                    .font(.geist(HooplabDimens.textButton, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: HooplabDimens.buttonHeight)
                    .background(HooplabTheme.onboardingButtonGradient)
                    .cornerRadius(16)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.bottom, 36)
        }
    }
}
