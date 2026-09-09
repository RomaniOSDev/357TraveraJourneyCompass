import SwiftUI
import MapKit

struct StampMapView: View {
    @EnvironmentObject private var store: DataStore
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 12),
        span: MKCoordinateSpan(latitudeDelta: 90, longitudeDelta: 90)
    )

    private var pins: [StampPin] {
        store.destinations.compactMap { destination in
            guard let coordinate = CityTimeZoneMap.coordinate(for: destination) else { return nil }
            return StampPin(
                id: destination.id,
                title: destination.name,
                visited: destination.visited,
                coordinate: coordinate
            )
        }
    }

    private var unmappedCount: Int {
        store.destinations.count - pins.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if store.destinations.isEmpty {
                EmptyStateBlock(
                    title: "Stamp a destination to drop a pin",
                    systemImage: "map"
                )
                .padding(.horizontal, 20)
            } else {
                Map(coordinateRegion: $region, annotationItems: pins) { pin in
                    MapAnnotation(coordinate: pin.coordinate) {
                        VStack(spacing: 4) {
                            Image(systemName: pin.visited ? "checkmark.seal.fill" : "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color("AppPrimary"))
                                .padding(6)
                                .background(Color("AppBackground").opacity(0.88))
                                .clipShape(Circle())
                            Text(pin.title)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color("AppBackground").opacity(0.82))
                                .clipShape(Capsule())
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color("AppPrimary").opacity(0.45), lineWidth: 1.2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Text(unmappedCount == 0 ? "\(pins.count) stamps on the map" : "\(pins.count) pins · \(unmappedCount) stamps need a mapped country")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .travelScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Stamp map")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            region = fittedRegion(for: pins)
        }
        .onChange(of: store.destinations) { _ in
            region = fittedRegion(for: pins)
        }
    }

    private func fittedRegion(for pins: [StampPin]) -> MKCoordinateRegion {
        guard let first = pins.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 20, longitude: 12),
                span: MKCoordinateSpan(latitudeDelta: 90, longitudeDelta: 90)
            )
        }
        var minLat = first.coordinate.latitude
        var maxLat = minLat
        var minLon = first.coordinate.longitude
        var maxLon = minLon
        for pin in pins {
            minLat = min(minLat, pin.coordinate.latitude)
            maxLat = max(maxLat, pin.coordinate.latitude)
            minLon = min(minLon, pin.coordinate.longitude)
            maxLon = max(maxLon, pin.coordinate.longitude)
        }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2),
            span: MKCoordinateSpan(
                latitudeDelta: max((maxLat - minLat) * 1.8, 10),
                longitudeDelta: max((maxLon - minLon) * 1.8, 10)
            )
        )
    }
}

private struct StampPin: Identifiable {
    let id: UUID
    let title: String
    let visited: Bool
    let coordinate: CLLocationCoordinate2D
}
