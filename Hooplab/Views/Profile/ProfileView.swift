import SwiftUI

public struct ProfileView: View {
    @EnvironmentObject var dataStore: DataStore

    @State private var showingQuiz = false
    @State private var showingPositionPicker = false

    public var body: some View {
        NavigationStack {
            ZStack {
                HooplabTheme.bgDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 2K Style Player Card Banner
                        playerCardView

                        // Basketball Quiz Quick Launch Banner
                        quizBanner

                        // Skill Radar / Attribute Bars
                        attributesView

                        // Badges & Achievements
                        badgesView

                        // Settings: Language & Position
                        settingsView
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(dataStore.isEnglish ? "Player Profile" : "Профиль игрока")
            .sheet(isPresented: $showingQuiz) {
                QuizSheetView()
                    .environmentObject(dataStore)
            }
        }
    }

    private var playerCardView: some View {
        let skills = dataStore.calculateSkills()
        return VStack(spacing: 16) {
            HStack(alignment: .top) {
                // Avatar with Jersey & Position
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(HooplabTheme.orangeGradient)
                        .frame(width: 72, height: 72)

                    VStack(spacing: 2) {
                        Text(dataStore.playerPosition.rawValue)
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                        Text(dataStore.playerName)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(1)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(dataStore.playerName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()

                        // OVR Rating
                        HStack(spacing: 2) {
                            Text("\(skills.ovr)")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(HooplabTheme.orangePrimary)
                            Text("OVR")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(HooplabTheme.orangePrimary)
                        }
                    }

                    Text(dataStore.playerPosition.title(isEn: dataStore.isEnglish))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(HooplabTheme.textSecondary)

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Text("🔥")
                            Text("\(dataStore.streakDays) \(dataStore.isEnglish ? "days" : "дней")")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }

                        HStack(spacing: 4) {
                            Text("⚡")
                            Text("\(dataStore.totalXP) XP")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(HooplabTheme.orangePrimary)
                        }

                        HStack(spacing: 4) {
                            Text("🏆")
                            Text(skills.tierTitle)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }

            Divider().background(HooplabTheme.borderDark)

            HStack {
                VStack(spacing: 2) {
                    Text("\(dataStore.completedSessions.count)")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                    Text(dataStore.isEnglish ? "Workouts" : "Тренировок")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(HooplabTheme.textMuted)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 2) {
                    Text("\(dataStore.quizHighScore)/10")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(HooplabTheme.orangePrimary)
                    Text(dataStore.isEnglish ? "Quiz Record" : "Рекорд квиза")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(HooplabTheme.textMuted)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 2) {
                    Text("\(dataStore.favoriteIds.count)")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.red)
                    Text(dataStore.isEnglish ? "Favorites" : "В избранном")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(HooplabTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .hooplabCard(padding: 18, cornerRadius: 20)
    }

    private var quizBanner: some View {
        Button(action: {
            SoundAndHaptics.shared.mediumTap()
            showingQuiz = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(HooplabTheme.orangePrimary.opacity(0.2))
                        .frame(width: 52, height: 52)
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(HooplabTheme.orangePrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(dataStore.isEnglish ? "Basketball IQ Quiz" : "Баскетбольный квиз")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)

                    Text(dataStore.isEnglish ? "Test your knowledge of NBA & FIBA rules" : "Проверь знания правил и тактики (10 вопросов)")
                        .font(.system(size: 13))
                        .foregroundColor(HooplabTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(HooplabTheme.textMuted)
            }
            .hooplabCard(padding: 16)
        }
        .buttonStyle(.plain)
    }

    private var attributesView: some View {
        let skills = dataStore.calculateSkills()
        return VStack(alignment: .leading, spacing: 14) {
            Text(dataStore.isEnglish ? "PLAYER ATTRIBUTES" : "НАВЫКИ И АТРИБУТЫ")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(HooplabTheme.textMuted)
                .tracking(1)

            skillBar(title: dataStore.isEnglish ? "Shooting" : "Броски", value: skills.shooting, color: HooplabTheme.orangePrimary)
            skillBar(title: dataStore.isEnglish ? "Finishing" : "Проходы под кольцо", value: skills.finishing, color: .purple)
            skillBar(title: dataStore.isEnglish ? "Defense" : "Защита", value: skills.defense, color: .green)
            skillBar(title: dataStore.isEnglish ? "Playmaking" : "Дриблинг и передачи", value: skills.playmaking, color: .blue)
            skillBar(title: dataStore.isEnglish ? "Athleticism" : "Атлетизм и выносливость", value: skills.athleticism, color: .red)
        }
        .hooplabCard()
    }

    private func skillBar(title: String, value: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(value)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(Double(value) / 100.0), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private var badgesView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(dataStore.isEnglish ? "ACHIEVEMENTS" : "ДОСТИЖЕНИЯ")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(HooplabTheme.textMuted)
                .tracking(1)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(dataStore.badges) { badge in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(badge.emoji)
                                .font(.system(size: 26))
                            Spacer()
                            if badge.isUnlocked {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(HooplabTheme.textMuted)
                            }
                        }

                        Text(badge.localizedTitle(isEn: dataStore.isEnglish))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)

                        Text(badge.localizedDesc(isEn: dataStore.isEnglish))
                            .font(.system(size: 11))
                            .foregroundColor(HooplabTheme.textSecondary)
                            .lineLimit(2)
                    }
                    .padding(12)
                    .background(badge.isUnlocked ? HooplabTheme.surfaceDark : HooplabTheme.cardDark.opacity(0.6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(badge.isUnlocked ? HooplabTheme.orangePrimary.opacity(0.5) : HooplabTheme.borderDark, lineWidth: 1)
                    )
                }
            }
        }
        .hooplabCard()
    }

    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(dataStore.isEnglish ? "SETTINGS" : "НАСТРОЙКИ")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(HooplabTheme.textMuted)
                .tracking(1)

            // Language switch
            HStack {
                Text(dataStore.isEnglish ? "Language" : "Язык приложения")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                Picker("Language", selection: Binding(
                    get: { dataStore.isEnglish },
                    set: { dataStore.setLanguage(isEn: $0) }
                )) {
                    Text("Русский").tag(false)
                    Text("English").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 170)
            }

            Divider().background(HooplabTheme.borderDark)

            // Position selection
            HStack {
                Text(dataStore.isEnglish ? "Court Position" : "Позиция на площадке")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                Picker("Position", selection: Binding(
                    get: { dataStore.playerPosition },
                    set: { dataStore.setPosition($0) }
                )) {
                    ForEach(PlayerPosition.allCases) { pos in
                        Text(pos.rawValue).tag(pos)
                    }
                }
                .pickerStyle(.menu)
                .tint(HooplabTheme.orangePrimary)
            }
        }
        .hooplabCard()
    }
}
