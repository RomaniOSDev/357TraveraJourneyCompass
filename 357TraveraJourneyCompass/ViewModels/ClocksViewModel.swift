import Foundation
import Combine

final class ClocksViewModel: ObservableObject {
    @Published var isPickerPresented = false
    @Published var isTripPickerPresented = false
    @Published var tripAlert: String?

    func timeString(for clock: WorldClock, at date: Date, use24Hour: Bool) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: clock.timeZoneIdentifier) ?? TimeZone(secondsFromGMT: 0) ?? .current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = use24Hour ? "HH:mm" : "h:mm a"
        return formatter.string(from: date)
    }

    func hour(for clock: WorldClock, at date: Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: clock.timeZoneIdentifier) ?? TimeZone(secondsFromGMT: 0) ?? .current
        return calendar.component(.hour, from: date)
    }

    func isDaylight(for clock: WorldClock, at date: Date) -> Bool {
        let hour = hour(for: clock, at: date)
        return hour >= 6 && hour < 18
    }

    func add(entry: CityTimeZoneEntry, store: DataStore) -> Bool {
        if store.hasClock(city: entry.city) {
            return false
        }
        store.addClock(WorldClock(city: entry.city, timeZoneIdentifier: entry.timeZoneIdentifier))
        return true
    }

    func addClockFromTrip(destination: Destination, store: DataStore) {
        guard let entry = CityTimeZoneMap.entry(forCountry: destination.country) else {
            tripAlert = "No city stamp is mapped for \(destination.country) yet."
            return
        }
        if store.hasClock(city: entry.city) {
            tripAlert = "\(entry.city) is already on your clock panel."
            return
        }
        store.addClock(WorldClock(city: entry.city, timeZoneIdentifier: entry.timeZoneIdentifier))
        tripAlert = "Added \(entry.city) from \(destination.name)."
    }

    func hourDelta(from left: WorldClock, to right: WorldClock, at date: Date) -> Int {
        let leftZone = TimeZone(identifier: left.timeZoneIdentifier) ?? TimeZone(secondsFromGMT: 0) ?? .current
        let rightZone = TimeZone(identifier: right.timeZoneIdentifier) ?? TimeZone(secondsFromGMT: 0) ?? .current
        return (leftZone.secondsFromGMT(for: date) - rightZone.secondsFromGMT(for: date)) / 3600
    }

    func overlapText(
        left: WorldClock,
        right: WorldClock,
        at date: Date,
        use24Hour: Bool
    ) -> String {
        let leftZone = TimeZone(identifier: left.timeZoneIdentifier) ?? TimeZone(secondsFromGMT: 0) ?? .current
        let rightZone = TimeZone(identifier: right.timeZoneIdentifier) ?? TimeZone(secondsFromGMT: 0) ?? .current
        var leftCalendar = Calendar(identifier: .gregorian)
        leftCalendar.timeZone = leftZone
        var rightCalendar = Calendar(identifier: .gregorian)
        rightCalendar.timeZone = rightZone

        var overlapping: [Date] = []
        for hour in 0..<24 {
            guard let sample = Calendar.current.date(byAdding: .hour, value: hour, to: date) else { continue }
            let leftHour = leftCalendar.component(.hour, from: sample)
            let rightHour = rightCalendar.component(.hour, from: sample)
            if (9..<21).contains(leftHour) && (9..<21).contains(rightHour) {
                overlapping.append(sample)
            }
        }

        guard let first = overlapping.first, let lastHour = overlapping.last,
              let last = Calendar.current.date(byAdding: .hour, value: 1, to: lastHour) else {
            return "No shared 09:00–21:00 window over the next 24 hours."
        }

        let leftRange = "\(timeString(for: left, at: first, use24Hour: use24Hour))–\(timeString(for: left, at: last, use24Hour: use24Hour))"
        let rightRange = "\(timeString(for: right, at: first, use24Hour: use24Hour))–\(timeString(for: right, at: last, use24Hour: use24Hour))"
        return "\(left.city) \(leftRange)\n\(right.city) \(rightRange)"
    }
}
