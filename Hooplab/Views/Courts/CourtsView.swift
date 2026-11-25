import SwiftUI
import CoreLocation

// MARK: - CoreLocation Helper for Nearest Court Sorting
final class CourtsLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation? = nil

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestAndUpdate() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silently degrade if location unavailable
    }
}

// MARK: - Streetball Courts Screen (1:1 Android activity_courts.xml + CourtsActivity.kt)
public struct CourtsView: View {
    @EnvironmentObject var dataStore: DataStore
    @StateObject private var locationManager = CourtsLocationManager()

    @State private var searchQuery: String = ""
    @State private var showAddCourtSheet: Bool = false

    public init() {}

    public var body: some View {
        let isEn = dataStore.isEnglish
        let sortedCourts = filteredAndSortedCourts()

        VStack(spacing: 0) {
            HooplabTopBar(
                title: isEn ? "Streetball Courts" : "Площадки",
                subtitle: isEn ? "Find a court & check in" : "Найди корт и отметься",
                trailingView: AnyView(
                    Button {
                        SoundAndHaptics.shared.vibrateClick()
                        showAddCourtSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(HooplabTheme.primary)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                )
            )

            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(HooplabTheme.textSecondary)
                TextField(isEn ? "Search city, court, street..." : "Поиск по городу, названию, улице...", text: $searchQuery)
                    .font(.geist(15, weight: .regular))
                    .foregroundColor(HooplabTheme.textPrimary)
                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(HooplabTheme.textHint)
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(HooplabTheme.bgInput)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(HooplabTheme.glassStroke, lineWidth: 1))
            .padding(.horizontal, HooplabDimens.screenPaddingH)
            .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    ForEach(sortedCourts) { court in
                        StreetballCourtCard(
                            court: court,
                            isEn: isEn,
                            onCheckIn: {
                                SoundAndHaptics.shared.mediumTap()
                                dataStore.toggleCourtCheckIn(court)
                            },
                            onOpenRoute: {
                                SoundAndHaptics.shared.vibrateClick()
                                openMapsRoute(for: court)
                            }
                        )
                    }
                }
                .padding(.horizontal, HooplabDimens.screenPaddingH)
                .padding(.top, 2)
                .padding(.bottom, 28)
            }
            .refreshable {
                await dataStore.refreshCourts()
            }
        }
        .hooplabAurora()
        .toolbar(.hidden, for: .navigationBar)
        .enableSwipeBack()
        .task {
            locationManager.requestAndUpdate()
            await dataStore.refreshCourts()
        }
        .sheet(isPresented: $showAddCourtSheet) {
            AddCourtSheet(isEn: isEn, userLocation: locationManager.lastLocation)
                .environmentObject(dataStore)
        }
    }

    private func filteredAndSortedCourts() -> [StreetballCourt] {
        let loc = locationManager.lastLocation
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let mapped: [StreetballCourt] = dataStore.courts.compactMap { court in
            if !query.isEmpty {
                let match = court.name.lowercased().contains(query) ||
                    court.city.lowercased().contains(query) ||
                    court.address.lowercased().contains(query)
                if !match { return nil }
            }
            var copy = court
            if let loc {
                let courtLoc = CLLocation(latitude: court.latitude, longitude: court.longitude)
                copy.distanceMeters = loc.distance(from: courtLoc)
            }
            return copy
        }

        return mapped.sorted { a, b in
            if let da = a.distanceMeters, let db = b.distanceMeters {
                return da < db
            }
            return a.activePlayersCount > b.activePlayersCount
        }
    }

    private func openMapsRoute(for court: StreetballCourt) {
        let encodedName = court.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Court"
        if let url = URL(string: "http://maps.apple.com/?daddr=\(court.latitude),\(court.longitude)&q=\(encodedName)&dirflg=w") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - 1:1 Android item_streetball_court.xml
private struct StreetballCourtCard: View {
    let court: StreetballCourt
    let isEn: Bool
    let onCheckIn: () -> Void
    let onOpenRoute: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top badges row
            HStack(spacing: 8) {
                Text(court.city)
                    .font(.geist(11, weight: .bold))
                    .foregroundColor(HooplabTheme.primary)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(HooplabTheme.fireBg)
                    .clipShape(Capsule())

                if let dist = court.formattedDistance(isEn: isEn) {
                    Text("📍 \(dist)")
                        .font(.geist(11, weight: .bold))
                        .foregroundColor(HooplabTheme.accentSecondary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(HooplabTheme.accentSecondary.opacity(0.15))
                        .clipShape(Capsule())
                }

                Spacer()

                Text(
                    isEn
                    ? "🏀 \(court.activePlayersCount) active"
                    : "🏀 \(court.activePlayersCount) на корте"
                )
                .font(.geist(12, weight: .bold))
                .foregroundColor(court.isUserCheckedIn ? HooplabTheme.accentSecondary : HooplabTheme.textSecondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(court.name)
                    .font(.geist(17, weight: .bold))
                    .foregroundColor(HooplabTheme.textPrimary)

                Text(court.address)
                    .font(.geist(13, weight: .regular))
                    .foregroundColor(HooplabTheme.textSecondary)
            }

            // Feature chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    featureChip(court.localizedSurface(isEn: isEn))
                    featureChip(isEn ? "🏀 \(court.rimsCount) rims" : "🏀 \(court.rimsCount) кольца")
                    featureChip(
                        court.hasLighting
                        ? (isEn ? "💡 Night Lights" : "💡 Освещение")
                        : (isEn ? "☀️ Daylight" : "☀️ Дневная")
                    )
                }
            }

            // Buttons row
            HStack(spacing: 10) {
                Button(action: onCheckIn) {
                    HStack(spacing: 6) {
                        Image(systemName: court.isUserCheckedIn ? "checkmark.circle.fill" : "figure.basketball")
                            .font(.system(size: 14, weight: .bold))
                        Text(
                            court.isUserCheckedIn
                            ? (isEn ? "Checked In" : "Я на площадке")
                            : (isEn ? "Check In" : "Я на корте!")
                        )
                        .font(.geist(13, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(court.isUserCheckedIn ? HooplabTheme.accentSecondary : HooplabTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button(action: onOpenRoute) {
                    HStack(spacing: 6) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 13))
                        Text(isEn ? "Route" : "Маршрут")
                            .font(.geist(13, weight: .semibold))
                    }
                    .foregroundColor(HooplabTheme.textPrimary)
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(HooplabTheme.bgInput)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(HooplabTheme.glassStroke, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .hooplabCard(
            padding: 16,
            strokeColor: court.isUserCheckedIn ? HooplabTheme.accentSecondary.opacity(0.6) : nil
        )
    }

    private func featureChip(_ title: String) -> some View {
        Text(title)
            .font(.geist(11, weight: .semibold))
            .foregroundColor(HooplabTheme.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(HooplabTheme.bgInput)
            .clipShape(Capsule())
    }
}

// MARK: - Add Custom Court Sheet (1:1 Android dialog_add_court.xml)
private struct AddCourtSheet: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss

    let isEn: Bool
    let userLocation: CLLocation?

    @State private var name: String = ""
    @State private var city: String = ""
    @State private var address: String = ""
    @State private var surfaceIndex: Int = 0
    @State private var rimsCount: Int = 2
    @State private var hasLighting: Bool = true
    @State private var useCurrentLocation: Bool = true
    @State private var isSaving: Bool = false

    private var surfaceChoices: [String] {
        isEn
        ? ["Rubber Cushion", "Polymer Acrylic", "Asphalt Street"]
        : ["Резиновая крошка", "Полимерное", "Асфальт"]
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    fieldBlock(
                        label: isEn ? "Court Name" : "Название площадки",
                        placeholder: isEn ? "e.g. Nike Box Park" : "Например: Площадка Парк Победы",
                        text: $name
                    )

                    fieldBlock(
                        label: isEn ? "City" : "Город",
                        placeholder: isEn ? "Moscow" : "Москва",
                        text: $city
                    )

                    fieldBlock(
                        label: isEn ? "Street Address" : "Адрес",
                        placeholder: isEn ? "Street & building" : "Улица, дом",
                        text: $address
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text(isEn ? "Surface Type" : "Покрытие")
                            .font(.geist(13, weight: .semibold))
                            .foregroundColor(HooplabTheme.textSecondary)

                        Picker("", selection: $surfaceIndex) {
                            ForEach(0..<surfaceChoices.count, id: \.self) { idx in
                                Text(surfaceChoices[idx]).tag(idx)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    HStack {
                        Text(isEn ? "Number of Rims" : "Количество колец")
                            .font(.geist(15, weight: .medium))
                            .foregroundColor(HooplabTheme.textPrimary)
                        Spacer()
                        Stepper("\(rimsCount)", value: $rimsCount, in: 1...12)
                            .labelsHidden()
                        Text("\(rimsCount)")
                            .font(.geist(16, weight: .bold))
                            .foregroundColor(HooplabTheme.primary)
                            .frame(minWidth: 24)
                    }
                    .hooplabCard(padding: 14)

                    Toggle(isOn: $hasLighting) {
                        Text(isEn ? "💡 Night Lighting Available" : "💡 Есть вечернее освещение")
                            .font(.geist(15, weight: .medium))
                            .foregroundColor(HooplabTheme.textPrimary)
                    }
                    .tint(HooplabTheme.primary)
                    .hooplabCard(padding: 14)

                    if userLocation != nil {
                        Toggle(isOn: $useCurrentLocation) {
                            Text(isEn ? "📍 Use My GPS Coordinates" : "📍 Привязать мою геопозицию")
                                .font(.geist(15, weight: .medium))
                                .foregroundColor(HooplabTheme.textPrimary)
                        }
                        .tint(HooplabTheme.accentSecondary)
                        .hooplabCard(padding: 14)
                    }

                    Button {
                        submit()
                    } label: {
                        HStack {
                            if isSaving { ProgressView().tint(.white) }
                            Text(isEn ? "Add Court" : "Добавить площадку")
                                .font(.geist(15, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: HooplabDimens.buttonHeight)
                        .background(name.trimmingCharacters(in: .whitespaces).isEmpty ? HooplabTheme.textHint : HooplabTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: HooplabDimens.radiusButton))
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                    .padding(.top, 6)
                }
                .padding(HooplabDimens.screenPaddingH)
            }
            .hooplabAurora()
            .navigationTitle(isEn ? "New Court" : "Новая площадка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(isEn ? "Cancel" : "Отмена") { dismiss() }
                        .foregroundColor(HooplabTheme.primary)
                }
            }
        }
    }

    private func fieldBlock(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.geist(13, weight: .semibold))
                .foregroundColor(HooplabTheme.textSecondary)
            TextField(placeholder, text: text)
                .font(.geist(15, weight: .regular))
                .foregroundColor(HooplabTheme.textPrimary)
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(HooplabTheme.bgInput)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(HooplabTheme.glassStroke, lineWidth: 1))
        }
    }

    private func submit() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        isSaving = true
        let lat = useCurrentLocation ? userLocation?.coordinate.latitude : nil
        let lng = useCurrentLocation ? userLocation?.coordinate.longitude : nil
        Task {
            await dataStore.addCustomCourt(
                name: trimmedName,
                city: city.trimmingCharacters(in: .whitespacesAndNewlines),
                address: address.trimmingCharacters(in: .whitespacesAndNewlines),
                surface: surfaceChoices[surfaceIndex],
                rims: rimsCount,
                hasLighting: hasLighting,
                lat: lat,
                lng: lng
            )
            await MainActor.run {
                isSaving = false
                dismiss()
            }
        }
    }
}
