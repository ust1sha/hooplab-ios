import SwiftUI

public struct CourtsView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var courts: [StreetballCourt] = CourtsData.sampleCourts

    public var body: some View {
        ZStack {
            Color.clear
                .hooplabAurora()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dataStore.isEnglish ? "Streetball Courts" : "Стритбольные площадки")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(HooplabTheme.textPrimary)
                        Text(dataStore.isEnglish ? "Top basketball spots in Moscow" : "Лучшие баскетбольные споты Москвы")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(HooplabTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(HooplabTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(courts) { court in
                            courtCard(court)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func courtCard(_ court: StreetballCourt) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(court.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)

                    Text(court.address)
                        .font(.system(size: 13))
                        .foregroundColor(HooplabTheme.textSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11))
                    Text("\(court.activePlayersCount)")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(HooplabTheme.orangeSoft)
                .foregroundColor(HooplabTheme.orangePrimary)
                .cornerRadius(8)
            }

            Divider()
                .background(HooplabTheme.cardBorder)

            HStack(spacing: 16) {
                HStack(spacing: 5) {
                    Image(systemName: "circle.grid.cross")
                        .foregroundColor(HooplabTheme.orangePrimary)
                        .font(.system(size: 12))
                    Text("\(court.rimsCount) \(dataStore.isEnglish ? "rims" : "колец")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(HooplabTheme.textSecondary)
                }

                HStack(spacing: 5) {
                    Image(systemName: "square.fill")
                        .foregroundColor(Color(hex: "2563EB"))
                        .font(.system(size: 10))
                    Text(court.localizedSurface(isEn: dataStore.isEnglish))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(HooplabTheme.textSecondary)
                }

                Spacer()

                if court.hasLighting {
                    HStack(spacing: 4) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(Color(hex: "D97706"))
                            .font(.system(size: 11))
                        Text(dataStore.isEnglish ? "Light" : "Освещение")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "D97706"))
                    }
                }
            }
        }
        .hooplabCard(padding: 14, cornerRadius: 18)
    }
}
