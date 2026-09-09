import Foundation
import Combine

final class DestinationsViewModel: ObservableObject {
    @Published var isEditorPresented = false
    @Published var editingDestination: Destination?
    @Published var validationMessage: String?

    func presentNew() {
        editingDestination = nil
        validationMessage = nil
        isEditorPresented = true
    }

    func presentEdit(_ destination: Destination) {
        editingDestination = destination
        validationMessage = nil
        isEditorPresented = true
    }

    func save(
        name: String,
        country: String,
        visitDate: Date,
        notes: String,
        visited: Bool,
        passportExpiry: Date?,
        store: DataStore
    ) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCountry = country.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            validationMessage = "Enter a destination name."
            return false
        }
        guard !trimmedCountry.isEmpty else {
            validationMessage = "Enter a country."
            return false
        }
        if store.hasDuplicateDestinationName(trimmedName, excluding: editingDestination?.id) {
            validationMessage = "That destination name is already on your pass."
            return false
        }

        let destination = Destination(
            id: editingDestination?.id ?? UUID(),
            name: trimmedName,
            country: trimmedCountry,
            visitDate: visitDate,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            visited: visited,
            passportExpiry: passportExpiry
        )
        store.upsertDestination(destination)
        isEditorPresented = false
        editingDestination = nil
        validationMessage = nil
        return true
    }

    func bridgeToItinerary(destination: Destination, store: DataStore, router: AppRouter) {
        if !store.hasItems(forDestinationId: destination.id) {
            let item = ItineraryItem(
                title: "Flight to \(destination.name)",
                details: "Outbound crossing — add airline and confirmation.",
                date: destination.visitDate,
                completed: false,
                tripDestinationId: destination.id,
                category: .flight
            )
            store.upsertItineraryItem(item)
        }
        router.path.append(AppRoute.itinerary(destinationId: destination.id))
    }
}
