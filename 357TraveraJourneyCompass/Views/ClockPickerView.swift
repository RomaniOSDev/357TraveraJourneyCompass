import SwiftUI

struct ClockPickerView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ClocksViewModel
    @State private var query = ""

    private var filtered: [CityTimeZoneEntry] {
        let all = CityTimeZoneMap.catalog.sorted { $0.city < $1.city }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return all }
        return all.filter { entry in
            entry.city.localizedCaseInsensitiveContains(trimmed)
                || entry.countryKeys.contains { key in
                    key.localizedCaseInsensitiveContains(trimmed)
                }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("City stamps")
                        .ticketLabel()
                        .foregroundStyle(Color("AppTextSecondary"))

                    TextField("Search cities", text: $query)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color("AppPrimary").opacity(0.35), lineWidth: 1)
                        }

                    ForEach(filtered) { entry in
                        let alreadyAdded = store.hasClock(city: entry.city)
                        Button {
                            if viewModel.add(entry: entry, store: store) {
                                dismiss()
                            }
                        } label: {
                            BoardingPassCard(stubWidth: 72) {
                                Image(systemName: alreadyAdded ? "checkmark.circle.fill" : "globe")
                                    .foregroundStyle(Color("AppPrimary"))
                            } main: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.city)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Text(entry.timeZoneIdentifier)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(alreadyAdded)
                        .opacity(alreadyAdded ? 0.45 : 1)
                    }
                }
                .padding(20)
            }
            .travelScreen()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add clock")
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
    }
}
