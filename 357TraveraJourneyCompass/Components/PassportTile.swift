import SwiftUI

struct PassportTile: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color("AppPrimary"))
                .frame(width: 52, height: 52)
                .background(Color.white.opacity(0.08))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color("AppPrimary").opacity(0.8), lineWidth: 1.4))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .ticketLabel()
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(subtitle)
                    .foregroundStyle(Color("AppTextSecondary"))
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
        }
        .padding(18)
        .background(Color("AppSurface"))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.55), lineWidth: 1.6)
        }
        .overlay { StampCorners() }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: Color("AppBackground"), radius: 10, x: 0, y: 8)
        .shadow(color: Color("AppPrimary"), radius: 2, x: 0, y: 2)
    }
}
