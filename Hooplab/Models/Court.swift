import Foundation

public struct StreetballCourt: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let address: String
    public let surfaceTypeRu: String
    public let surfaceTypeEn: String
    public let rimsCount: Int
    public let hasLighting: BooleanLiteralType
    public let latitude: Double
    public let longitude: Double
    public var activePlayersCount: Int
    public let city: String

    public func localizedSurface(isEn: Bool) -> String {
        isEn ? surfaceTypeEn : surfaceTypeRu
    }
}

public struct CourtsData {
    public static let sampleCourts: [StreetballCourt] = [
        StreetballCourt(
            id: "court_1",
            name: "Лужники Streetball Park",
            address = "ул. Лужники, 24с1",
            surfaceTypeRu: "Полимерное покрытие",
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
            name: "ВДНХ Баскет Холл",
            address: "Проспект Мира, 119",
            surfaceTypeRu: "Специальный уличный паркет",
            surfaceTypeEn: "Outdoor Pro Hardwood",
            rimsCount: 4,
            hasLighting: true,
            latitude: 55.8263,
            longitude: 37.6375,
            activePlayersCount: 15,
            city: "Москва"
        )
    ]
}
