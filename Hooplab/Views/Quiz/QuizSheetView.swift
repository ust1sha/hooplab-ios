import SwiftUI

// MARK: - Continuous Basketball IQ Quiz Modal (1:1 Android dialog_basketball_quiz.xml)
public struct QuizSheetView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss

    @State private var currentQuestion: QuizQuestion? = nil
    @State private var selectedOptionIndex: Int? = nil
    @State private var hasSubmittedCurrent: Bool = false

    public init() {}

    public var body: some View {
        let isEn = dataStore.isEnglish

        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // Header Badges
                    HStack {
                        Text("🧠 HOOP IQ")
                            .font(.geist(12, weight: .bold))
                            .foregroundColor(HooplabTheme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(HooplabTheme.fireBg)
                            .clipShape(Capsule())

                        Spacer()

                        Text(
                            isEn
                            ? "Score: \(dataStore.quizScore) • \(dataStore.answeredQuestionIds.count)/\(dataStore.totalQuizQuestionsCount)"
                            : "Счёт: \(dataStore.quizScore) • \(dataStore.answeredQuestionIds.count)/\(dataStore.totalQuizQuestionsCount)"
                        )
                        .font(.geist(13, weight: .bold))
                        .foregroundColor(HooplabTheme.textSecondary)
                    }

                    if let q = currentQuestion {
                        // Question Card
                        Text(q.localizedQuestion(isEn: isEn))
                            .font(.geist(19, weight: .bold))
                            .foregroundColor(HooplabTheme.textPrimary)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .hooplabCard(padding: 18)

                        // 4 Interactive Option Buttons
                        let options = q.localizedOptions(isEn: isEn)
                        let letters = ["A", "B", "C", "D"]

                        VStack(spacing: 10) {
                            ForEach(Array(options.enumerated()), id: \.offset) { idx, optionText in
                                Button {
                                    handleOptionTap(idx: idx, question: q)
                                } label: {
                                    optionRow(
                                        letter: idx < letters.count ? letters[idx] : "•",
                                        text: optionText,
                                        index: idx,
                                        correctIndex: q.correctIndex
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(hasSubmittedCurrent)
                            }
                        }

                        // Explanation Card + Continuous "Next Question ->" Button
                        if hasSubmittedCurrent {
                            let isCorrect = (selectedOptionIndex == q.correctIndex)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(
                                    isCorrect
                                    ? (isEn ? "✅ Correct! +1 Hoop IQ" : "✅ Верно! +1 к Hoop IQ")
                                    : (isEn ? "❌ Not quite right" : "❌ Неверный ответ")
                                )
                                .font(.geist(14, weight: .bold))
                                .foregroundColor(isCorrect ? HooplabTheme.accentSecondary : HooplabTheme.error)

                                Text(q.localizedExplanation(isEn: isEn))
                                    .font(.geist(14, weight: .regular))
                                    .foregroundColor(HooplabTheme.textPrimary)
                                    .lineSpacing(3)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .hooplabCard(
                                padding: 16,
                                strokeColor: isCorrect ? HooplabTheme.accentSecondary.opacity(0.6) : HooplabTheme.error.opacity(0.5)
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))

                            // Continuous Question Advance Button (doesn't close dialog!)
                            let hasMore = dataStore.nextUnansweredQuestion() != nil
                            Button {
                                SoundAndHaptics.shared.vibrateClick()
                                loadNextQuestion()
                            } label: {
                                HStack(spacing: 8) {
                                    Text(
                                        hasMore
                                        ? (isEn ? "Next Question" : "Следующий вопрос")
                                        : (isEn ? "See Final Results" : "Показать результат")
                                    )
                                    .font(.geist(15, weight: .bold))
                                    Image(systemName: hasMore ? "arrow.right" : "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: HooplabDimens.buttonHeight)
                                .background(HooplabTheme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusButton))
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }
                    } else {
                        // All Questions Completed View
                        VStack(spacing: 16) {
                            Text("🏆")
                                .font(.system(size: 56))

                            Text(isEn ? "All Hoop IQ Questions Complete!" : "Все вопросы Hoop IQ пройдены!")
                                .font(.geist(22, weight: .bold))
                                .foregroundColor(HooplabTheme.textPrimary)
                                .multilineTextAlignment(.center)

                            Text(
                                isEn
                                ? "Correct answers: \(dataStore.quizScore) of \(dataStore.totalQuizQuestionsCount)\nYour Playmaking & OVR rating are boosted!"
                                : "Правильных ответов: \(dataStore.quizScore) из \(dataStore.totalQuizQuestionsCount)\nТвой рейтинг Playmaking и OVR прокачаны!"
                            )
                            .font(.geist(15, weight: .regular))
                            .foregroundColor(HooplabTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                            Button {
                                SoundAndHaptics.shared.vibrateClick()
                                dismiss()
                            } label: {
                                Text(isEn ? "Back to Profile" : "Вернуться в профиль")
                                    .font(.geist(15, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: HooplabDimens.buttonHeight)
                                    .background(HooplabTheme.accentSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusButton))
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .hooplabCard(padding: 24)
                    }
                }
                .padding(HooplabDimens.screenPaddingH)
            }
            .hooplabAurora()
            .navigationTitle(isEn ? "Basketball IQ Quiz" : "Викторина Hoop IQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEn ? "Close" : "Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(HooplabTheme.primary)
                }
            }
        }
        .onAppear {
            if currentQuestion == nil {
                currentQuestion = dataStore.nextUnansweredQuestion()
            }
        }
    }

    private func optionRow(letter: String, text: String, index: Int, correctIndex: Int) -> some View {
        let borderColor: Color = {
            guard hasSubmittedCurrent else { return HooplabTheme.glassStroke }
            if index == correctIndex { return HooplabTheme.accentSecondary }
            if index == selectedOptionIndex { return HooplabTheme.error }
            return HooplabTheme.glassStroke.opacity(0.5)
        }()

        let bgTint: Color = {
            guard hasSubmittedCurrent else { return HooplabTheme.glassFill }
            if index == correctIndex { return HooplabTheme.accentSecondary.opacity(0.16) }
            if index == selectedOptionIndex { return HooplabTheme.error.opacity(0.16) }
            return HooplabTheme.glassFill.opacity(0.6)
        }()

        return HStack(spacing: 12) {
            Text(letter)
                .font(.geist(13, weight: .bold))
                .foregroundColor(hasSubmittedCurrent && index == correctIndex ? .white : HooplabTheme.primary)
                .frame(width: 28, height: 28)
                .background(hasSubmittedCurrent && index == correctIndex ? HooplabTheme.accentSecondary : HooplabTheme.fireBg)
                .clipShape(Circle())

            Text(text)
                .font(.geist(15, weight: .medium))
                .foregroundColor(HooplabTheme.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if hasSubmittedCurrent {
                if index == correctIndex {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(HooplabTheme.accentSecondary)
                } else if index == selectedOptionIndex {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(HooplabTheme.error)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(bgTint)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, lineWidth: hasSubmittedCurrent && (index == correctIndex || index == selectedOptionIndex) ? 2 : 1)
        )
    }

    private func handleOptionTap(idx: Int, question: QuizQuestion) {
        guard !hasSubmittedCurrent else { return }
        selectedOptionIndex = idx
        let isCorrect = (idx == question.correctIndex)
        if isCorrect {
            SoundAndHaptics.shared.playSetComplete()
        } else {
            SoundAndHaptics.shared.mediumTap()
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            hasSubmittedCurrent = true
        }
        dataStore.submitQuizAnswer(questionId: question.id, isCorrect: isCorrect)
    }

    private func loadNextQuestion() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedOptionIndex = nil
            hasSubmittedCurrent = false
            currentQuestion = dataStore.nextUnansweredQuestion()
        }
    }
}
