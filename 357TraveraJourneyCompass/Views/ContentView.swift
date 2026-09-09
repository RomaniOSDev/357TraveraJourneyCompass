import SwiftUI

struct ContentView: View {
    @StateObject private var store = DataStore()
    @StateObject private var router = AppRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            HubView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .destinations:
                        DestinationsListView()
                    case .itinerary(let destinationId):
                        ItineraryListView(focusDestinationId: destinationId)
                    case .packing(let destinationId):
                        PackingListView(destinationId: destinationId)
                    case .clocks:
                        WorldClocksView()
                    case .stampsMap:
                        StampMapView()
                    case .stats:
                        StatsView()
                    case .settings:
                        SettingsView()
                    }
                }
        }
        .environmentObject(store)
        .environmentObject(router)
        .preferredColorScheme(.dark)
        .tint(Color("AppPrimary"))
    }
}
