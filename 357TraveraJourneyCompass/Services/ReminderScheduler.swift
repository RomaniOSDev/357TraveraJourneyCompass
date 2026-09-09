import Foundation
import UserNotifications

enum ReminderScheduler {
    static func requestAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func sync(destinations: [Destination], items: [ItineraryItem]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let calendar = Calendar.current
        let now = Date()

        for destination in destinations where !destination.visited {
            guard let dayBefore = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: destination.visitDate)) else {
                continue
            }
            var components = calendar.dateComponents([.year, .month, .day], from: dayBefore)
            components.hour = 9
            components.minute = 0
            guard let fire = calendar.date(from: components), fire > now else { continue }
            add(
                id: "tjc.visit.\(destination.id.uuidString)",
                title: "Next crossing",
                body: "\(destination.name) is tomorrow. Check stamps and packing.",
                date: fire
            )
        }

        for item in items where !item.completed {
            guard let fire = calendar.date(byAdding: .hour, value: -3, to: item.date), fire > now else {
                continue
            }
            add(
                id: "tjc.coupon.\(item.id.uuidString)",
                title: "Boarding coupon",
                body: "\(item.title) starts in 3 hours.",
                date: fire
            )
        }
    }

    private static func add(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
