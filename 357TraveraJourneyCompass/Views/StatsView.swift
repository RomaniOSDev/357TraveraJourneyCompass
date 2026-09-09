import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject private var store: DataStore

    private var snapshot: TravelStatsSnapshot {
        TravelStatsSnapshot(store: store)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Journey ledger")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextSecondary"))

                if snapshot.hasAnyData {
                    metricsGrid

                    if snapshot.destinationCount > 0 {
                        chartCard(title: "Passport stamps", subtitle: "Visited versus still planned") {
                            stampStatusChart
                        }

                        chartCard(title: "Crossing calendar", subtitle: "Stamps by visit month") {
                            monthChart
                        }
                    }

                    if snapshot.itineraryTotal > 0 {
                        chartCard(title: "Coupon mix", subtitle: "Flights, stays, and activities") {
                            categoryChart
                        }

                        chartCard(title: "Coupon status", subtitle: "Completed versus still open") {
                            completionChart
                        }
                    }
                } else {
                    EmptyStateBlock(
                        title: "Stamp a destination to open the ledger",
                        systemImage: "chart.xyaxis.line"
                    )
                }
            }
            .padding(20)
        }
        .travelScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Statistics")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            metricTile(title: "Stamps", value: "\(snapshot.destinationCount)", systemImage: "globe.europe.africa.fill")
            metricTile(title: "Visited", value: "\(snapshot.visitedCount)", systemImage: "checkmark.seal.fill")
            metricTile(title: "Coupons", value: "\(snapshot.itineraryTotal)", systemImage: "ticket.fill")
            metricTile(title: "Clocks", value: "\(snapshot.clockCount)", systemImage: "clock.fill")
        }
    }

    private func metricTile(title: String, value: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(Color("AppPrimary"))
            Text(value)
                .font(.title.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(title)
                .ticketLabel()
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color("AppSurface"))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.45), lineWidth: 1.2)
        }
        .overlay { StampCorners() }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func chartCard<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(subtitle)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            content()
                .frame(height: 220)
        }
        .padding(16)
        .background(Color("AppSurface"))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.45), lineWidth: 1.2)
        }
        .overlay { StampCorners() }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var stampStatusChart: some View {
        Chart(snapshot.stampBars) { bar in
            BarMark(
                x: .value("Status", bar.title),
                y: .value("Stamps", bar.count)
            )
            .foregroundStyle(bar.color)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.22))
                AxisValueLabel()
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .chartYScale(domain: 0...max(snapshot.stampMax, 1))
    }

    private var categoryChart: some View {
        Chart(snapshot.categoryBars) { bar in
            BarMark(
                x: .value("Category", bar.title),
                y: .value("Coupons", bar.count)
            )
            .foregroundStyle(bar.color)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.22))
                AxisValueLabel()
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .chartYScale(domain: 0...max(snapshot.categoryMax, 1))
    }

    private var monthChart: some View {
        Chart(snapshot.monthPoints) { point in
            AreaMark(
                x: .value("Month", point.monthStart, unit: .month),
                y: .value("Stamps", point.count)
            )
            .foregroundStyle(Color("AppPrimary").opacity(0.28))
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Month", point.monthStart, unit: .month),
                y: .value("Stamps", point.count)
            )
            .foregroundStyle(Color("AppPrimary"))
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2.4))

            PointMark(
                x: .value("Month", point.monthStart, unit: .month),
                y: .value("Stamps", point.count)
            )
            .foregroundStyle(Color("AppAccent"))
            .symbolSize(48)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.22))
                AxisValueLabel()
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .chartXAxis {
            AxisMarks(values: snapshot.monthPoints.map(\.monthStart)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.month(.narrow))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
        }
        .chartYScale(domain: 0...max(snapshot.monthMax, 1))
    }

    private var completionChart: some View {
        Chart(snapshot.completionBars) { bar in
            BarMark(
                x: .value("Count", bar.count),
                y: .value("Status", bar.title)
            )
            .foregroundStyle(bar.color)
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine()
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.22))
                AxisValueLabel()
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .chartXScale(domain: 0...max(snapshot.itineraryTotal, 1))
    }
}

private struct TravelStatsSnapshot {
    struct NamedBar: Identifiable {
        let title: String
        let count: Int
        let color: Color
        var id: String { title }
    }

    struct MonthPoint: Identifiable {
        let monthStart: Date
        let count: Int
        var id: Date { monthStart }
    }

    let destinationCount: Int
    let visitedCount: Int
    let itineraryTotal: Int
    let clockCount: Int
    let stampBars: [NamedBar]
    let categoryBars: [NamedBar]
    let monthPoints: [MonthPoint]
    let completionBars: [NamedBar]

    var hasAnyData: Bool {
        destinationCount > 0 || itineraryTotal > 0 || clockCount > 0
    }

    var stampMax: Int {
        stampBars.map(\.count).max() ?? 0
    }

    var categoryMax: Int {
        categoryBars.map(\.count).max() ?? 0
    }

    var monthMax: Int {
        monthPoints.map(\.count).max() ?? 0
    }

    init(store: DataStore) {
        let destinations = store.destinations
        let items = store.itineraryItems
        destinationCount = destinations.count
        visitedCount = destinations.filter(\.visited).count
        itineraryTotal = items.count
        clockCount = store.clocks.count

        stampBars = [
            NamedBar(title: "Visited", count: visitedCount, color: Color("AppPrimary")),
            NamedBar(title: "Planned", count: max(destinationCount - visitedCount, 0), color: Color("AppAccent"))
        ]

        categoryBars = ItineraryCategory.allCases.map { category in
            NamedBar(
                title: category.rawValue,
                count: items.filter { $0.category == category }.count,
                color: Self.color(for: category)
            )
        }

        let calendar = Calendar.current
        monthPoints = Self.monthStarts(for: destinations, calendar: calendar, now: Date()).map { start in
            MonthPoint(
                monthStart: start,
                count: destinations.filter { destination in
                    calendar.isDate(destination.visitDate, equalTo: start, toGranularity: .month)
                }.count
            )
        }

        let completed = items.filter(\.completed).count
        completionBars = [
            NamedBar(title: "Done", count: completed, color: Color("AppPrimary")),
            NamedBar(title: "Open", count: max(itineraryTotal - completed, 0), color: Color("AppAccent"))
        ]
    }

    private static func monthStarts(for destinations: [Destination], calendar: Calendar, now: Date) -> [Date] {
        func startOfMonth(_ date: Date) -> Date {
            calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
        }

        let visitMonths = destinations.map { startOfMonth($0.visitDate) }
        let windowStart = startOfMonth(calendar.date(byAdding: .month, value: -2, to: now) ?? now)
        let windowEnd = startOfMonth(calendar.date(byAdding: .month, value: 3, to: now) ?? now)
        let start = min(visitMonths.min() ?? windowStart, windowStart)
        let end = max(visitMonths.max() ?? windowEnd, windowEnd)

        var months: [Date] = []
        var cursor = start
        while cursor <= end {
            months.append(cursor)
            guard let next = calendar.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = next
            if months.count == 8 { break }
        }
        return months
    }

    private static func color(for category: ItineraryCategory) -> Color {
        switch category {
        case .flight:
            return Color("AppPrimary")
        case .accommodation:
            return Color("AppAccent")
        case .activities:
            return Color(red: 0.95, green: 0.78, blue: 0.42)
        }
    }
}
