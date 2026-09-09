import SwiftUI
import UIKit

enum KeyboardDismiss {
    static let recognizerName = "tjc.windowKeyboardDismiss"

    static func hide() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

final class KeyboardDismissTarget: NSObject, UIGestureRecognizerDelegate {
    static let shared = KeyboardDismissTarget()

    @objc func handleTap() {
        KeyboardDismiss.hide()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var view = touch.view
        while let current = view {
            if current is UITextField || current is UITextView {
                return false
            }
            view = current.superview
        }
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

struct WindowKeyboardDismissInstaller: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            attach(to: uiView.window)
        }
    }

    private func attach(to window: UIWindow?) {
        guard let window else { return }
        if window.gestureRecognizers?.contains(where: { $0.name == KeyboardDismiss.recognizerName }) == true {
            return
        }
        let tap = UITapGestureRecognizer(target: KeyboardDismissTarget.shared, action: #selector(KeyboardDismissTarget.handleTap))
        tap.cancelsTouchesInView = false
        tap.delegate = KeyboardDismissTarget.shared
        tap.name = KeyboardDismiss.recognizerName
        window.addGestureRecognizer(tap)
    }
}
