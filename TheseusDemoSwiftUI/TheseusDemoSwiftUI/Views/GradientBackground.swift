import SwiftUI

struct GradientBackground: View {
    var isDarkMode: Bool

    var body: some View {
        LinearGradient(
            colors: isDarkMode
                ? [Color(red: 0.15, green: 0.15, blue: 0.20),
                   Color(red: 0.20, green: 0.18, blue: 0.25),
                   Color(red: 0.18, green: 0.20, blue: 0.28)]
                : [Color(red: 0.95, green: 0.85, blue: 0.82),
                   Color(red: 0.92, green: 0.80, blue: 0.85),
                   Color(red: 0.88, green: 0.78, blue: 0.82)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GradientBackground(isDarkMode: false)
}
