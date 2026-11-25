import SwiftUI

// MARK: - Detailed Statistics Screen (1:1 Android activity_stats.xml)
public struct StatsView: View {
    @EnvironmentObject var dataStore: DataStore

    public init() {}

    public var body: some View {
        let isEn = dataStore.isEnglish
        let stats = dataStore.computeStatsUiState()

        VStack(spacing: 0) {
            HooplabTopBar(
                title: isEn ? "Statistics" : "Статистика",
                subtitle: isEn ? "Training Activity & Personal Records" : "Активность тренировок и рекорды"
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // KPI Summary Card
                    HStack(spacing: 12) {
                        kpiTile(
                            value: "\(stats.totalSessions)",
                            label: isEn ? "Workouts" : "Тренировок",
                            icon: "figure.basketball",
                            tint: HooplabTheme.primary
                        )

                        kpiTile(
                            value: formatTotalTime(stats.totalDurationSec, isEn: isEn),
                            label: isEn ? "Total Time" : "Общее время",
                            icon: "clock.fill",
                            tint: Color(hex: "3B82F6")
                        )

                        kpiTile(
                            value: "\(stats.streakDays)",
                            label: isEn ? "Streak (d)" : "Серия (дн.)",
                            icon: "flame.fill",
                            tint: HooplabTheme.accentSecondary
                        )
                    }

                    // 7-Day Activity Bar Chart (item_stats_bar.xml)
                    VStack(alignment: .leading, spacing: 12) {
                        Text(isEn ? "📅 LAST 7 DAYS" : "📅 АКТИВНОСТЬ ЗА 7 ДНЕЙ")
                            .font(.geist(12, weight: .bold))
                            .foregroundColor(HooplabTheme.primary)

                        let maxCount = max(1, stats.weekly.map { $0.count }.max() ?? 1)
                        if stats.weekly.isEmpty {
                            emptyRowText(isEn ? "Complete your first workout to track weekly volume." : "Завершите первую тренировку, чтобы видеть график недели.")
                        } else {
                            ForEach(Array(stats.weekly.enumerated()), id: \.offset) { _, day in
                                HStack(spacing: 10) {
                                    Text(day.label)
                                        .font(.geist(12, weight: .bold))
                                        .foregroundColor(HooplabTheme.textSecondary)
                                        .frame(width: 28, alignment: .leading)

                                    GeometryReader { geo in
                                        let ratio = Double(day.count) / Double(maxCount)
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(HooplabTheme.nbaSkillTrack)
                                                .frame(height: 10)
                                            if day.count > 0 {
                                                Capsule()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [HooplabTheme.primary, HooplabTheme.accentSecondary],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .frame(width: max(14, geo.size.width * ratio), height: 10)
                                            }
                                        }
                                    }
                                    .frame(height: 10)

                                    Text("\(day.count)")
                                        .font(.geist(12, weight: .bold))
                                        .foregroundColor(day.count > 0 ? HooplabTheme.textPrimary : HooplabTheme.textHint)
                                        .frame(width: 24, alignment: .trailing)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .hooplabCard(padding: 16)

                    // Top-3 Exercises (item_top_exercise.xml)
                    VStack(alignment: .leading, spacing: 12) {
                        Text(isEn ? "⭐ TOP DRILLS" : "⭐ ТОП УПРАЖНЕНИЙ")
                            .font(.geist(12, weight: .bold))
                            .foregroundColor(HooplabTheme.primary)

                        if stats.topExercises.isEmpty {
                            emptyRowText(isEn ? "Your favorite drills will appear here." : "Здесь появятся ваши самые частые упражнения.")
                        } else {
                            ForEach(Array(stats.topExercises.enumerated()), id: \.offset) { idx, item in
                                HStack(spacing: 12) {
                                    Text(medalForRank(idx + 1))
                                        .font(.system(size: 20))
                                        .frame(width: 28)

                                    Text(item.name)
                                        .font(.geist(14, weight: .semibold))
                                        .foregroundColor(HooplabTheme.textPrimary)
                                        .lineLimit(2)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text("\(item.count)x")
                                        .font(.geist(14, weight: .bold))
                                        .foregroundColor(HooplabTheme.primary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(HooplabTheme.fireBg)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .hooplabCard(padding: 16)

                    // Personal Records Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text(isEn ? "🏆 PERSONAL RECORDS" : "🏆 ЛИЧНЫЕ РЕКОРДЫ")
                            .font(.geist(12, weight: .bold))
                            .foregroundColor(HooplabTheme.primary)

                        recordRow(
                            title: isEn ? "Longest Streak" : "Лучшая серия дней",
                            value: "\(stats.bestStreak) " + (isEn ? "days" : "дн."),
                            icon: "flame.fill"
                        )
                        Divider().overlay(HooplabTheme.divider)
                        recordRow(
                            title: isEn ? "Most Workouts in a Day" : "Максимум за день",
                            value: "\(stats.maxSessionsPerDay)",
                            icon: "bolt.fill"
                        )
                        Divider().overlay(HooplabTheme.divider)
                        recordRow(
                            title: isEn ? "Longest Session" : "Самая долгая тренировка",
                            value: formatTotalTime(stats.longestSessionSec, isEn: isEn),
                            icon: "timer"
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .hooplabCard(padding: 16)
                }
                .padding(.horizontal, HooplabDimens.screenPaddingH)
                .padding(.top, 6)
                .padding(.bottom, 28)
            }
        }
        .hooplabAurora()
        .toolbar(.hidden, for: .navigationBar)
        .enableSwipeBack()
    }

    private func kpiTile(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(tint)
            Text(value)
                .font(.geist(22, weight: .bold))
                .foregroundColor(HooplabTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(label)
                .font(.geist(11, weight: .medium))
                .foregroundColor(HooplabTheme.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hooplabCard(padding: 14)
    }

    private func recordRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(HooplabTheme.primary)
                .frame(width: 24)
            Text(title)
                .font(.geist(14, weight: .medium))
                .foregroundColor(HooplabTheme.textPrimary)
            Spacer()
            Text(value)
                .font(.geist(14, weight: .bold))
                .foregroundColor(HooplabTheme.primary)
        }
    }

    private func emptyRowText(_ msg: String) -> some View {
        Text(msg)
            .font(.geist(13, weight: .regular))
            .foregroundColor(HooplabTheme.textSecondary)
    }

    private func medalForRank(_ rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "•"
        }
    }

    private func formatTotalTime(_ sec: Int, isEn: Bool) -> String {
        if sec <= 0 { return isEn ? "0m" : "0 мин" }
        let mins = sec / 60
        if mins >= 60 {
            let hrs = mins / 60
            let rem = mins % 60
            return isEn ? "\(hrs)h \(rem)m" : "\(hrs)ч \(rem)м"
        } else if mins > 0 {
            return isEn ? "\(mins)m" : "\(mins) мин"
        } else {
            return isEn ? "\(sec)s" : "\(sec) сек"
        }
    }
}
