import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Cabin desk")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextSecondary"))

                settingsRow(title: "Rate Us", systemImage: "star.fill") {
                    viewModel.rateUs()
                }
                settingsRow(title: "Privacy", systemImage: "hand.raised.fill") {
                    viewModel.openPrivacy()
                }
                settingsRow(title: "Terms", systemImage: "doc.plaintext.fill") {
                    viewModel.openTerms()
                }

                GradientCapsuleButton(title: "Reset", systemImage: "arrow.counterclockwise") {
                    viewModel.isResetPresented = true
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .travelScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Reset all stamps?", isPresented: $viewModel.isResetPresented) {
            Button("Reset", role: .destructive) {
                viewModel.reset(store: store)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Destinations, itinerary coupons, and world clocks will be cleared.")
        }
    }

    private func settingsRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            BoardingPassCard(stubWidth: 70) {
                Image(systemName: systemImage)
                    .foregroundStyle(Color("AppPrimary"))
            } main: {
                HStack {
                    Text(title)
                        .ticketLabel()
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
