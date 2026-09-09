import SwiftUI

struct WorldClocksView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = ClocksViewModel()
    @State private var leftClockId: UUID?
    @State private var rightClockId: UUID?

    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Local hours")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextSecondary"))

                Toggle(isOn: $store.use24Hour) {
                    Text(store.use24Hour ? "24-hour format" : "12-hour format")
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .tint(Color("AppPrimary"))
                .padding()
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay { StampCorners() }

                VStack(alignment: .leading, spacing: 10) {
                    GradientCapsuleButton(title: "Add clock", systemImage: "plus") {
                        viewModel.isPickerPresented = true
                    }
                    GradientCapsuleButton(
                        title: "Add clock from trip",
                        systemImage: "globe.americas.fill",
                        isEnabled: !store.destinations.isEmpty
                    ) {
                        addFromTrip()
                    }
                }

                if store.clocks.count >= 2 {
                    overlapBlock
                }

                if store.clocks.isEmpty {
                    EmptyStateBlock(
                        title: "Add your first world clock",
                        systemImage: "globe"
                    )
                } else {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(store.clocks) { clock in
                                clockCell(clock, at: context.date)
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
                Text("World clocks")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            if leftClockId == nil { leftClockId = store.clocks.first?.id }
            if rightClockId == nil { rightClockId = store.clocks.dropFirst().first?.id }
        }
        .sheet(isPresented: $viewModel.isPickerPresented) {
            ClockPickerView(viewModel: viewModel)
                .environmentObject(store)
        }
        .alert(item: tripAlertBinding) { message in
            Alert(
                title: Text("Clock stamp"),
                message: Text(message.text),
                dismissButton: .default(Text("OK"))
            )
        }
        .confirmationDialog(
            "Stamp a city from a trip",
            isPresented: $viewModel.isTripPickerPresented,
            titleVisibility: .visible
        ) {
            ForEach(store.destinations) { destination in
                Button(destination.name) {
                    viewModel.addClockFromTrip(destination: destination, store: store)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func addFromTrip() {
        if store.destinations.count == 1, let destination = store.destinations.first {
            viewModel.addClockFromTrip(destination: destination, store: store)
        } else if !store.destinations.isEmpty {
            viewModel.isTripPickerPresented = true
        }
    }

    private func clockCell(_ clock: WorldClock, at date: Date) -> some View {
        VStack(spacing: 10) {
            AnalogClockRing(
                date: date,
                clock: clock,
                isDaylight: viewModel.isDaylight(for: clock, at: date),
                timeText: viewModel.timeString(for: clock, at: date, use24Hour: store.use24Hour)
            )
            Button {
                store.deleteClock(clock)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.4), lineWidth: 1)
        }
        .overlay { StampCorners() }
    }

    private var overlapBlock: some View {
        let left = store.clocks.first(where: { $0.id == leftClockId }) ?? store.clocks[0]
        let right = store.clocks.first(where: { $0.id == rightClockId }) ?? store.clocks[1]
        return VStack(alignment: .leading, spacing: 12) {
            Text("Call overlap")
                .ticketLabel()
                .foregroundStyle(Color("AppTextSecondary"))

            HStack(spacing: 12) {
                clockPicker("From", selection: $leftClockId)
                clockPicker("To", selection: $rightClockId)
            }

            TimelineView(.periodic(from: .now, by: 60)) { context in
                let delta = viewModel.hourDelta(from: left, to: right, at: context.date)
                VStack(alignment: .leading, spacing: 8) {
                    Text(delta == 0 ? "Same local hour" : "\(abs(delta))h \(delta > 0 ? "ahead" : "behind")")
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(viewModel.overlapText(left: left, right: right, at: context.date, use24Hour: store.use24Hour))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.35), lineWidth: 1)
        }
        .overlay { StampCorners() }
    }

    private func clockPicker(_ title: String, selection: Binding<UUID?>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .ticketLabel()
                .foregroundStyle(Color("AppTextSecondary"))
            Picker(title, selection: selection) {
                ForEach(store.clocks) { clock in
                    Text(clock.city).tag(Optional(clock.id))
                }
            }
            .tint(Color("AppPrimary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var tripAlertBinding: Binding<ClockAlertMessage?> {
        Binding(
            get: {
                viewModel.tripAlert.map(ClockAlertMessage.init)
            },
            set: { newValue in
                viewModel.tripAlert = newValue?.text
            }
        )
    }
}

private struct ClockAlertMessage: Identifiable {
    let text: String
    var id: String { text }
}
