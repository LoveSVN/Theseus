import UIKit

final class AppearanceManager {
    static let shared = AppearanceManager()

    private let key = "isDarkMode"

    var isDarkMode: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            applyAppearance()
        }
    }

    func applyAppearance() {
        let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { $0.overrideUserInterfaceStyle = style }
        }
    }
}
