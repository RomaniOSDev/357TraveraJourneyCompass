import SwiftUI

struct EmptyStateBlock: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: systemImage)
                .font(.system(size: 52, weight: .regular))
                .foregroundStyle(Color("AppPrimary"))
                .padding(22)
                .background(Color.white.opacity(0.08))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color("AppPrimary").opacity(0.5), lineWidth: 1.4))
            Text(title)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 56)
        .padding(.horizontal, 24)
    }
}
