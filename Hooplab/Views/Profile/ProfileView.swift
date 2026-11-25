import SwiftUI
import PhotosUI

// MARK: - Profile Screen (1:1 Android activity_profile.xml + NBA Player Card + Badges + Settings)
public struct ProfileView: View {
    @EnvironmentObject var dataStore: DataStore

    // Modals & Pickers
    @State private var showQuizSheet: Bool = false
    @State private var showPositionPicker: Bool = false
    @State private var showJerseyAlert: Bool = false
    @State private var jerseyInput: String = "7"

    @State private var showNameAlert: Bool = false
    @State private var nameInput: String = ""

    @State private var showPasswordSheet: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    @State private var showDeleteConfirm: Bool = false
    @State private var showDeleteReauthAlert: Bool = false
    @State private var deleteReauthPassword: String = ""

    @State private var selectedBadgeForInfo: PlayerBadge? = nil
    @State private var shareSheetPayload: ShareCardPayload? = nil

    public init() {}

    public var body: some View {
        let isEn = dataStore.isEnglish

        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                headerSection(isEn: isEn)

                nbaPlayerCardSection(isEn: isEn)

                quickEditButtonsRow(isEn: isEn)

                quickStatsSummaryCard(isEn: isEn)

                quizProgressCard(isEn: isEn)

                badgesSection(isEn: isEn)

                navigationHubSection(isEn: isEn)

                settingsCard(isEn: isEn)

                accountActionsSection(isEn: isEn)
            }
            .padding(.horizontal, HooplabDimens.screenPaddingH)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .hooplabAurora()
        .onChange(of: selectedPhotoItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        dataStore.saveAvatar(image: uiImage)
                    }
                }
            }
        }
        .sheet(isPresented: $showQuizSheet) {
            QuizSheetView()
                .environmentObject(dataStore)
        }
        .sheet(isPresented: $showPasswordSheet) {
            ChangePasswordSheet(isEn: isEn)
                .environmentObject(dataStore)
        }
        .sheet(item: $shareSheetPayload) { payload in
            ActivityShareSheet(items: payload.items)
        }
        .confirmationDialog(
            isEn ? "Select Court Position" : "Выберите игровую позицию",
            isPresented: $showPositionPicker,
            titleVisibility: .visible
        ) {
            ForEach(PlayerPosition.allCases) { pos in
                Button(pos.title(isEn: isEn)) {
                    SoundAndHaptics.shared.vibrateClick()
                    dataStore.setPlayerPosition(pos)
                }
            }
            Button(isEn ? "Cancel" : "Отмена", role: .cancel) {}
        }
        .alert(isEn ? "Jersey Number (0–99)" : "Игровой номер (0–99)", isPresented: $showJerseyAlert) {
            TextField("7", text: $jerseyInput)
                .keyboardType(.numberPad)
            Button(isEn ? "Save" : "Сохранить") {
                if let val = Int(jerseyInput) {
                    dataStore.setJerseyNumber(val)
                }
            }
            Button(isEn ? "Cancel" : "Отмена", role: .cancel) {}
        }
        .alert(isEn ? "Change Name" : "Сменить имя", isPresented: $showNameAlert) {
            TextField(isEn ? "Your name" : "Ваше имя", text: $nameInput)
            Button(isEn ? "Save" : "Сохранить") {
                let clean = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                if !clean.isEmpty {
                    dataStore.updateUserName(clean)
                }
            }
            Button(isEn ? "Cancel" : "Отмена", role: .cancel) {}
        }
        .alert(
            selectedBadgeForInfo?.localizedTitle(isEn: isEn) ?? "",
            isPresented: Binding(
                get: { selectedBadgeForInfo != nil },
                set: { if !$0 { selectedBadgeForInfo = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let badge = selectedBadgeForInfo {
                Text("\(badge.localizedDesc(isEn: isEn))\n\n\(badge.progressText)")
            }
        }
        .alert(isEn ? "Delete Account?" : "Удалить аккаунт?", isPresented: $showDeleteConfirm) {
            Button(isEn ? "Delete Forever" : "Удалить навсегда", role: .destructive) {
                performAccountDelete(password: nil)
            }
            Button(isEn ? "Cancel" : "Отмена", role: .cancel) {}
        } message: {
            Text(
                isEn
                ? "All workouts, stats, badges, and favorites will be permanently deleted."
                : "Все тренировки, статистика, награды и избранное будут удалены безвозвратно."
            )
        }
        .alert(isEn ? "Confirm Password" : "Подтвердите пароль", isPresented: $showDeleteReauthAlert) {
            SecureField(isEn ? "Current password" : "Текущий пароль", text: $deleteReauthPassword)
            Button(isEn ? "Confirm & Delete" : "Подтвердить и удалить", role: .destructive) {
                let pw = deleteReauthPassword
                deleteReauthPassword = ""
                performAccountDelete(password: pw)
            }
            Button(isEn ? "Cancel" : "Отмена", role: .cancel) {
                deleteReauthPassword = ""
            }
        } message: {
            Text(
                isEn
                ? "Please enter your password to confirm account deletion."
                : "Для удаления аккаунта введите ваш текущий пароль."
            )
        }
    }

    // MARK: - 1. Header
    private func headerSection(isEn: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(isEn ? "Profile" : "Профиль")
                .font(.geist(HooplabDimens.textDisplay, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)

            if let email = dataStore.userEmail, !email.isEmpty {
                Text(email)
                    .font(.geist(13, weight: .regular))
                    .foregroundColor(HooplabTheme.textSecondary)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - 2. Collectible NBA Prizm Player Card
    private func nbaPlayerCardSection(isEn: Bool) -> some View {
        VStack(spacing: 10) {
            NbaCollectibleCardView(
                playerName: dataStore.playerName,
                avatarImage: dataStore.avatarImage,
                positionCode: dataStore.playerPosition.code,
                jerseyNumber: dataStore.playerJersey,
                skills: dataStore.playerSkills,
                isEn: isEn,
                photoPickerItem: $selectedPhotoItem,
                onTapPosition: {
                    SoundAndHaptics.shared.vibrateClick()
                    showPositionPicker = true
                },
                onTapJersey: {
                    SoundAndHaptics.shared.vibrateClick()
                    jerseyInput = "\(dataStore.playerJersey)"
                    showJerseyAlert = true
                }
            )

            Button {
                SoundAndHaptics.shared.vibrateClick()
                shareNbaCard(isEn: isEn)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .bold))
                    Text(isEn ? "Share Player Card" : "Поделиться карточкой")
                        .font(.geist(14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(HooplabTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 3. Quick Profile Edit Row
    private func quickEditButtonsRow(isEn: Bool) -> some View {
        HStack(spacing: 10) {
            Button {
                SoundAndHaptics.shared.vibrateClick()
                nameInput = dataStore.playerName
                showNameAlert = true
            } label: {
                editPill(icon: "pencil", title: isEn ? "Name" : "Имя")
            }
            .buttonStyle(.plain)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                editPill(icon: "camera.fill", title: isEn ? "Photo" : "Фото")
            }
            .buttonStyle(.plain)

            Button {
                SoundAndHaptics.shared.vibrateClick()
                showPasswordSheet = true
            } label: {
                editPill(icon: "key.fill", title: isEn ? "Password" : "Пароль")
            }
            .buttonStyle(.plain)
        }
    }

    private func editPill(icon: String, title: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(HooplabTheme.primary)
            Text(title)
                .font(.geist(13, weight: .semibold))
                .foregroundColor(HooplabTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(HooplabTheme.glassFill)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(HooplabTheme.glassStroke, lineWidth: 1))
    }

    // MARK: - 4. Quick Stats Summary Card
    private func quickStatsSummaryCard(isEn: Bool) -> some View {
        let stats = dataStore.computeStatsUiState()
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isEn ? "WORKOUT PROGRESS" : "ПРОГРЕСС ТРЕНИРОВОК")
                    .font(.geist(12, weight: .bold))
                    .foregroundColor(HooplabTheme.primary)
                Spacer()
                NavigationLink {
                    StatsView()
                } label: {
                    Text(isEn ? "Details →" : "Подробнее →")
                        .font(.geist(13, weight: .bold))
                        .foregroundColor(HooplabTheme.primary)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 0) {
                miniStat(value: "\(stats.totalSessions)", label: isEn ? "Drills" : "Тренировок")
                Divider().frame(height: 32).overlay(HooplabTheme.divider)
                miniStat(value: "\(stats.totalDurationSec / 60) \(isEn ? "m" : "мин")", label: isEn ? "Active Time" : "В игре")
                Divider().frame(height: 32).overlay(HooplabTheme.divider)
                miniStat(value: "\(stats.streakDays) 🔥", label: isEn ? "Streak" : "Серия")
            }
        }
        .hooplabCard(padding: 16)
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.geist(18, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)
            Text(label)
                .font(.geist(11, weight: .medium))
                .foregroundColor(HooplabTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 5. Hoop IQ Quiz Progress Card
    private func quizProgressCard(isEn: Bool) -> some View {
        let answered = dataStore.answeredQuestionIds.count
        let total = max(1, dataStore.totalQuizQuestionsCount)
        let progress = min(1.0, Double(answered) / Double(total))

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(isEn ? "🧠 Hoop IQ Quiz" : "🧠 Викторина Hoop IQ")
                        .font(.geist(17, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)

                    Text(
                        isEn
                        ? "Answered: \(answered)/\(total) • Correct: \(dataStore.quizScore)"
                        : "Пройдено: \(answered)/\(total) • Верных: \(dataStore.quizScore)"
                    )
                    .font(.geist(12, weight: .regular))
                    .foregroundColor(HooplabTheme.textSecondary)
                }
                Spacer()
                Text("+\(dataStore.quizScore) XP")
                    .font(.geist(12, weight: .bold))
                    .foregroundColor(HooplabTheme.accentSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(HooplabTheme.accentSecondary.opacity(0.15))
                    .clipShape(Capsule())
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(HooplabTheme.nbaSkillTrack)
                        .frame(height: 8)
                    Capsule()
                        .fill(HooplabTheme.primary)
                        .frame(width: max(0, geo.size.width * progress), height: 8)
                }
            }
            .frame(height: 8)

            Button {
                SoundAndHaptics.shared.vibrateClick()
                showQuizSheet = true
            } label: {
                Text(
                    answered >= total
                    ? (isEn ? "View Quiz Results" : "Посмотреть итоги")
                    : (isEn ? "Continue Hoop IQ Quiz" : "Продолжить квиз")
                )
                .font(.geist(14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(HooplabTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .hooplabCard(padding: 16)
    }

    // MARK: - 6. 13 NBA Achievement Badges
    private func badgesSection(isEn: Bool) -> some View {
        let unlockedCount = dataStore.playerBadges.filter { $0.isUnlocked }.count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isEn ? "Achievements" : "Награды и бейджи")
                    .font(.geist(HooplabDimens.textSection, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)
                Spacer()
                Text("\(unlockedCount)/\(dataStore.playerBadges.count)")
                    .font(.geist(14, weight: .bold))
                    .foregroundColor(HooplabTheme.primary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(dataStore.playerBadges) { badge in
                        Button {
                            SoundAndHaptics.shared.vibrateClick()
                            selectedBadgeForInfo = badge
                        } label: {
                            VStack(spacing: 6) {
                                Text(badge.emoji)
                                    .font(.system(size: 30))
                                    .grayscale(badge.isUnlocked ? 0 : 0.9)
                                    .opacity(badge.isUnlocked ? 1 : 0.45)

                                Text(badge.localizedTitle(isEn: isEn))
                                    .font(.geist(12, weight: .bold))
                                    .foregroundColor(HooplabTheme.textPrimary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)

                                Text(badge.isUnlocked ? badge.tier : badge.progressText)
                                    .font(.geist(10, weight: .bold))
                                    .foregroundColor(badge.isUnlocked ? HooplabTheme.accentSecondary : HooplabTheme.textSecondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        badge.isUnlocked
                                        ? HooplabTheme.accentSecondary.opacity(0.15)
                                        : HooplabTheme.bgInput
                                    )
                                    .clipShape(Capsule())
                            }
                            .frame(width: 128, height: 132)
                            .hooplabCard(
                                padding: 10,
                                strokeColor: badge.isUnlocked ? HooplabTheme.accentSecondary.opacity(0.75) : nil
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - 7. Navigation Hub Rows
    private func navigationHubSection(isEn: Bool) -> some View {
        VStack(spacing: 10) {
            NavigationLink {
                LeaderboardView()
            } label: {
                hubRow(
                    icon: "trophy.fill",
                    iconColor: Color(hex: "F59E0B"),
                    title: isEn ? "Top-50 Leaderboard" : "Рейтинг игроков (Топ-50)",
                    subtitle: isEn ? "Compare your OVR with athletes" : "Сравни свой OVR с другими атлетами"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                CourtsView()
            } label: {
                hubRow(
                    icon: "mappin.and.ellipse",
                    iconColor: HooplabTheme.accentSecondary,
                    title: isEn ? "Streetball Courts" : "Стритбол площадки",
                    subtitle: isEn ? "Check in & find nearest hoops" : "Чек-ин на корте и ближайшие кольца"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                StatsView()
            } label: {
                hubRow(
                    icon: "chart.bar.fill",
                    iconColor: HooplabTheme.primary,
                    title: isEn ? "Detailed Statistics" : "Подробная статистика",
                    subtitle: isEn ? "7-day chart & personal records" : "График недели и личные рекорды"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func hubRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(iconColor)
                .frame(width: 42, height: 42)
                .background(iconColor.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.geist(15, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)
                Text(subtitle)
                    .font(.geist(12, weight: .regular))
                    .foregroundColor(HooplabTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(HooplabTheme.textHint)
        }
        .hooplabCard(padding: 14)
    }

    // MARK: - 8. Settings Card
    private func settingsCard(isEn: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(isEn ? "SETTINGS" : "НАСТРОЙКИ")
                .font(.geist(12, weight: .bold))
                .foregroundColor(HooplabTheme.primary)

            Toggle(isOn: Binding(
                get: { dataStore.notificationsEnabled },
                set: { dataStore.setNotificationsEnabled($0) }
            )) {
                HStack(spacing: 10) {
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(HooplabTheme.primary)
                    Text(isEn ? "Workout Reminders" : "Напоминания о тренировках")
                        .font(.geist(15, weight: .medium))
                        .foregroundColor(HooplabTheme.textPrimary)
                }
            }
            .tint(HooplabTheme.primary)

            Divider().overlay(HooplabTheme.divider)

            Toggle(isOn: Binding(
                get: { dataStore.isDarkTheme },
                set: { dataStore.setDarkTheme($0) }
            )) {
                HStack(spacing: 10) {
                    Image(systemName: dataStore.isDarkTheme ? "moon.stars.fill" : "sun.max.fill")
                        .foregroundColor(HooplabTheme.primary)
                    Text(isEn ? "Dark Theme" : "Тёмная тема")
                        .font(.geist(15, weight: .medium))
                        .foregroundColor(HooplabTheme.textPrimary)
                }
            }
            .tint(HooplabTheme.primary)

            Divider().overlay(HooplabTheme.divider)

            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "globe")
                        .foregroundColor(HooplabTheme.primary)
                    Text(isEn ? "Language" : "Язык приложения")
                        .font(.geist(15, weight: .medium))
                        .foregroundColor(HooplabTheme.textPrimary)
                }
                Spacer()
                Picker("", selection: Binding(
                    get: { dataStore.isEnglish },
                    set: { dataStore.setLanguage(isEn: $0) }
                )) {
                    Text("Русский").tag(false)
                    Text("English").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 165)
            }
        }
        .hooplabCard(padding: 16)
    }

    // MARK: - 9. Logout & Delete Account
    private func accountActionsSection(isEn: Bool) -> some View {
        VStack(spacing: 10) {
            Button {
                SoundAndHaptics.shared.vibrateClick()
                dataStore.logout()
            } label: {
                Text(isEn ? "Log Out" : "Выйти из аккаунта")
                    .font(.geist(15, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(HooplabTheme.glassFill)
                    .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusButton))
                    .overlay(RoundedRectangle(cornerRadius: HooplabDimens.radiusButton).stroke(HooplabTheme.glassStroke, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Button {
                SoundAndHaptics.shared.vibrateClick()
                showDeleteConfirm = true
            } label: {
                Text(isEn ? "Delete Account" : "Удалить аккаунт")
                    .font(.geist(15, weight: .bold))
                    .foregroundColor(HooplabTheme.error)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(HooplabTheme.error.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusButton))
                    .overlay(RoundedRectangle(cornerRadius: HooplabDimens.radiusButton).stroke(HooplabTheme.error.opacity(0.35), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private func performAccountDelete(password: String?) {
        Task {
            let outcome = await dataStore.deleteAccount(password: password)
            await MainActor.run {
                switch outcome {
                case .success:
                    break
                case .requiresRecentLogin:
                    showDeleteReauthAlert = true
                case .failure(let msg):
                    dataStore.showToast(msg)
                }
            }
        }
    }

    @MainActor
    private func shareNbaCard(isEn: Bool) {
        let cardSnapshot = NbaCollectibleCardView(
            playerName: dataStore.playerName,
            avatarImage: dataStore.avatarImage,
            positionCode: dataStore.playerPosition.code,
            jerseyNumber: dataStore.playerJersey,
            skills: dataStore.playerSkills,
            isEn: isEn,
            photoPickerItem: .constant(nil),
            onTapPosition: {},
            onTapJersey: {},
            isInteractive: false
        )
        .frame(width: 360)
        .padding(16)
        .background(Color(hex: "0B0E14"))

        let renderer = ImageRenderer(content: cardSnapshot)
        renderer.scale = 2.0

        let caption = isEn
            ? "Check out my Hooplab Player Card: \(dataStore.playerSkills.ovr) OVR (\(dataStore.playerSkills.tierTitle))! 🏀🔥"
            : "Моя карточка игрока в Hooplab: \(dataStore.playerSkills.ovr) OVR (\(dataStore.playerSkills.tierTitle))! 🏀🔥"

        if let uiImage = renderer.uiImage {
            shareSheetPayload = ShareCardPayload(items: [uiImage, caption])
        } else {
            shareSheetPayload = ShareCardPayload(items: [caption])
        }
    }
}

// MARK: - Standalone Panini Prizm NBA Player Card View
private struct NbaCollectibleCardView: View {
    let playerName: String
    let avatarImage: UIImage?
    let positionCode: String
    let jerseyNumber: Int
    let skills: PlayerStatsSkills
    let isEn: Bool
    @Binding var photoPickerItem: PhotosPickerItem?
    let onTapPosition: () -> Void
    let onTapJersey: () -> Void
    var isInteractive: Bool = true

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "0F172A"), Color(hex: "1E293B"), Color(hex: "111827")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Diagonal Prizm metallic highlight
            LinearGradient(
                colors: [Color.white.opacity(0.08), Color.clear, Color(hex: "F59E0B").opacity(0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))

            VStack(spacing: 16) {
                // Top Row: Position + Jersey + Gold OVR Badge
                HStack(alignment: .center) {
                    HStack(spacing: 8) {
                        Button(action: onTapPosition) {
                            Text(isInteractive ? "\(positionCode) ▾" : positionCode)
                                .font(.geist(13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.12))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(!isInteractive)

                        Button(action: onTapJersey) {
                            Text(isInteractive ? "#\(jerseyNumber) ▾" : "#\(jerseyNumber)")
                                .font(.geist(13, weight: .bold))
                                .foregroundColor(Color(hex: "FBBF24"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "F59E0B").opacity(0.15))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color(hex: "F59E0B").opacity(0.35), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(!isInteractive)
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Text("\(skills.ovr)")
                            .font(.geist(22, weight: .bold))
                        Text("OVR")
                            .font(.geist(10, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(HooplabTheme.ovrBadgeGradient)
                    .clipShape(Capsule())
                }

                // Avatar + Player Identity
                HStack(spacing: 14) {
                    if isInteractive {
                        PhotosPicker(selection: $photoPickerItem, matching: .images) {
                            avatarCircle
                        }
                        .buttonStyle(.plain)
                    } else {
                        avatarCircle
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(playerName.uppercased())
                            .font(.geist(21, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text(skills.tierTitle)
                            .font(.geist(12, weight: .bold))
                            .foregroundColor(Color(hex: "FBBF24"))

                        Text("HOOPLAB PRO EDITION")
                            .font(.geist(10, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(1.1)
                    }

                    Spacer()
                }

                // 5 NBA Skill Bars
                VStack(spacing: 9) {
                    skillBar(label: isEn ? "SHOOTING" : "БРОСОК (SHT)", value: skills.shooting, color: Color(hex: "FF5500"))
                    skillBar(label: isEn ? "FINISHING" : "ПРОХОД (FIN)", value: skills.finishing, color: Color(hex: "3B82F6"))
                    skillBar(label: isEn ? "DEFENSE" : "ЗАЩИТА (DEF)", value: skills.defense, color: Color(hex: "A3FF12"))
                    skillBar(label: isEn ? "PLAYMAKING" : "МЫШЛЕНИЕ (PLY)", value: skills.playmaking, color: Color(hex: "D946EF"))
                    skillBar(label: isEn ? "ATHLETICISM" : "АТЛЕТИЗМ (ATH)", value: skills.athleticism, color: Color(hex: "FBBF24"))
                }
            }
            .padding(18)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "FBBF24").opacity(0.65), Color.white.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }

    private var avatarCircle: some View {
        ZStack(alignment: .bottomTrailing) {
            if let img = avatarImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 74, height: 74)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FF5500"), Color(hex: "D97706")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 74, height: 74)
                    .overlay(
                        Text(String(playerName.prefix(1)).uppercased())
                            .font(.geist(28, weight: .bold))
                            .foregroundColor(.white)
                    )
            }

            if isInteractive {
                Image(systemName: "camera.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(Color(hex: "FF5500"))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(hex: "0F172A"), lineWidth: 2))
            }
        }
        .overlay(Circle().stroke(Color(hex: "FBBF24").opacity(0.8), lineWidth: 2))
    }

    private func skillBar(label: String, value: Int, color: Color) -> some View {
        let ratio = max(0, min(1, Double(value - 50) / 50.0))
        return VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.geist(10, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("\(value)")
                    .font(.geist(11, weight: .bold))
                    .foregroundColor(color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 6)
                    Capsule()
                        .fill(color)
                        .frame(width: max(8, geo.size.width * ratio), height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Change Password Sheet (1:1 Android dialog_change_password.xml)
private struct ChangePasswordSheet: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss

    let isEn: Bool
    @State private var currentPass: String = ""
    @State private var newPass: String = ""
    @State private var confirmPass: String = ""
    @State private var errorMsg: String? = nil
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                SecureField(isEn ? "Current password" : "Текущий пароль", text: $currentPass)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(HooplabTheme.bgInput)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(HooplabTheme.glassStroke, lineWidth: 1))

                SecureField(isEn ? "New password (min 6 chars)" : "Новый пароль (от 6 символов)", text: $newPass)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(HooplabTheme.bgInput)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(HooplabTheme.glassStroke, lineWidth: 1))

                SecureField(isEn ? "Repeat new password" : "Повторите новый пароль", text: $confirmPass)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(HooplabTheme.bgInput)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(HooplabTheme.glassStroke, lineWidth: 1))

                if let errorMsg {
                    Text(errorMsg)
                        .font(.geist(13, weight: .medium))
                        .foregroundColor(HooplabTheme.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    submit()
                } label: {
                    HStack {
                        if isLoading { ProgressView().tint(.white) }
                        Text(isEn ? "Update Password" : "Обновить пароль")
                            .font(.geist(15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: HooplabDimens.buttonHeight)
                    .background(HooplabTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusButton))
                }
                .disabled(isLoading)
                .padding(.top, 6)

                Spacer()
            }
            .padding(HooplabDimens.screenPaddingH)
            .hooplabAurora()
            .navigationTitle(isEn ? "Change Password" : "Смена пароля")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(isEn ? "Cancel" : "Отмена") { dismiss() }
                        .foregroundColor(HooplabTheme.primary)
                }
            }
        }
    }

    private func submit() {
        errorMsg = nil
        guard !currentPass.isEmpty else {
            errorMsg = isEn ? "Enter your current password" : "Введите текущий пароль"
            return
        }
        guard newPass.count >= 6 else {
            errorMsg = isEn ? "Password must be at least 6 characters" : "Минимум 6 символов"
            return
        }
        guard newPass == confirmPass else {
            errorMsg = isEn ? "Passwords do not match" : "Пароли не совпадают"
            return
        }
        isLoading = true
        Task {
            let ok = await dataStore.changePassword(currentPassword: currentPass, newPassword: newPass)
            await MainActor.run {
                isLoading = false
                if ok {
                    dataStore.showToast(isEn ? "Password updated" : "Пароль успешно изменён")
                    dismiss()
                } else {
                    errorMsg = isEn ? "Current password is incorrect" : "Неверный текущий пароль"
                }
            }
        }
    }
}

private struct ShareCardPayload: Identifiable {
    let id = UUID()
    let items: [Any]
}

private struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
