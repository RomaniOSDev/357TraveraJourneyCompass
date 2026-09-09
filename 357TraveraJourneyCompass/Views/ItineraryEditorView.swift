import SwiftUI

struct ItineraryEditorView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ItineraryViewModel

    let item: ItineraryItem?
    let defaultDestinationId: UUID?

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var date: Date = Date()
    @State private var category: ItineraryCategory = .flight
    @State private var destinationId: UUID?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Coupon details")
                        .ticketLabel()
                        .foregroundStyle(Color("AppTextSecondary"))

                    fieldBlock(title: "Title") {
                        TextField("Flight, stay, or activity", text: $title)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }

                    fieldBlock(title: "Details") {
                        TextField("Seat, address, or notes", text: $details, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }

                    fieldBlock(title: "When") {
                        DatePicker("", selection: $date)
                            .labelsHidden()
                            .tint(Color("AppPrimary"))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .ticketLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                        Picker("Category", selection: $category) {
                            ForEach(ItineraryCategory.allCases) { item in
                                Text(item.rawValue).tag(item)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Destination")
                            .ticketLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                        if store.destinations.isEmpty {
                            Text("Add a destination first.")
                                .foregroundStyle(Color("AppTextSecondary"))
                        } else {
                            Picker("Destination", selection: $destinationId) {
                                Text("Choose a stamp").tag(Optional<UUID>.none)
                                ForEach(store.destinations) { destination in
                                    Text(destination.name).tag(Optional(destination.id))
                                }
                            }
                            .tint(Color("AppPrimary"))
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }

                    if let validationMessage = viewModel.validationMessage {
                        Text(validationMessage)
                            .foregroundStyle(Color("AppPrimary"))
                    }

                    GradientCapsuleButton(title: "Save coupon", systemImage: "checkmark.seal.fill") {
                        _ = viewModel.save(
                            title: title,
                            details: details,
                            date: date,
                            category: category,
                            destinationId: destinationId,
                            store: store
                        )
                    }
                }
                .padding(20)
            }
            .travelScreen()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(item == nil ? "New coupon" : "Edit coupon")
                        .ticketLabel()
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            if let item {
                title = item.title
                details = item.details
                date = item.date
                category = item.category
                destinationId = item.tripDestinationId
            } else {
                destinationId = defaultDestinationId ?? store.destinations.first?.id
            }
            viewModel.validationMessage = nil
        }
        .onChange(of: viewModel.isEditorPresented) { presented in
            if !presented {
                dismiss()
            }
        }
    }

    private func fieldBlock<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .ticketLabel()
                .foregroundStyle(Color("AppTextSecondary"))
            content()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color("AppPrimary").opacity(0.35), lineWidth: 1)
                }
        }
    }
}
