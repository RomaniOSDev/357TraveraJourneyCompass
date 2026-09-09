import SwiftUI

struct HubView: View {
    @EnvironmentObject private var store: DataStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero
                nextCrossingCard

                Text("Select a gate")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(.top, 4)

                NavigationLink(value: AppRoute.destinations) {
                    PassportTile(
                        title: "Destinations",
                        subtitle: "Stamp countries you plan to cross",
                        systemImage: "globe.europe.africa.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(value: AppRoute.itinerary(destinationId: nil)) {
                    PassportTile(
                        title: "Itinerary",
                        subtitle: "Flight, stay, and activity coupons",
                        systemImage: "ticket.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(value: AppRoute.clocks) {
                    PassportTile(
                        title: "Clocks",
                        subtitle: "Local hours at each stop",
                        systemImage: "clock.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(value: AppRoute.stampsMap) {
                    PassportTile(
                        title: "Stamp map",
                        subtitle: "Pins for countries on your pass",
                        systemImage: "map.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(value: AppRoute.stats) {
                    PassportTile(
                        title: "Statistics",
                        subtitle: "Stamps, coupons, and crossing charts",
                        systemImage: "chart.bar.fill"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .padding(.bottom, 28)
        }
        .travelScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Boarding")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: AppRoute.settings) {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            ReminderScheduler.requestAccess()
            ReminderScheduler.sync(destinations: store.destinations, items: store.itineraryItems)
        }
    }

    @ViewBuilder
    private var nextCrossingCard: some View {
        if let crossing = NextCrossing.current(store: store) {
            NavigationLink(value: crossing.route) {
                BoardingPassCard(stubWidth: 78) {
                    VStack(spacing: 8) {
                        Image(systemName: crossing.systemImage)
                            .foregroundStyle(Color("AppPrimary"))
                        Text("Next")
                            .ticketLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                } main: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(crossing.title)
                            .ticketLabel()
                            .foregroundStyle(Color("AppPrimary"))
                        Text(crossing.subtitle)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(crossing.date, style: .relative)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var hero: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 214)
            .background {
                Image("banner_suitcase")
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color("AppPrimary").opacity(0.45), lineWidth: 1.2)
            }
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Passenger copy")
                        .ticketLabel()
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Pack the next crossing")
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .padding(16)
                .background(Color("AppBackground").opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(14)
            }
            .overlay(alignment: .bottomTrailing) {
                Color.clear
                    .frame(width: 72, height: 72)
                    .background {
                        Image("tile_compass")
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color("AppPrimary"), lineWidth: 2))
                    .shadow(color: Color("AppBackground"), radius: 8, x: 0, y: 8)
                    .shadow(color: Color("AppPrimary"), radius: 2, x: 0, y: 2)
                    .offset(x: -10, y: 18)
            }
            .padding(.bottom, 10)
    }
}

private struct NextCrossing {
    let title: String
    let subtitle: String
    let date: Date
    let systemImage: String
    let route: AppRoute

    static func current(store: DataStore) -> NextCrossing? {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let upcomingDestination = store.destinations
            .filter { $0.visitDate >= startOfToday && !$0.visited }
            .sorted { $0.visitDate < $1.visitDate }
            .first
        let upcomingFlight = store.itineraryItems
            .filter { $0.category == .flight && !$0.completed && $0.date >= Date() }
            .sorted { $0.date < $1.date }
            .first

        switch (upcomingDestination, upcomingFlight) {
        case let (destination?, flight?):
            if flight.date < destination.visitDate {
                return flightCrossing(flight, store: store)
            }
            return destinationCrossing(destination, flight: flight)
        case let (destination?, nil):
            return destinationCrossing(destination, flight: nil)
        case let (nil, flight?):
            return flightCrossing(flight, store: store)
        case (nil, nil):
            return nil
        }
    }

    private static func destinationCrossing(_ destination: Destination, flight: ItineraryItem?) -> NextCrossing {
        NextCrossing(
            title: "Next crossing",
            subtitle: flight.map { "\(destination.name) · \($0.title)" } ?? destination.name,
            date: destination.visitDate,
            systemImage: "airplane.departure",
            route: .itinerary(destinationId: destination.id)
        )
    }

    private static func flightCrossing(_ flight: ItineraryItem, store: DataStore) -> NextCrossing {
        let name = store.destination(id: flight.tripDestinationId)?.name
        return NextCrossing(
            title: "Next flight",
            subtitle: name.map { "\($0) · \(flight.title)" } ?? flight.title,
            date: flight.date,
            systemImage: "airplane",
            route: .itinerary(destinationId: flight.tripDestinationId)
        )
    }
}
