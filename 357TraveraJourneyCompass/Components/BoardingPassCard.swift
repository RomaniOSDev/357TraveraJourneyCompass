import SwiftUI

struct BoardingPassShape: Shape {
    var stubWidth: CGFloat = 86
    var cornerRadius: CGFloat = 16
    var notchRadius: CGFloat = 9

    func path(in rect: CGRect) -> Path {
        var path = Path(roundedRect: rect, cornerRadius: cornerRadius)
        let notchOrigin = CGPoint(x: stubWidth - notchRadius, y: rect.midY - notchRadius)
        path.addEllipse(in: CGRect(origin: notchOrigin, size: CGSize(width: notchRadius * 2, height: notchRadius * 2)))
        return path
    }
}

struct StampCorners: View {
    var body: some View {
        GeometryReader { _ in
            ZStack {
                stamp.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                stamp.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                stamp.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                stamp.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .padding(10)
        }
        .allowsHitTesting(false)
    }

    private var stamp: some View {
        Circle()
            .stroke(Color("AppPrimary").opacity(0.55), lineWidth: 1.4)
            .frame(width: 16, height: 16)
    }
}

struct DashedPerforation: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: geo.size.width / 2, y: 12))
                path.addLine(to: CGPoint(x: geo.size.width / 2, y: geo.size.height - 12))
            }
            .stroke(
                Color("AppTextSecondary").opacity(0.75),
                style: StrokeStyle(lineWidth: 1.4, lineCap: .round, dash: [5, 4])
            )
        }
        .allowsHitTesting(false)
    }
}

struct BoardingPassCard<Stub: View, Main: View>: View {
    var stubWidth: CGFloat = 86
    @ViewBuilder var stub: () -> Stub
    @ViewBuilder var main: () -> Main

    var body: some View {
        let shape = BoardingPassShape(stubWidth: stubWidth + 6)
        HStack(spacing: 0) {
            stub()
                .frame(width: stubWidth)
                .padding(.vertical, 16)
            DashedPerforation()
                .frame(width: 12)
            main()
                .padding(.vertical, 16)
                .padding(.trailing, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 8)
        .background {
            Color("AppSurface").overlay(Color.white.opacity(0.08))
        }
        .overlay {
            shape.stroke(Color("AppPrimary").opacity(0.45), lineWidth: 1.2)
        }
        .overlay { StampCorners() }
        .mask(shape.fill(Color("AppTextPrimary"), style: FillStyle(eoFill: true)))
    }
}
