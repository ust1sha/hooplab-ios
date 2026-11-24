import SwiftUI

public struct ProfileView: View {
    @EnvironmentObject var dataStore: DataStore

    @State private var showingQuiz = false
    @State private var showingCourts = false
    @State private var showingNameAlert = false
    @State private var newPlayerName = ""
    @State private var showingShareSheet = false
    @State private var shareText = ""

    private var skills: PlayerStatsSkills {
        dataStore.calculateSkills()
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .hooplabAurora()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Title
                        Text(dataStore.isEnglish ? "Profile" : "Профиль")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(HooplabTheme.textPrimary)
                            .padding(.top, 14)
                            .padding(.horizontal, 16)

                        // 1. NBA Player Card (Panini Prizm & 2K Style)
                        nbaPlayerCard
                            .padding(.horizontal, 16)

                        // 2. Quick Actions
                        actionsSection
                            .padding(.horizontal, 16)

                        // 3. Badges & Achievements
                        badgesSection
                            .padding(.horizontal, 16)

                        // 4. App Settings
                        settingsSection
                            .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingQuiz) {
                QuizSheetView()
                    .environmentObject(dataStore)
            }
            .sheet(isPresented: $showingCourts) {
                NavigationStack {
                    CourtsView()
                        .environmentObject(dataStore)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [shareText])
            }
            .alert(dataStore.isEnglish ? "Change Player Name" : "Изменить имя атлета", isPresented: $showingNameAlert) {
                TextField(dataStore.isEnglish ? "Enter name" : "Введите имя", text: $newPlayerName)
                Button(dataStore.isEnglish ? "Save" : "Сохранить") {
                    if !newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty {
                        dataStore.setPlayerName(newPlayerName.trimmingCharacters(in: .whitespaces))
                    }
                }
                Button(dataStore.isEnglish ? "Cancel" : "Отмена", role: .cancel) {}
            }
        }
    }

    // MARK: - 1. NBA Player Card (matches activity_profile.xml)
    private var nbaPlayerCard: some View {
        VStack(spacing: 12) {
            // Top Bar: Card Brand + Position/Jersey Pills + OVR Badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("HOOPLAB PLAYER CARD")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(HooplabTheme.textSecondary)
                        .tracking(1)

                    HStack(spacing: 6) {
                        // Position Picker Menu
                        Menu {
                            ForEach(PlayerPosition.allCases) { pos in
                                Button(pos.title(isEn: dataStore.isEnglish)) {
                                    SoundAndHaptics.shared.lightTap()
                                    dataStore.setPosition(pos)
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(dataStore.playerPosition.rawValue) ▾")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(HooplabTheme.textPrimary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(HooplabTheme.bgNav)
                            .cornerRadius(10)
                        }

                        // Jersey Picker Menu
                        Menu {
                            ForEach([1, 2, 3, 7, 8, 11, 13, 23, 24, 30, 34, 77], id: \.self) { j in
                                Button("#\(j)") {
                                    SoundAndHaptics.shared.lightTap()
                                    dataStore.setPlayerJersey(j)
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("#\(dataStore.playerJersey) ▾")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(HooplabTheme.orangePrimary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(HooplabTheme.orangeSoft)
                            .cornerRadius(10)
                        }
                    }
                }

                Spacer()

                // Gold / Titanium OVR Badge
                VStack(spacing: 0) {
                    Text("\(skills.ovr)")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(HooplabTheme.textPrimary)
                    Text("OVR")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(HooplabTheme.textSecondary)
                        .tracking(1)
                }
                .frame(width: 60, height: 50)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "FEF3C7"), Color(hex: "FDE68A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "F59E0B"), lineWidth: 1)
                )
            }

            // Player Identity Row
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(HooplabTheme.orangeGradient)
                        .frame(width: 58, height: 58)
                        .shadow(color: HooplabTheme.orangePrimary.opacity(0.3), radius: 6, x: 0, y: 3)

                    Text(String(dataStore.playerName.prefix(1)).uppercased())
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(dataStore.playerName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)

                    HStack(spacing: 6) {
                        Text(skills.tierTitle)
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(HooplabTheme.orangePrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(HooplabTheme.orangeSoft)
                            .cornerRadius(6)

                        Text("•")
                            .foregroundColor(HooplabTheme.textSecondary)

                        Text(dataStore.playerPosition.title(isEn: dataStore.isEnglish))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(HooplabTheme.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()
            }
            .padding(.top, 4)

            // Divider
            Divider()
                .background(HooplabTheme.cardBorder)
                .padding(.vertical, 4)

            // 5 NBA Attributes (SHT, DNK, DEF, PLY, ATH)
            attributeBar(title: dataStore.isEnglish ? "Shooting (SHT)" : "Бросок (SHT)", val: skills.shooting)
            attributeBar(title: dataStore.isEnglish ? "Finishing (DNK)" : "Данк / Проход (DNK)", val: skills.finishing)
            attributeBar(title: dataStore.isEnglish ? "Defense (DEF)" : "Защита (DEF)", val: skills.defense)
            attributeBar(title: dataStore.isEnglish ? "Playmaking (PLY)" : "Плеймейкинг (PLY)", val: skills.playmaking)
            attributeBar(title: dataStore.isEnglish ? "Athleticism (ATH)" : "Атлетизм (ATH)", val: skills.athleticism)

            // Share Card Button
            Button(action: {
                SoundAndHaptics.shared.mediumTap()
                shareText = """
                🏀 HoopLab Player Card
                Игрок: \(dataStore.playerName) (\(dataStore.playerPosition.rawValue) • #\(dataStore.playerJersey))
                Рейтинг OVR: \(skills.ovr) (\(skills.tierTitle))
                🔥 Бросок: \(skills.shooting) | Защита: \(skills.defense) | Атлетизм: \(skills.athleticism)
                Стрик: \(dataStore.streakDays) дн. | Опыт: \(dataStore.totalXP) XP
                """
                showingShareSheet = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .semibold))
                    Text(dataStore.isEnglish ? "Share Player Card" : "Поделиться карточкой")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(HooplabTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(HooplabTheme.bgNav)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .hooplabCard(padding: 16, cornerRadius: 22)
    }

    private func attributeBar(title: String, val: Int) -> some View {
        VStack(spacing: 3) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(HooplabTheme.textSecondary)

                Spacer()

                Text("\(val)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(HooplabTheme.bgNav)
                        .frame(height: 5)

                    let progress = min(1.0, Double(val) / 99.0)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(HooplabTheme.orangePrimary)
                        .frame(width: geo.size.width * CGFloat(progress), height: 5)
                }
            }
            .frame(height: 5)
        }
    }

    // MARK: - 2. Quick Actions Section
    private var actionsSection: some View {
        VStack(spacing: 8) {
            actionRow(
                icon: "brain.head.profile",
                color: Color(hex: "D97706"),
                title: dataStore.isEnglish ? "Basketball IQ Quiz" : "Баскетбольный IQ-квиз",
                subtitle: dataStore.isEnglish ? "Best score: \(dataStore.quizHighScore) pts" : "Рекорд: \(dataStore.quizHighScore) очков"
            ) {
                showingQuiz = true
            }

            actionRow(
                icon: "mappin.and.ellipse",
                color: Color(hex: "2563EB"),
                title: dataStore.isEnglish ? "Streetball Courts" : "Стритбольные площадки",
                subtitle: dataStore.isEnglish ? "Find outdoor courts & navigate" : "Карта лучших спотов Москвы"
            ) {
                showingCourts = true
            }

            actionRow(
                icon: "pencil",
                color: HooplabTheme.orangePrimary,
                title: dataStore.isEnglish ? "Change Name" : "Изменить имя атлета",
                subtitle: dataStore.playerName
            ) {
                newPlayerName = dataStore.playerName
                showingNameAlert = true
            }
        }
    }

    private func actionRow(icon: String, color: Color, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            SoundAndHaptics.shared.lightTap()
            action()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.12))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(HooplabTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(HooplabTheme.textHint)
            }
            .hooplabCard(padding: 12, cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 3. Badges Section
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dataStore.isEnglish ? "Achievements" : "Достижения")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(dataStore.badges) { badge in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(badge.emoji)
                                .font(.system(size: 22))

                            Spacer()

                            Text(badge.tier)
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundColor(badge.isUnlocked ? HooplabTheme.orangePrimary : HooplabTheme.textHint)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(badge.isUnlocked ? HooplabTheme.orangeSoft : HooplabTheme.bgNav)
                                .cornerRadius(6)
                        }

                        Text(badge.localizedTitle(isEn: dataStore.isEnglish))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(HooplabTheme.textPrimary)
                            .lineLimit(1)

                        Text(badge.localizedDesc(isEn: dataStore.isEnglish))
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(HooplabTheme.textSecondary)
                            .lineLimit(2)
                    }
                    .hooplabCard(padding: 12, cornerRadius: 16)
                    .opacity(badge.isUnlocked ? 1.0 : 0.65)
                }
            }
        }
    }

    // MARK: - 4. Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dataStore.isEnglish ? "Settings" : "Настройки")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)

            VStack(spacing: 10) {
                // Language Toggle
                HStack {
                    Text(dataStore.isEnglish ? "Language / Язык" : "Язык / Language")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(HooplabTheme.textPrimary)

                    Spacer()

                    Picker("Language", selection: Binding(
                        get: { dataStore.isEnglish },
                        set: { dataStore.setLanguage(isEn: $0) }
                    )) {
                        Text("Русский").tag(false)
                        Text("English").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(HooplabTheme.cardBg)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(HooplabTheme.cardBorder, lineWidth: 1)
                )
            }
        }
    }
}

// Helper ShareSheet for UIActivityViewController
public struct ShareSheet: UIViewControllerRepresentable {
    public var activityItems: [Any]
    public var applicationActivities: [UIActivity]? = nil

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
