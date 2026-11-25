import Foundation
import CoreLocation

public struct StreetballCourt: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let address: String
    public let surfaceTypeRu: String
    public let surfaceTypeEn: String
    public let rimsCount: Int
    public let hasLighting: Bool
    public let latitude: Double
    public let longitude: Double
    public var activePlayersCount: Int
    public var isUserCheckedIn: Bool
    public var distanceMeters: Double?
    public let city: String

    public init(
        id: String,
        name: String,
        address: String,
        surfaceTypeRu: String,
        surfaceTypeEn: String,
        rimsCount: Int,
        hasLighting: Bool,
        latitude: Double,
        longitude: Double,
        activePlayersCount: Int = 0,
        isUserCheckedIn: Bool = false,
        distanceMeters: Double? = nil,
        city: String = "Москва"
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.surfaceTypeRu = surfaceTypeRu
        self.surfaceTypeEn = surfaceTypeEn
        self.rimsCount = rimsCount
        self.hasLighting = hasLighting
        self.latitude = latitude
        self.longitude = longitude
        self.activePlayersCount = activePlayersCount
        self.isUserCheckedIn = isUserCheckedIn
        self.distanceMeters = distanceMeters
        self.city = city
    }

    public func localizedSurface(isEn: Bool) -> String {
        isEn ? surfaceTypeEn : surfaceTypeRu
    }

    public func formattedDistance(isEn: Bool) -> String? {
        guard let d = distanceMeters else { return nil }
        if d < 1000 {
            return "\(Int(d)) " + (isEn ? "m" : "м")
        } else {
            return String(format: "%.1f %@", d / 1000.0, isEn ? "km" : "км")
        }
    }
}

public struct CourtsData {
    public static let sampleCourts: [StreetballCourt] = [
        StreetballCourt(
            id: "court_1",
            name: "Лужники Streetball Park",
            address: "ул. Лужники, 24с1",
            surfaceTypeRu: "Полимерное",
            surfaceTypeEn: "Polymer Acrylic",
            rimsCount: 6,
            hasLighting: true,
            latitude: 55.7158,
            longitude: 37.5537,
            activePlayersCount: 8,
            city: "Москва"
        ),
        StreetballCourt(
            id: "court_2",
            name: "Парк Горького / Музеон Корт",
            address: "Крымский вал, 9",
            surfaceTypeRu: "Резиновая крошка",
            surfaceTypeEn: "Rubber Cushion",
            rimsCount: 4,
            hasLighting: true,
            latitude: 55.7314,
            longitude: 37.6034,
            activePlayersCount: 12,
            city: "Москва"
        ),
        StreetballCourt(
            id: "court_3",
            name: "Underground Spot Таганка",
            address: "Таганская площадь, 12",
            surfaceTypeRu: "Асфальт (Street Pro)",
            surfaceTypeEn: "Asphalt Street Pro",
            rimsCount: 2,
            hasLighting: false,
            latitude: 55.7412,
            longitude: 37.6531,
            activePlayersCount: 4,
            city: "Москва"
        ),
        StreetballCourt(
            id: "court_4",
            name: "Спорткомплекс Динамо Корт",
            address: "Ленинградский просп., 36",
            surfaceTypeRu: "Спортивный паркет",
            surfaceTypeEn: "Hardwood Indoor",
            rimsCount: 4,
            hasLighting: true,
            latitude: 55.7915,
            longitude: 37.5598,
            activePlayersCount: 6,
            city: "Москва"
        ),
        StreetballCourt(
            id: "court_spb_1",
            name: "Новая Голландия Streetball",
            address: "наб. Адмиралтейского канала, 2",
            surfaceTypeRu: "Полимерное Pro",
            surfaceTypeEn: "Polymer Acrylic Pro",
            rimsCount: 4,
            hasLighting: true,
            latitude: 59.9298,
            longitude: 30.2891,
            activePlayersCount: 9,
            city: "Санкт-Петербург"
        ),
        StreetballCourt(
            id: "court_kzn_1",
            name: "Экстрим-парк УРАМ Корт",
            address: "Кремлевская набережная, 33",
            surfaceTypeRu: "Резиновая крошка",
            surfaceTypeEn: "Rubber Cushion",
            rimsCount: 6,
            hasLighting: true,
            latitude: 55.8038,
            longitude: 49.1256,
            activePlayersCount: 14,
            city: "Казань"
        ),
        StreetballCourt(
            id: "court_sochi_1",
            name: "Олимпийский парк Корт",
            address: "Олимпийский проспект, 1",
            surfaceTypeRu: "Полимерное",
            surfaceTypeEn: "Polymer Acrylic",
            rimsCount: 4,
            hasLighting: true,
            latitude: 43.4024,
            longitude: 39.9554,
            activePlayersCount: 7,
            city: "Сочи"
        ),
        StreetballCourt(
            id: "court_nsk_1",
            name: "Streetball Spot Михайловская набережная",
            address: "ул. Большевистская, 12б",
            surfaceTypeRu: "Асфальт Street Pro",
            surfaceTypeEn: "Asphalt Street Pro",
            rimsCount: 4,
            hasLighting: true,
            latitude: 55.0112,
            longitude: 82.9345,
            activePlayersCount: 5,
            city: "Новосибирск"
        )
    ]
}
