import SwiftUI
import Combine

final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
}
