import Foundation
import Combine

final class ItineraryViewModel: ObservableObject {
    @Published var isEditorPresented = false
    @Published var editingItem: ItineraryItem?
    @Published var pendingDelete: ItineraryItem?
    @Published var validationMessage: String?

    func presentNew() {
        editingItem = nil
        validationMessage = nil
        isEditorPresented = true
    }

    func presentEdit(_ item: ItineraryItem) {
        editingItem = item
        validationMessage = nil
        isEditorPresented = true
    }

    func save(
        title: String,
        details: String,
        date: Date,
        category: ItineraryCategory,
        destinationId: UUID?,
        store: DataStore
    ) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            validationMessage = "Enter a title for this coupon."
            return false
        }
        guard let destinationId else {
            validationMessage = "Stamp this item with a destination."
            return false
        }

        let item = ItineraryItem(
            id: editingItem?.id ?? UUID(),
            title: trimmedTitle,
            details: details.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            completed: editingItem?.completed ?? false,
            tripDestinationId: destinationId,
            category: category
        )
        store.upsertItineraryItem(item)
        isEditorPresented = false
        editingItem = nil
        validationMessage = nil
        return true
    }

    func confirmDelete(_ item: ItineraryItem) {
        pendingDelete = item
    }

    func performDelete(store: DataStore) {
        guard let pendingDelete else { return }
        store.deleteItineraryItem(id: pendingDelete.id)
        self.pendingDelete = nil
    }
}
