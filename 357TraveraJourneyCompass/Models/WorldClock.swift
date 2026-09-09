import Foundation

struct WorldClock: Identifiable, Codable, Hashable {
    var id: UUID
    var city: String
    var timeZoneIdentifier: String

    init(id: UUID = UUID(), city: String, timeZoneIdentifier: String) {
        self.id = id
        self.city = city
        self.timeZoneIdentifier = timeZoneIdentifier
    }
}
