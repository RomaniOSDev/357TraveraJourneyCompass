import SwiftUI

struct AnalogClockRing: View {
    let date: Date
    let clock: WorldClock
    let isDaylight: Bool
    let timeText: String

    var body: some View {
        let hour = hourValue
        let minute = minuteValue
        let hourProgress = (CGFloat(hour % 12) + CGFloat(minute) / 60) / 12
        let minuteProgress = CGFloat(minute) / 60

        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 10)

            Circle()
                .trim(from: 0, to: max(hourProgress, 0.02))
                .stroke(
                    Color("AppPrimary"),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Circle()
                .trim(from: 0, to: max(minuteProgress, 0.02))
                .stroke(
                    Color("AppAccent"),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .padding(14)
                .rotationEffect(.degrees(-90))

            VStack(spacing: 6) {
                Image(systemName: isDaylight ? "sun.max.fill" : "moon.stars.fill")
                    .foregroundStyle(Color("AppPrimary"))
                Text(timeText)
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(clock.city)
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(18)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var hourValue: Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: clock.timeZoneIdentifier) ?? TimeZone(secondsFromGMT: 0) ?? .current
        return calendar.component(.hour, from: date)
    }

    private var minuteValue: Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: clock.timeZoneIdentifier) ?? TimeZone(secondsFromGMT: 0) ?? .current
        return calendar.component(.minute, from: date)
    }
}
