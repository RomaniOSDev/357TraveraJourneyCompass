import Foundation

struct PackingItem: Identifiable, Codable, Hashable {
    var id: UUID
    var destinationId: UUID
    var title: String
    var packed: Bool

    init(
        id: UUID = UUID(),
        destinationId: UUID,
        title: String,
        packed: Bool = false
    ) {
        self.id = id
        self.destinationId = destinationId
        self.title = title
        self.packed = packed
    }
}
