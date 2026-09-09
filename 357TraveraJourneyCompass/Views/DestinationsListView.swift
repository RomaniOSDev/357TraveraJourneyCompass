import SwiftUI

private enum DestinationFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case planned = "Planned"
    case visited = "Visited"

    var id: String { rawValue }
}

struct DestinationsListView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = DestinationsViewModel()
    @State private var query = ""
    @State private var filter: DestinationFilter = .all

    private var filteredDestinations: [Destination] {
        store.destinations
            .filter { destination in
                switch filter {
                case .all: return true
                case .planned: return !destination.visited
                case .visited: return destination.visited
                }
            }
            .filter { destination in
                let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !needle.isEmpty else { return true }
                return destination.name.localizedCaseInsensitiveContains(needle)
                    || destination.country.localizedCaseInsensitiveContains(needle)
            }
            .sorted { $0.visitDate < $1.visitDate }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Passenger routes")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextSecondary"))

                TicketSearchField(placeholder: "Search city or country", text: $query)

                Picker("Filter", selection: $filter) {
                    ForEach(DestinationFilter.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                if store.destinations.isEmpty {
                    EmptyStateBlock(
                        title: "Explore Your Next Adventure",
                        systemImage: "globe"
                    )
                } else if filteredDestinations.isEmpty {
                    EmptyStateBlock(
                        title: "No stamps match this filter",
                        systemImage: "magnifyingglass"
                    )
                } else {
                    ForEach(filteredDestinations) { destination in
                        SwipeablePass(
                            actions: [
                                SwipePassAction(
                                    title: destination.visited ? "Plan" : "Visited",
                                    systemImage: destination.visited ? "airplane.departure" : "checkmark.seal.fill"
                                ) {
                                    store.toggleVisited(destination)
                                }
                            ]
                        ) {
                            DestinationPassCard(
                                destination: destination,
                                onEdit: { viewModel.presentEdit(destination) },
                                onBuild: {
                                    viewModel.bridgeToItinerary(
                                        destination: destination,
                                        store: store,
                                        router: router
                                    )
                                },
                                onPack: {
                                    router.path.append(AppRoute.packing(destinationId: destination.id))
                                },
                                onDuplicate: {
                                    let copy = store.duplicateDestination(destination)
                                    router.path.append(AppRoute.itinerary(destinationId: copy.id))
                                }
                            )
                        }
                    }
                }
            }
            .padding(20)
        }
        .travelScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Destinations")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.presentNew()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $viewModel.isEditorPresented) {
            DestinationEditorView(viewModel: viewModel, destination: viewModel.editingDestination)
                .environmentObject(store)
        }
    }
}

private struct DestinationPassCard: View {
    let destination: Destination
    let onEdit: () -> Void
    let onBuild: () -> Void
    let onPack: () -> Void
    let onDuplicate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if CityTimeZoneMap.isAsianCountry(destination.country) {
                Image("tile_kyoto")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 72)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            BoardingPassCard {
                VStack(spacing: 8) {
                    Image(systemName: destination.visited ? "checkmark.seal.fill" : "airplane.departure")
                        .foregroundStyle(Color("AppPrimary"))
                    Text(countryCode)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Gate")
                        .ticketLabel()
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            } main: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(destination.name)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(destination.country)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(destination.visitDate.formatted(date: .abbreviated, time: .omitted))
                        .ticketLabel()
                        .foregroundStyle(Color("AppPrimary"))
                    if let warning = destination.passportValidityWarning() {
                        Text(warning)
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    if !destination.notes.isEmpty {
                        Text(destination.notes)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(3)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        GradientCapsuleButton(title: "Edit", systemImage: "pencil") {
                            onEdit()
                        }
                        GradientCapsuleButton(title: "Build itinerary", systemImage: "ticket.fill") {
                            onBuild()
                        }
                        GradientCapsuleButton(title: "Packing list", systemImage: "suitcase.fill") {
                            onPack()
                        }
                        GradientCapsuleButton(title: "Duplicate trip", systemImage: "plus.square.on.square") {
                            onDuplicate()
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private var countryCode: String {
        let letters = destination.country.uppercased().filter(\.isLetter)
        if letters.count >= 2 {
            return String(letters.prefix(3))
        }
        return "XXX"
    }
}
