import SwiftUI

// MARK: - Top-50 Leaderboard Screen (1:1 Android activity_leaderboard.xml + PlayerDetailBottomSheet)
public struct LeaderboardView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedUser: LeaderboardUser? = nil
    @State private var isLoading: Bool = false

    public init() {}

    public var body: some View {
        let isEn = dataStore.isEnglish
        let currentUser = dataStore.leaderboardUsers.first { $0.isCurrentUser }

        VStack(spacing: 0) {
            HooplabTopBar(
                title: isEn ? "Top-50 Players" : "Рейтинг игроков",
                subtitle: isEn ? "Global Hooplab OVR Leaderboard" : "Топ-50 атлетов Hooplab",
                trailingView: AnyView(
                    Button {
                        SoundAndHaptics.shared.vibrateClick()
                        Task {
                            isLoading = true
                            await dataStore.loadLeaderboard()
                            isLoading = false
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(width: 40, height: 40)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(HooplabTheme.textPrimary)
                                .frame(width: 40, height: 40)
                                .background(HooplabTheme.glassFill)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(HooplabTheme.glassStroke, lineWidth: 1))
                        }
                    }
                    .buttonStyle(.plain)
                )
            )

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(dataStore.leaderboardUsers) { user in
                        Button {
                            SoundAndHaptics.shared.vibrateClick()
                            selectedUser = user
                        } label: {
                            LeaderboardRowView(user: user, isEn: isEn)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HooplabDimens.screenPaddingH)
                .padding(.top, 4)
                .padding(.bottom, 20)
            }
            .refreshable {
                await dataStore.loadLeaderboard()
            }

            // Sticky Current User Rank Bar (currentUserBar)
            if let me = currentUser {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Text("#\(me.rank)")
                            .font(.geist(16, weight: .bold))
                            .foregroundColor(HooplabTheme.primary)
                            .frame(minWidth: 38, alignment: .leading)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(me.name)
                                    .font(.geist(15, weight: .bold))
                                    .foregroundColor(HooplabTheme.textPrimary)
                                    .lineLimit(1)
                                Text(isEn ? "YOU" : "ВЫ")
                                    .font(.geist(9, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(HooplabTheme.primary)
                                    .clipShape(Capsule())
                            }
                            Text("\(me.position) • #\(me.jerseyNumber) • 🔥 \(me.streak)")
                                .font(.geist(12, weight: .regular))
                                .foregroundColor(HooplabTheme.textSecondary)
                        }

                        Spacer()

                        Text("\(me.ovr) OVR")
                            .font(.geist(13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(HooplabTheme.ovrBadgeGradient)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, HooplabDimens.screenPaddingH)
                    .padding(.vertical, 12)
                    .background(HooplabTheme.bgNav.opacity(0.94))
                    .overlay(
                        Rectangle()
                            .fill(HooplabTheme.glassStroke)
                            .frame(height: 1),
                        alignment: .top
                    )
                }
            }
        }
        .hooplabAurora()
        .toolbar(.hidden, for: .navigationBar)
        .enableSwipeBack()
        .task {
            if dataStore.leaderboardUsers.isEmpty {
                isLoading = true
                await dataStore.loadLeaderboard()
                isLoading = false
            } else {
                await dataStore.loadLeaderboard()
            }
        }
        .sheet(item: $selectedUser) { user in
            PlayerDetailBottomSheet(user: user, isEn: isEn)
        }
    }
}

// MARK: - 1:1 Android item_leaderboard_user.xml
private struct LeaderboardRowView: View {
    let user: LeaderboardUser
    let isEn: Bool

    var body: some View {
        HStack(spacing: 12) {
            rankBadge(rank: user.rank)
                .frame(width: 34)

            ZStack {
                Circle()
                    .fill(user.isCurrentUser ? HooplabTheme.fireBg : HooplabTheme.bgInput)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Circle().stroke(
                            user.isCurrentUser ? HooplabTheme.primary : HooplabTheme.glassStroke,
                            lineWidth: 1.5
                        )
                    )
                Text(String(user.name.prefix(1)).uppercased())
                    .font(.geist(16, weight: .bold))
                    .foregroundColor(user.isCurrentUser ? HooplabTheme.primary : HooplabTheme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(user.name)
                        .font(.geist(15, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)
                        .lineLimit(1)

                    if user.isCurrentUser {
                        Text(isEn ? "YOU" : "ВЫ")
                            .font(.geist(9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(HooplabTheme.primary)
                            .clipShape(Capsule())
                    }
                }

                Text("\(user.position) • #\(user.jerseyNumber) • 🔥 \(user.streak) • 🧠 \(user.quizScore)")
                    .font(.geist(12, weight: .regular))
                    .foregroundColor(HooplabTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 1) {
                Text("\(user.ovr)")
                    .font(.geist(15, weight: .bold))
                Text("OVR")
                    .font(.geist(8, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(HooplabTheme.ovrBadgeGradient)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .hooplabCard(
            padding: 12,
            strokeColor: user.isCurrentUser ? HooplabTheme.primary : nil
        )
    }

    @ViewBuilder
    private func rankBadge(rank: Int) -> some View {
        switch rank {
        case 1:
            Text("🥇").font(.system(size: 22))
        case 2:
            Text("🥈").font(.system(size: 22))
        case 3:
            Text("🥉").font(.system(size: 22))
        default:
            Text("#\(rank)")
                .font(.geist(14, weight: .bold))
                .foregroundColor(HooplabTheme.textSecondary)
        }
    }
}

// MARK: - 1:1 Android dialog_player_detail_bottom_sheet.xml
private struct PlayerDetailBottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    let user: LeaderboardUser
    let isEn: Bool

    var body: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(HooplabTheme.glassStroke)
                .frame(width: 44, height: 5)
                .padding(.top, 10)

            // Gold OVR Emblem
            VStack(spacing: 4) {
                Text("\(user.ovr)")
                    .font(.geist(36, weight: .bold))
                Text("OVR")
                    .font(.geist(11, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(width: 92, height: 92)
            .background(HooplabTheme.ovrBadgeGradient)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.45), lineWidth: 2))

            VStack(spacing: 6) {
                Text(user.name)
                    .font(.geist(22, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)

                Text(user.tierTitle)
                    .font(.geist(13, weight: .bold))
                    .foregroundColor(Color(hex: "F59E0B"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(hex: "F59E0B").opacity(0.16))
                    .clipShape(Capsule())

                Text(
                    isEn
                    ? "Rank #\(user.rank) • Position \(user.position) • #\(user.jerseyNumber)"
                    : "Ранг #\(user.rank) • Позиция \(user.position) • #\(user.jerseyNumber)"
                )
                .font(.geist(14, weight: .medium))
                .foregroundColor(HooplabTheme.textSecondary)
                .padding(.top, 2)
            }

            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("🔥 \(user.streak)")
                        .font(.geist(20, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)
                    Text(isEn ? "Day Streak" : "Дней подряд")
                        .font(.geist(12, weight: .medium))
                        .foregroundColor(HooplabTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .hooplabCard(padding: 14)

                VStack(spacing: 4) {
                    Text("🧠 \(user.quizScore)")
                        .font(.geist(20, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)
                    Text(isEn ? "Hoop IQ Points" : "Очки Hoop IQ")
                        .font(.geist(12, weight: .medium))
                        .foregroundColor(HooplabTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .hooplabCard(padding: 14)
            }
            .padding(.horizontal, HooplabDimens.screenPaddingH)

            Button {
                SoundAndHaptics.shared.vibrateClick()
                dismiss()
            } label: {
                Text(isEn ? "Close" : "Закрыть")
                    .font(.geist(15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(HooplabTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusButton))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, HooplabDimens.screenPaddingH)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .hooplabAurora()
        .presentationDetents([.medium])
    }
}
