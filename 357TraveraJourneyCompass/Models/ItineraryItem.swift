import Foundation

enum ItineraryCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case flight = "Flight"
    case accommodation = "Accommodation"
    case activities = "Activities"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .flight: return "airplane"
        case .accommodation: return "bed.double.fill"
        case .activities: return "figure.walk"
        }
    }
}

struct ItineraryItem: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var details: String
    var date: Date
    var completed: Bool
    var tripDestinationId: UUID
    var category: ItineraryCategory

    init(
        id: UUID = UUID(),
        title: String,
        details: String,
        date: Date,
        completed: Bool,
        tripDestinationId: UUID,
        category: ItineraryCategory
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.date = date
        self.completed = completed
        self.tripDestinationId = tripDestinationId
        self.category = category
    }
}
