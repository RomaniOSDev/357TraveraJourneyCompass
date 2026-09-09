import Foundation

enum AppRoute: Hashable {
    case destinations
    case itinerary(destinationId: UUID?)
    case packing(destinationId: UUID)
    case clocks
    case stampsMap
    case stats
    case settings
}
