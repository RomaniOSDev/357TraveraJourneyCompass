import SwiftUI

struct SwipePassAction: Identifiable {
    let title: String
    let systemImage: String
    var isDestructive: Bool = false
    let handler: () -> Void

    var id: String { title }
}

struct SwipeablePass<Content: View>: View {
    let actions: [SwipePassAction]
    @ViewBuilder var content: () -> Content

    @State private var offset: CGFloat = 0

    private var revealedWidth: CGFloat {
        CGFloat(actions.count) * 78
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 8) {
                ForEach(actions) { action in
                    Button {
                        action.handler()
                        withAnimation(.easeOut(duration: 0.18)) { offset = 0 }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: action.systemImage)
                            Text(action.title)
                                .font(.caption2.weight(.semibold))
                                .lineLimit(1)
                        }
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(width: 70, height: 88)
                        .background(action.isDestructive ? Color.red.opacity(0.85) : Color("AppPrimary"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.trailing, 2)
            .opacity(offset < -8 ? 1 : 0)

            content()
                .offset(x: offset)
                .simultaneousGesture(drag)
        }
        .clipped()
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 24, coordinateSpace: .local)
            .onChanged { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                guard abs(horizontal) > abs(vertical) else { return }
                offset = min(0, max(-revealedWidth, horizontal))
            }
            .onEnded { value in
                let shouldOpen = value.translation.width < -(revealedWidth * 0.35)
                withAnimation(.easeOut(duration: 0.2)) {
                    offset = shouldOpen ? -revealedWidth : 0
                }
            }
    }
}
