import SwiftUI

struct TicketLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption.weight(.semibold))
            .tracking(2)
            .textCase(.uppercase)
    }
}

struct TravelScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color("AppBackground").overlay {
                    Image("bg_alps").resizable().scaledToFill().opacity(0.30)
                }.clipped().ignoresSafeArea()
            }
            .background(WindowKeyboardDismissInstaller())
            .scrollDismissesKeyboard(.interactively)
    }
}

extension View {
    func ticketLabel() -> some View {
        modifier(TicketLabelModifier())
    }

    func travelScreen() -> some View {
        modifier(TravelScreenBackground())
    }
}

struct TicketSearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .foregroundStyle(Color("AppTextPrimary"))
            .padding()
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color("AppPrimary").opacity(0.35), lineWidth: 1)
            }
    }
}
