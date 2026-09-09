import SwiftUI

struct PackingListView: View {
    @EnvironmentObject private var store: DataStore
    let destinationId: UUID
    @State private var draft = ""

    private var destination: Destination? {
        store.destination(id: destinationId)
    }

    private var items: [PackingItem] {
        store.packingItems(forDestinationId: destinationId)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(destination?.name ?? "Packing")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextSecondary"))

                TicketSearchField(placeholder: "Add a packing item", text: $draft)

                GradientCapsuleButton(
                    title: "Add item",
                    systemImage: "plus",
                    isEnabled: !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ) {
                    addItem()
                }

                GradientCapsuleButton(title: "Starter kit", systemImage: "suitcase.fill") {
                    store.addStarterPack(destinationId: destinationId)
                }

                if items.isEmpty {
                    EmptyStateBlock(
                        title: "Nothing packed for this stamp yet",
                        systemImage: "suitcase"
                    )
                } else {
                    ForEach(items) { item in
                        SwipeablePass(
                            actions: [
                                SwipePassAction(
                                    title: "Delete",
                                    systemImage: "trash",
                                    isDestructive: true
                                ) {
                                    store.deletePackingItem(id: item.id)
                                }
                            ]
                        ) {
                            BoardingPassCard(stubWidth: 72) {
                                Image(systemName: item.packed ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(Color("AppPrimary"))
                            } main: {
                                Toggle(item.title, isOn: Binding(
                                    get: { item.packed },
                                    set: { _ in store.togglePacked(id: item.id) }
                                ))
                                .tint(Color("AppPrimary"))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .strikethrough(item.packed, color: Color("AppTextSecondary"))
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
                Text("Packing list")
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func addItem() {
        let title = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        store.upsertPackingItem(PackingItem(destinationId: destinationId, title: title))
        draft = ""
        KeyboardDismiss.hide()
    }
}
