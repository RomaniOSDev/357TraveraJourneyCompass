import Foundation

struct Destination: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var country: String
    var visitDate: Date
    var notes: String
    var visited: Bool
    var passportExpiry: Date?

    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        visitDate: Date,
        notes: String,
        visited: Bool,
        passportExpiry: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.visitDate = visitDate
        self.notes = notes
        self.visited = visited
        self.passportExpiry = passportExpiry
    }

    func passportValidityWarning(minimumDays: Int = 180) -> String? {
        guard let passportExpiry else { return nil }
        if passportExpiry < visitDate {
            return "Passport expires before this visit."
        }
        let calendar = Calendar.current
        guard let needed = calendar.date(byAdding: .day, value: minimumDays, to: visitDate) else {
            return nil
        }
        if passportExpiry < needed {
            return "Less than 6 months of passport validity after this visit."
        }
        return nil
    }
}
