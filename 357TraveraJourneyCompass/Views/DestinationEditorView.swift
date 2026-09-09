import SwiftUI

struct DestinationEditorView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DestinationsViewModel

    let destination: Destination?

    @State private var name: String = ""
    @State private var country: String = ""
    @State private var visitDate: Date = Date()
    @State private var notes: String = ""
    @State private var visited: Bool = false
    @State private var tracksPassport = false
    @State private var passportExpiry = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Passenger details")
                        .ticketLabel()
                        .foregroundStyle(Color("AppTextSecondary"))

                    fieldBlock(title: "Destination") {
                        TextField("City or region", text: $name)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }

                    fieldBlock(title: "Country") {
                        TextField("Country", text: $country)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }

                    fieldBlock(title: "Visit date") {
                        DatePicker("", selection: $visitDate, displayedComponents: .date)
                            .labelsHidden()
                            .tint(Color("AppPrimary"))
                    }

                    fieldBlock(title: "Notes") {
                        TextField("Cabin notes", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }

                    Toggle(isOn: $visited) {
                        Text("Visited")
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .tint(Color("AppPrimary"))
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay { StampCorners() }

                    Toggle(isOn: $tracksPassport) {
                        Text("Track passport expiry")
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .tint(Color("AppPrimary"))
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay { StampCorners() }

                    if tracksPassport {
                        fieldBlock(title: "Passport expiry") {
                            DatePicker("", selection: $passportExpiry, displayedComponents: .date)
                                .labelsHidden()
                                .tint(Color("AppPrimary"))
                        }
                        if let warning = Destination(
                            name: name,
                            country: country,
                            visitDate: visitDate,
                            notes: notes,
                            visited: visited,
                            passportExpiry: passportExpiry
                        ).passportValidityWarning() {
                            Text(warning)
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }

                    if let validationMessage = viewModel.validationMessage {
                        Text(validationMessage)
                            .foregroundStyle(Color("AppPrimary"))
                    }

                    GradientCapsuleButton(title: "Save stamp", systemImage: "checkmark.seal.fill") {
                        _ = viewModel.save(
                            name: name,
                            country: country,
                            visitDate: visitDate,
                            notes: notes,
                            visited: visited,
                            passportExpiry: tracksPassport ? passportExpiry : nil,
                            store: store
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .travelScreen()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(destination == nil ? "New destination" : "Edit destination")
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
            if let destination {
                name = destination.name
                country = destination.country
                visitDate = destination.visitDate
                notes = destination.notes
                visited = destination.visited
                tracksPassport = destination.passportExpiry != nil
                passportExpiry = destination.passportExpiry ?? destination.visitDate
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
