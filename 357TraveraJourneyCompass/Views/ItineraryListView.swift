import SwiftUI

private enum CouponStatusFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case open = "Open"
    case done = "Done"

    var id: String { rawValue }
}

private enum CouponCategoryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case flight = "Flight"
    case accommodation = "Stay"
    case activities = "Do"

    var id: String { rawValue }

    var category: ItineraryCategory? {
        switch self {
        case .all: return nil
        case .flight: return .flight
        case .accommodation: return .accommodation
        case .activities: return .activities
        }
    }
}

struct ItineraryListView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = ItineraryViewModel()
    var focusDestinationId: UUID?

    @State private var query = ""
    @State private var statusFilter: CouponStatusFilter = .all
    @State private var categoryFilter: CouponCategoryFilter = .all

    private var filteredItems: [ItineraryItem] {
        store.items(forDestinationId: focusDestinationId)
            .filter { item in
                switch statusFilter {
                case .all: return true
                case .open: return !item.completed
                case .done: return item.completed
                }
            }
            .filter { item in
                guard let category = categoryFilter.category else { return true }
                return item.category == category
            }
            .filter { item in
                let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !needle.isEmpty else { return true }
                return item.title.localizedCaseInsensitiveContains(needle)
                    || item.details.localizedCaseInsensitiveContains(needle)
                    || (store.destination(id: item.tripDestinationId)?.name.localizedCaseInsensitiveContains(needle) ?? false)
            }
    }

    private var timeline: [(date: Date, items: [ItineraryItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredItems) { item in
            calendar.startOfDay(for: item.date)
        }
        return grouped.keys.sorted().map { day in
            (day, grouped[day] ?? [])
        }
    }

    private var headerTitle: String {
        if let focusDestinationId, let destination = store.destination(id: focusDestinationId) {
            return destination.name
        }
        return "All coupons"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: 110)
                    .background {
                        Image("tile_kyoto")
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color("AppPrimary").opacity(0.4), lineWidth: 1)
                    }
                    .overlay(alignment: .bottomLeading) {
                        Text(headerTitle)
                            .ticketLabel()
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(12)
                            .background(Color("AppBackground").opacity(0.62))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .padding(12)
                    }

                Text("Travel coupons")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextSecondary"))

                TicketSearchField(placeholder: "Search coupons", text: $query)

                Picker("Status", selection: $statusFilter) {
                    ForEach(CouponStatusFilter.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Category", selection: $categoryFilter) {
                    ForEach(CouponCategoryFilter.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                if store.items(forDestinationId: focusDestinationId).isEmpty {
                    EmptyStateBlock(
                        title: "No itinerary yet",
                        systemImage: "calendar.badge.plus"
                    )
                } else if timeline.isEmpty {
                    EmptyStateBlock(
                        title: "No coupons match this filter",
                        systemImage: "magnifyingglass"
                    )
                } else {
                    ForEach(timeline, id: \.date) { bucket in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(Color("AppPrimary"))
                                    .frame(width: 10, height: 10)
                                    .padding(.top, 6)
                                Rectangle()
                                    .fill(Color("AppPrimary").opacity(0.45))
                                    .frame(width: 2)
                            }
                            .frame(width: 10)

                            VStack(alignment: .leading, spacing: 12) {
                                Text(bucket.date.formatted(date: .abbreviated, time: .omitted))
                                    .ticketLabel()
                                    .foregroundStyle(Color("AppPrimary"))

                                ForEach(bucket.items) { item in
                                    SwipeablePass(
                                        actions: [
                                            SwipePassAction(
                                                title: item.completed ? "Open" : "Done",
                                                systemImage: item.completed ? "arrow.uturn.backward" : "checkmark"
                                            ) {
                                                store.toggleItineraryCompleted(id: item.id)
                                            },
                                            SwipePassAction(
                                                title: "Delete",
                                                systemImage: "trash",
                                                isDestructive: true
                                            ) {
                                                viewModel.confirmDelete(item)
                                            }
                                        ]
                                    ) {
                                        ItineraryPassCard(
                                            item: item,
                                            destinationName: store.destination(id: item.tripDestinationId)?.name ?? "Open ticket",
                                            onToggle: { store.toggleItineraryCompleted(id: item.id) },
                                            onEdit: { viewModel.presentEdit(item) },
                                            onDelete: { viewModel.confirmDelete(item) }
                                        )
                                    }
                                }
                            }
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
                Text("Itinerary")
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
                .disabled(store.destinations.isEmpty)
            }
        }
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $viewModel.isEditorPresented) {
            ItineraryEditorView(
                viewModel: viewModel,
                item: viewModel.editingItem,
                defaultDestinationId: focusDestinationId
            )
            .environmentObject(store)
        }
        .confirmationDialog(
            "Delete this coupon?",
            isPresented: Binding(
                get: { viewModel.pendingDelete != nil },
                set: { if !$0 { viewModel.pendingDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.performDelete(store: store)
            }
            Button("Cancel", role: .cancel) {
                viewModel.pendingDelete = nil
            }
        } message: {
            Text("This boarding coupon will be removed from the itinerary.")
        }
    }
}

private struct ItineraryPassCard: View {
    let item: ItineraryItem
    let destinationName: String
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        BoardingPassCard {
            VStack(spacing: 8) {
                Image(systemName: item.category.systemImage)
                    .foregroundStyle(Color("AppPrimary"))
                Text(item.category.rawValue)
                    .ticketLabel()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        } main: {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .strikethrough(item.completed, color: Color("AppTextSecondary"))
                Text(destinationName)
                    .foregroundStyle(Color("AppTextSecondary"))
                if !item.details.isEmpty {
                    Text(item.details)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(3)
                }
                Text(item.date.formatted(date: .abbreviated, time: .shortened))
                    .ticketLabel()
                    .foregroundStyle(Color("AppPrimary"))

                Toggle("Complete", isOn: Binding(
                    get: { item.completed },
                    set: { _ in onToggle() }
                ))
                .tint(Color("AppPrimary"))
                .foregroundStyle(Color("AppTextPrimary"))

                VStack(alignment: .leading, spacing: 8) {
                    GradientCapsuleButton(title: "Edit", systemImage: "pencil") {
                        onEdit()
                    }
                    GradientCapsuleButton(title: "Delete", systemImage: "trash") {
                        onDelete()
                    }
                }
            }
        }
    }
}
