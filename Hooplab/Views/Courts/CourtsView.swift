import SwiftUI

public struct CourtsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var courts: [StreetballCourt] = CourtsData.sampleCourts

    public var body: some View {
        NavigationStack {
            ZStack {
                HooplabTheme.bgDark.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(dataStore.isEnglish ? "POPULAR BASKETBALL COURTS" : "ПОПУЛЯРНЫЕ СТРИТБОЛЬНЫЕ КОРТЫ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(HooplabTheme.textMuted)
                            .tracking(1)
                            .padding(.horizontal, 16)

                        ForEach(courts) { court in
                            courtCard(court)
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(dataStore.isEnglish ? "Courts" : "Площадки")
        }
    }

    private func courtCard(_ court: StreetballCourt) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(court.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Text(court.address)
                        .font(.system(size: 14))
                        .foregroundColor(HooplabTheme.textSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                    Text("\(court.activePlayersCount)")
                        .font(.system(size: 13, weight: .bold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(HooplabTheme.orangePrimary.opacity(0.2))
                .foregroundColor(HooplabTheme.orangePrimary)
                .cornerRadius(8)
            }

            Divider().background(HooplabTheme.borderDark)

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "circle.grid.cross")
                        .foregroundColor(HooplabTheme.orangePrimary)
                    Text("\(court.rimsCount) \(dataStore.isEnglish ? "rims" : "колец")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(HooplabTheme.textSecondary)
                }

                HStack(spacing: 6) {
                    Image(systemName: "square.fill")
                        .foregroundColor(Color.blue)
                    Text(court.localizedSurface(isEn: dataStore.isEnglish))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(HooplabTheme.textSecondary)
                }

                Spacer()

                if court.hasLighting {
                    HStack(spacing: 4) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text(dataStore.isEnglish ? "Light" : "Свет")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .hooplabCard(padding: 16)
        .padding(.horizontal, 16)
    }
}
