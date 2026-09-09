import Foundation
import CoreLocation

struct CityTimeZoneEntry: Identifiable, Hashable {
    var id: String { city + "|" + timeZoneIdentifier }
    let city: String
    let timeZoneIdentifier: String
    let countryKeys: [String]
}

enum CityTimeZoneMap {
    static let catalog: [CityTimeZoneEntry] = [
        CityTimeZoneEntry(city: "Tokyo", timeZoneIdentifier: "Asia/Tokyo", countryKeys: ["japan"]),
        CityTimeZoneEntry(city: "Kyoto", timeZoneIdentifier: "Asia/Tokyo", countryKeys: ["japan"]),
        CityTimeZoneEntry(city: "Seoul", timeZoneIdentifier: "Asia/Seoul", countryKeys: ["korea", "south korea"]),
        CityTimeZoneEntry(city: "Shanghai", timeZoneIdentifier: "Asia/Shanghai", countryKeys: ["china"]),
        CityTimeZoneEntry(city: "Hong Kong", timeZoneIdentifier: "Asia/Hong_Kong", countryKeys: ["hong kong"]),
        CityTimeZoneEntry(city: "Taipei", timeZoneIdentifier: "Asia/Taipei", countryKeys: ["taiwan"]),
        CityTimeZoneEntry(city: "Bangkok", timeZoneIdentifier: "Asia/Bangkok", countryKeys: ["thailand"]),
        CityTimeZoneEntry(city: "Singapore", timeZoneIdentifier: "Asia/Singapore", countryKeys: ["singapore"]),
        CityTimeZoneEntry(city: "Kuala Lumpur", timeZoneIdentifier: "Asia/Kuala_Lumpur", countryKeys: ["malaysia"]),
        CityTimeZoneEntry(city: "Jakarta", timeZoneIdentifier: "Asia/Jakarta", countryKeys: ["indonesia"]),
        CityTimeZoneEntry(city: "Manila", timeZoneIdentifier: "Asia/Manila", countryKeys: ["philippines"]),
        CityTimeZoneEntry(city: "Ho Chi Minh City", timeZoneIdentifier: "Asia/Ho_Chi_Minh", countryKeys: ["vietnam"]),
        CityTimeZoneEntry(city: "New Delhi", timeZoneIdentifier: "Asia/Kolkata", countryKeys: ["india"]),
        CityTimeZoneEntry(city: "Dubai", timeZoneIdentifier: "Asia/Dubai", countryKeys: ["uae", "united arab emirates", "dubai"]),
        CityTimeZoneEntry(city: "Istanbul", timeZoneIdentifier: "Europe/Istanbul", countryKeys: ["turkey"]),
        CityTimeZoneEntry(city: "Paris", timeZoneIdentifier: "Europe/Paris", countryKeys: ["france"]),
        CityTimeZoneEntry(city: "Rome", timeZoneIdentifier: "Europe/Rome", countryKeys: ["italy"]),
        CityTimeZoneEntry(city: "Madrid", timeZoneIdentifier: "Europe/Madrid", countryKeys: ["spain"]),
        CityTimeZoneEntry(city: "London", timeZoneIdentifier: "Europe/London", countryKeys: ["united kingdom", "uk", "england", "britain"]),
        CityTimeZoneEntry(city: "Berlin", timeZoneIdentifier: "Europe/Berlin", countryKeys: ["germany"]),
        CityTimeZoneEntry(city: "Amsterdam", timeZoneIdentifier: "Europe/Amsterdam", countryKeys: ["netherlands", "holland"]),
        CityTimeZoneEntry(city: "Lisbon", timeZoneIdentifier: "Europe/Lisbon", countryKeys: ["portugal"]),
        CityTimeZoneEntry(city: "Zurich", timeZoneIdentifier: "Europe/Zurich", countryKeys: ["switzerland"]),
        CityTimeZoneEntry(city: "Vienna", timeZoneIdentifier: "Europe/Vienna", countryKeys: ["austria"]),
        CityTimeZoneEntry(city: "Prague", timeZoneIdentifier: "Europe/Prague", countryKeys: ["czech", "czechia"]),
        CityTimeZoneEntry(city: "Athens", timeZoneIdentifier: "Europe/Athens", countryKeys: ["greece"]),
        CityTimeZoneEntry(city: "Dublin", timeZoneIdentifier: "Europe/Dublin", countryKeys: ["ireland"]),
        CityTimeZoneEntry(city: "Stockholm", timeZoneIdentifier: "Europe/Stockholm", countryKeys: ["sweden"]),
        CityTimeZoneEntry(city: "Oslo", timeZoneIdentifier: "Europe/Oslo", countryKeys: ["norway"]),
        CityTimeZoneEntry(city: "Copenhagen", timeZoneIdentifier: "Europe/Copenhagen", countryKeys: ["denmark"]),
        CityTimeZoneEntry(city: "Helsinki", timeZoneIdentifier: "Europe/Helsinki", countryKeys: ["finland"]),
        CityTimeZoneEntry(city: "Warsaw", timeZoneIdentifier: "Europe/Warsaw", countryKeys: ["poland"]),
        CityTimeZoneEntry(city: "Budapest", timeZoneIdentifier: "Europe/Budapest", countryKeys: ["hungary"]),
        CityTimeZoneEntry(city: "Zagreb", timeZoneIdentifier: "Europe/Zagreb", countryKeys: ["croatia"]),
        CityTimeZoneEntry(city: "Reykjavik", timeZoneIdentifier: "Atlantic/Reykjavik", countryKeys: ["iceland"]),
        CityTimeZoneEntry(city: "New York", timeZoneIdentifier: "America/New_York", countryKeys: ["united states", "usa", "america"]),
        CityTimeZoneEntry(city: "Los Angeles", timeZoneIdentifier: "America/Los_Angeles", countryKeys: ["united states", "usa"]),
        CityTimeZoneEntry(city: "Toronto", timeZoneIdentifier: "America/Toronto", countryKeys: ["canada"]),
        CityTimeZoneEntry(city: "Mexico City", timeZoneIdentifier: "America/Mexico_City", countryKeys: ["mexico"]),
        CityTimeZoneEntry(city: "Sao Paulo", timeZoneIdentifier: "America/Sao_Paulo", countryKeys: ["brazil"]),
        CityTimeZoneEntry(city: "Buenos Aires", timeZoneIdentifier: "America/Argentina/Buenos_Aires", countryKeys: ["argentina"]),
        CityTimeZoneEntry(city: "Lima", timeZoneIdentifier: "America/Lima", countryKeys: ["peru"]),
        CityTimeZoneEntry(city: "Santiago", timeZoneIdentifier: "America/Santiago", countryKeys: ["chile"]),
        CityTimeZoneEntry(city: "Sydney", timeZoneIdentifier: "Australia/Sydney", countryKeys: ["australia"]),
        CityTimeZoneEntry(city: "Auckland", timeZoneIdentifier: "Pacific/Auckland", countryKeys: ["new zealand"]),
        CityTimeZoneEntry(city: "Cairo", timeZoneIdentifier: "Africa/Cairo", countryKeys: ["egypt"]),
        CityTimeZoneEntry(city: "Cape Town", timeZoneIdentifier: "Africa/Johannesburg", countryKeys: ["south africa"]),
        CityTimeZoneEntry(city: "Marrakesh", timeZoneIdentifier: "Africa/Casablanca", countryKeys: ["morocco"]),
        CityTimeZoneEntry(city: "Nairobi", timeZoneIdentifier: "Africa/Nairobi", countryKeys: ["kenya"])
    ]

    private static let asiaKeys = [
        "japan", "china", "korea", "thailand", "vietnam", "india", "indonesia",
        "singapore", "malaysia", "philippines", "taiwan", "hong kong", "cambodia",
        "laos", "myanmar", "nepal", "sri lanka", "mongolia", "asia", "dubai", "uae"
    ]

    static func entry(forCountry country: String) -> CityTimeZoneEntry? {
        let needle = country.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return nil }
        return catalog.first { entry in
            entry.countryKeys.contains { key in
                needle == key || needle.contains(key) || key.contains(needle)
            }
        }
    }

    static func isAsianCountry(_ country: String) -> Bool {
        let needle = country.lowercased()
        return asiaKeys.contains { needle.contains($0) }
    }

    static func coordinate(for destination: Destination) -> CLLocationCoordinate2D? {
        if let match = catalog.first(where: { $0.city.compare(destination.name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }) {
            return coordinates[match.city.lowercased()]
        }
        if let entry = entry(forCountry: destination.country) {
            return coordinates[entry.city.lowercased()]
        }
        let needle = destination.country.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let city = countryCities.first(where: { needle == $0.key || needle.contains($0.key) || $0.key.contains(needle) })?.value {
            return coordinates[city]
        }
        return nil
    }

    private static let coordinates: [String: CLLocationCoordinate2D] = [
        "tokyo": CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
        "kyoto": CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681),
        "seoul": CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        "shanghai": CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737),
        "hong kong": CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694),
        "taipei": CLLocationCoordinate2D(latitude: 25.0330, longitude: 121.5654),
        "bangkok": CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018),
        "singapore": CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198),
        "kuala lumpur": CLLocationCoordinate2D(latitude: 3.1390, longitude: 101.6869),
        "jakarta": CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456),
        "manila": CLLocationCoordinate2D(latitude: 14.5995, longitude: 120.9842),
        "ho chi minh city": CLLocationCoordinate2D(latitude: 10.8231, longitude: 106.6297),
        "new delhi": CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),
        "dubai": CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708),
        "istanbul": CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        "paris": CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
        "rome": CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964),
        "madrid": CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
        "london": CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
        "berlin": CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050),
        "amsterdam": CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
        "lisbon": CLLocationCoordinate2D(latitude: 38.7223, longitude: -9.1393),
        "zurich": CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417),
        "vienna": CLLocationCoordinate2D(latitude: 48.2082, longitude: 16.3738),
        "prague": CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378),
        "athens": CLLocationCoordinate2D(latitude: 37.9838, longitude: 23.7275),
        "dublin": CLLocationCoordinate2D(latitude: 53.3498, longitude: -6.2603),
        "stockholm": CLLocationCoordinate2D(latitude: 59.3293, longitude: 18.0686),
        "oslo": CLLocationCoordinate2D(latitude: 59.9139, longitude: 10.7522),
        "copenhagen": CLLocationCoordinate2D(latitude: 55.6761, longitude: 12.5683),
        "helsinki": CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384),
        "warsaw": CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122),
        "budapest": CLLocationCoordinate2D(latitude: 47.4979, longitude: 19.0402),
        "zagreb": CLLocationCoordinate2D(latitude: 45.8150, longitude: 15.9819),
        "reykjavik": CLLocationCoordinate2D(latitude: 64.1466, longitude: -21.9426),
        "new york": CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        "los angeles": CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
        "toronto": CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
        "mexico city": CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
        "sao paulo": CLLocationCoordinate2D(latitude: -23.5558, longitude: -46.6396),
        "buenos aires": CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816),
        "lima": CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428),
        "santiago": CLLocationCoordinate2D(latitude: -33.4489, longitude: -70.6693),
        "sydney": CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
        "auckland": CLLocationCoordinate2D(latitude: -36.8509, longitude: 174.7645),
        "cairo": CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357),
        "cape town": CLLocationCoordinate2D(latitude: -33.9249, longitude: 18.4241),
        "marrakesh": CLLocationCoordinate2D(latitude: 31.6295, longitude: -7.9811),
        "nairobi": CLLocationCoordinate2D(latitude: -1.2921, longitude: 36.8219)
    ]

    private static let countryCities: [String: String] = [
        "japan": "tokyo",
        "korea": "seoul",
        "south korea": "seoul",
        "china": "shanghai",
        "hong kong": "hong kong",
        "taiwan": "taipei",
        "thailand": "bangkok",
        "singapore": "singapore",
        "malaysia": "kuala lumpur",
        "indonesia": "jakarta",
        "philippines": "manila",
        "vietnam": "ho chi minh city",
        "india": "new delhi",
        "uae": "dubai",
        "united arab emirates": "dubai",
        "turkey": "istanbul",
        "france": "paris",
        "italy": "rome",
        "spain": "madrid",
        "united kingdom": "london",
        "uk": "london",
        "england": "london",
        "germany": "berlin",
        "netherlands": "amsterdam",
        "portugal": "lisbon",
        "switzerland": "zurich",
        "austria": "vienna",
        "czech": "prague",
        "czechia": "prague",
        "greece": "athens",
        "ireland": "dublin",
        "sweden": "stockholm",
        "norway": "oslo",
        "denmark": "copenhagen",
        "finland": "helsinki",
        "poland": "warsaw",
        "hungary": "budapest",
        "croatia": "zagreb",
        "iceland": "reykjavik",
        "united states": "new york",
        "usa": "new york",
        "america": "new york",
        "canada": "toronto",
        "mexico": "mexico city",
        "brazil": "sao paulo",
        "argentina": "buenos aires",
        "peru": "lima",
        "chile": "santiago",
        "australia": "sydney",
        "new zealand": "auckland",
        "egypt": "cairo",
        "south africa": "cape town",
        "morocco": "marrakesh",
        "kenya": "nairobi"
    ]
}
