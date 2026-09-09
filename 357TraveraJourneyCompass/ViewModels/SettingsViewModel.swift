import UIKit
import StoreKit
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var isResetPresented = false

    func rateUs() {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
        if let scene = scenes.first {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    func openPrivacy() {
        if let url = URL(string: AppLinks.privacy) {
            UIApplication.shared.open(url)
        }
    }

    func openTerms() {
        if let url = URL(string: AppLinks.terms) {
            UIApplication.shared.open(url)
        }
    }

    func reset(store: DataStore) {
        store.resetAll()
        isResetPresented = false
    }
}
