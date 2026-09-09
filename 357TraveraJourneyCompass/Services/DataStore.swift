import Foundation
import Combine

final class DataStore: ObservableObject {
    @Published private(set) var destinations: [Destination] = []
    @Published private(set) var itineraryItems: [ItineraryItem] = []
    @Published private(set) var clocks: [WorldClock] = []
    @Published private(set) var packingItems: [PackingItem] = []
    @Published var use24Hour: Bool = false {
        didSet { persistFlags() }
    }

    private enum Keys {
        static let destinations = "tjc.destinations"
        static let itineraryItems = "tjc.itineraryItems"
        static let clocks = "tjc.worldClocks"
        static let packingItems = "tjc.packingItems"
        static let use24Hour = "tjc.use24Hour"
    }

    static let starterPack = [
        "Passport",
        "Boarding pass",
        "Charger",
        "Plug adapter",
        "Medications",
        "Toiletries"
    ]

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
        load()
        ReminderScheduler.sync(destinations: destinations, items: itineraryItems)
    }

    func destination(id: UUID) -> Destination? {
        destinations.first { $0.id == id }
    }

    func hasDuplicateDestinationName(_ name: String, excluding id: UUID?) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return destinations.contains { destination in
            if let id, destination.id == id { return false }
            return destination.name.compare(trimmed, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
    }

    func upsertDestination(_ destination: Destination) {
        if let index = destinations.firstIndex(where: { $0.id == destination.id }) {
            destinations[index] = destination
        } else {
            destinations.append(destination)
        }
        persistDestinations()
    }

    func toggleVisited(_ destination: Destination) {
        guard let index = destinations.firstIndex(where: { $0.id == destination.id }) else { return }
        destinations[index].visited.toggle()
        persistDestinations()
    }

    func deleteDestination(_ destination: Destination) {
        destinations.removeAll { $0.id == destination.id }
        itineraryItems.removeAll { $0.tripDestinationId == destination.id }
        packingItems.removeAll { $0.destinationId == destination.id }
        persistDestinations()
        persistItinerary()
        persistPacking()
    }

    func duplicateDestination(_ destination: Destination) -> Destination {
        let copy = Destination(
            name: uniqueCopyName(from: destination.name),
            country: destination.country,
            visitDate: Calendar.current.date(byAdding: .year, value: 1, to: destination.visitDate) ?? destination.visitDate,
            notes: destination.notes,
            visited: false,
            passportExpiry: destination.passportExpiry
        )
        upsertDestination(copy)

        let dateShift = copy.visitDate.timeIntervalSince(destination.visitDate)
        for item in items(forDestinationId: destination.id) {
            upsertItineraryItem(
                ItineraryItem(
                    title: item.title,
                    details: item.details,
                    date: item.date.addingTimeInterval(dateShift),
                    completed: false,
                    tripDestinationId: copy.id,
                    category: item.category
                )
            )
        }
        for item in packingItems(forDestinationId: destination.id) {
            upsertPackingItem(
                PackingItem(
                    destinationId: copy.id,
                    title: item.title,
                    packed: false
                )
            )
        }
        return copy
    }

    func items(forDestinationId id: UUID?) -> [ItineraryItem] {
        let items: [ItineraryItem]
        if let id {
            items = itineraryItems.filter { $0.tripDestinationId == id }
        } else {
            items = itineraryItems
        }
        return items.sorted { $0.date < $1.date }
    }

    func upsertItineraryItem(_ item: ItineraryItem) {
        if let index = itineraryItems.firstIndex(where: { $0.id == item.id }) {
            itineraryItems[index] = item
        } else {
            itineraryItems.append(item)
        }
        persistItinerary()
    }

    func deleteItineraryItem(id: UUID) {
        itineraryItems.removeAll { $0.id == id }
        persistItinerary()
    }

    func toggleItineraryCompleted(id: UUID) {
        guard let index = itineraryItems.firstIndex(where: { $0.id == id }) else { return }
        itineraryItems[index].completed.toggle()
        persistItinerary()
    }

    func hasItems(forDestinationId id: UUID) -> Bool {
        itineraryItems.contains { $0.tripDestinationId == id }
    }

    func packingItems(forDestinationId id: UUID) -> [PackingItem] {
        packingItems
            .filter { $0.destinationId == id }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func upsertPackingItem(_ item: PackingItem) {
        if let index = packingItems.firstIndex(where: { $0.id == item.id }) {
            packingItems[index] = item
        } else {
            packingItems.append(item)
        }
        persistPacking()
    }

    func deletePackingItem(id: UUID) {
        packingItems.removeAll { $0.id == id }
        persistPacking()
    }

    func togglePacked(id: UUID) {
        guard let index = packingItems.firstIndex(where: { $0.id == id }) else { return }
        packingItems[index].packed.toggle()
        persistPacking()
    }

    func addStarterPack(destinationId: UUID) {
        let existing = Set(
            packingItems(forDestinationId: destinationId).map { $0.title.lowercased() }
        )
        for title in Self.starterPack where !existing.contains(title.lowercased()) {
            packingItems.append(PackingItem(destinationId: destinationId, title: title))
        }
        persistPacking()
    }

    func hasClock(city: String) -> Bool {
        clocks.contains { $0.city.compare(city, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }
    }

    func addClock(_ clock: WorldClock) {
        guard !hasClock(city: clock.city) else { return }
        clocks.append(clock)
        persistClocks()
    }

    func deleteClock(_ clock: WorldClock) {
        clocks.removeAll { $0.id == clock.id }
        persistClocks()
    }

    func resetAll() {
        destinations = []
        itineraryItems = []
        clocks = []
        packingItems = []
        use24Hour = false
        persistDestinations()
        persistItinerary()
        persistClocks()
        persistPacking()
        persistFlags()
    }

    private func uniqueCopyName(from name: String) -> String {
        var candidate = "\(name) return"
        var index = 2
        while hasDuplicateDestinationName(candidate, excluding: nil) {
            candidate = "\(name) return \(index)"
            index += 1
        }
        return candidate
    }

    private func load() {
        destinations = decode([Destination].self, key: Keys.destinations) ?? []
        itineraryItems = decode([ItineraryItem].self, key: Keys.itineraryItems) ?? []
        clocks = decode([WorldClock].self, key: Keys.clocks) ?? []
        packingItems = decode([PackingItem].self, key: Keys.packingItems) ?? []
        use24Hour = defaults.bool(forKey: Keys.use24Hour)
    }

    private func persistDestinations() {
        encode(destinations, key: Keys.destinations)
        ReminderScheduler.sync(destinations: destinations, items: itineraryItems)
    }

    private func persistItinerary() {
        encode(itineraryItems, key: Keys.itineraryItems)
        ReminderScheduler.sync(destinations: destinations, items: itineraryItems)
    }

    private func persistClocks() {
        encode(clocks, key: Keys.clocks)
    }

    private func persistPacking() {
        encode(packingItems, key: Keys.packingItems)
    }

    private func persistFlags() {
        defaults.set(use24Hour, forKey: Keys.use24Hour)
    }

    private func encode<T: Encodable>(_ value: T, key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }
}
