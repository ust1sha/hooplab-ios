import SwiftUI

public struct QuizSheetView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var questions: [QuizQuestion] = BasketballQuizData.allQuestions
    @State private var currentIndex: Int = 0
    @State private var selectedOptionIndex: Int? = nil
    @State private var isAnswered: Bool = false
    @State private var score: Int = 0
    @State private var isFinished: Bool = false

    public var body: some View {
        ZStack {
            HooplabTheme.bgDark.ignoresSafeArea()

            VStack(spacing: 20) {
                // Top header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(HooplabTheme.textMuted)
                    }

                    Spacer()

                    Text(dataStore.isEnglish ? "Basketball Quiz" : "Баскетбольный квиз")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                        Text("\(score)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if isFinished {
                    quizSummaryView
                } else if currentIndex < questions.count {
                    questionContentView(question: questions[currentIndex])
                }
            }
        }
    }

    private func questionContentView(question: QuizQuestion) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress bar
                HStack(spacing: 6) {
                    ForEach(0..<questions.count, id: \.self) { idx in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(idx < currentIndex ? Color.green : (idx == currentIndex ? HooplabTheme.orangePrimary : Color.white.opacity(0.15)))
                            .frame(height: 5)
                    }
                }
                .padding(.horizontal, 20)

                // Question counter & badge
                HStack {
                    Text(dataStore.isEnglish ? "QUESTION \(currentIndex + 1) OF \(questions.count)" : "ВОПРОС \(currentIndex + 1) ИЗ \(questions.count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(HooplabTheme.orangePrimary)
                        .tracking(1.5)

                    Spacer()
                }
                .padding(.horizontal, 20)

                // Question text card
                VStack(alignment: .leading, spacing: 12) {
                    Text(question.localizedQuestion(isEn: dataStore.isEnglish))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .hooplabCard(padding: 20)
                .padding(.horizontal, 16)

                // Options
                VStack(spacing: 12) {
                    let options = question.localizedOptions(isEn: dataStore.isEnglish)
                    ForEach(0..<options.count, id: \.self) { optIdx in
                        optionButton(index: optIdx, text: options[optIdx], correctIdx: question.correctIndex)
                    }
                }
                .padding(.horizontal, 16)

                // Explanation & Next Button
                if isAnswered {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Image(systemName: selectedOptionIndex == question.correctIndex ? "checkmark.circle.fill" : "info.circle.fill")
                                .foregroundColor(selectedOptionIndex == question.correctIndex ? .green : .orange)
                            Text(dataStore.isEnglish ? "Explanation" : "Объяснение")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text(question.localizedExplanation(isEn: dataStore.isEnglish))
                            .font(.system(size: 14))
                            .foregroundColor(HooplabTheme.textSecondary)
                            .lineSpacing(3)

                        Button(action: {
                            SoundAndHaptics.shared.mediumTap()
                            goToNextQuestion()
                        }) {
                            HStack {
                                Text(currentIndex + 1 < questions.count ? (dataStore.isEnglish ? "Next Question ▶" : "Следующий вопрос ▶") : (dataStore.isEnglish ? "View Results 🎉" : "Посмотреть результаты 🎉"))
                                    .font(.system(size: 16, weight: .bold))
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HooplabTheme.orangeGradient)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.top, 4)
                    }
                    .hooplabCard(padding: 16)
                    .padding(.horizontal, 16)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer(minLength: 40)
            }
        }
    }

    private func optionButton(index: Int, text: String, correctIdx: Int) -> some View {
        let isCorrect = index == correctIdx
        let isSelected = selectedOptionIndex == index

        var bgColor: Color = HooplabTheme.cardDark
        var borderColor: Color = HooplabTheme.borderDark
        var iconName: String = "circle"
        var iconColor: Color = HooplabTheme.textMuted

        if isAnswered {
            if isCorrect {
                bgColor = Color.green.opacity(0.2)
                borderColor = Color.green
                iconName = "checkmark.circle.fill"
                iconColor = .green
            } else if isSelected {
                bgColor = Color.red.opacity(0.2)
                borderColor = Color.red
                iconName = "xmark.circle.fill"
                iconColor = .red
            }
        }

        return Button(action: {
            if !isAnswered {
                selectOption(index: index, correctIdx: correctIdx)
            }
        }) {
            HStack(spacing: 14) {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20))

                Text(text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(bgColor)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
    }

    private func selectOption(index: Int, correctIdx: Int) {
        selectedOptionIndex = index
        isAnswered = true

        if index == correctIdx {
            score += 1
            SoundAndHaptics.shared.success()
        } else {
            SoundAndHaptics.shared.error()
        }
    }

    private func goToNextQuestion() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if currentIndex + 1 < questions.count {
                currentIndex += 1
                selectedOptionIndex = nil
                isAnswered = false
            } else {
                isFinished = true
                dataStore.recordQuizCompletion(score: score)
            }
        }
    }

    private var quizSummaryView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(HooplabTheme.orangePrimary.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: score >= 7 ? "medal.fill" : "flame.fill")
                    .font(.system(size: 56))
                    .foregroundColor(HooplabTheme.orangePrimary)
            }

            VStack(spacing: 8) {
                Text(dataStore.isEnglish ? "Quiz Completed!" : "Квиз завершён!")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(.white)

                let percent = Int((Double(score) / Double(questions.count)) * 100)
                Text(score >= 7 ? (dataStore.isEnglish ? "Superb knowledge of basketball rules!" : "Отличное знание правил и тактики!") : (dataStore.isEnglish ? "Good effort! Keep practicing." : "Хороший результат! Тренируйся дальше."))
                    .font(.system(size: 15))
                    .foregroundColor(HooplabTheme.textSecondary)
            }

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(score) / \(questions.count)")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(HooplabTheme.orangePrimary)
                    Text(dataStore.isEnglish ? "Score" : "Правильно")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(HooplabTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .hooplabCard()

                VStack(spacing: 4) {
                    Text("+\(score * 20)")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(.green)
                    Text("XP Опыт")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(HooplabTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .hooplabCard()
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Button(action: {
                    restartQuiz()
                }) {
                    Text(dataStore.isEnglish ? "Play Again" : "Сыграть ещё раз")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(HooplabTheme.orangeGradient)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }

                Button(action: {
                    dismiss()
                }) {
                    Text(dataStore.isEnglish ? "Close" : "Закрыть")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(HooplabTheme.cardDark)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private func restartQuiz() {
        currentIndex = 0
        selectedOptionIndex = nil
        isAnswered = false
        score = 0
        isFinished = false
    }
}
