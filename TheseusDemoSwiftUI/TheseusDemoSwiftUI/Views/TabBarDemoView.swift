import SwiftUI
import Theseus

struct TabBarDemoView: View {
    @State private var selectedIndex = 0
    @State private var nativeSelectedIndex = 0
    @State private var showingSettings = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    // Settings
    @State private var tintColorIndex = 0
    @State private var blurRadius: Float = 3.0
    @State private var refractionFactor: Float = 1.42

    private let tintColors: [Color] = [.blue, .purple, .pink, .orange]
    private let tintUIColors: [UIColor] = [.systemBlue, .systemPurple, .systemPink, .systemOrange]

    private var tabItems: [TheseusTabBarItem] {
        [
            TheseusTabBarItem(icon: UIImage(systemName: "doc.text.image"), title: "Today"),
            TheseusTabBarItem(icon: UIImage(systemName: "gamecontroller"), title: "Games"),
            TheseusTabBarItem(icon: UIImage(systemName: "square.stack.3d.up.fill"), title: "Apps"),
            TheseusTabBarItem(icon: UIImage(systemName: "dpad.fill"), title: "Arcade"),
            TheseusTabBarItem(icon: UIImage(systemName: "magnifyingglass"), title: "Search")
        ]
    }

    var body: some View {
        ZStack {
            GradientBackground(isDarkMode: isDarkMode)

            VStack(spacing: 40) {
                // Native TabBar
                VStack(alignment: .leading, spacing: 8) {
                    Text("Native UITabBar")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    NativeTabBarRepresentable(
                        selectedIndex: $nativeSelectedIndex,
                        tintColor: tintUIColors[tintColorIndex]
                    )
                    .frame(height: 49)
                    .onChange(of: nativeSelectedIndex) { newValue in
                        selectedIndex = newValue
                    }
                }

                // Theseus TabBar
                VStack(alignment: .leading, spacing: 8) {
                    Text("TheseusTabBar")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    TheseusTabBarRepresentable(
                        items: tabItems,
                        selectedIndex: $selectedIndex,
                        selectedTintColor: tintUIColors[tintColorIndex],
                        unselectedTintColor: isDarkMode ? .white : .black,
                        glassBlurRadius: CGFloat(blurRadius),
                        glassRefractionFactor: CGFloat(refractionFactor)
                    )
                    .frame(height: 60)
                    .onChange(of: selectedIndex) { newValue in
                        nativeSelectedIndex = newValue
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("Tab Bar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { isDarkMode.toggle() }) {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                }
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            TabBarSettingsSheet(
                tintColorIndex: $tintColorIndex,
                blurRadius: $blurRadius,
                refractionFactor: $refractionFactor
            )
        }
    }
}

struct NativeTabBarRepresentable: UIViewRepresentable {
    @Binding var selectedIndex: Int
    var tintColor: UIColor

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITabBar {
        let tabBar = UITabBar()
        tabBar.items = [
            UITabBarItem(title: "Today", image: UIImage(systemName: "doc.text.image"), tag: 0),
            UITabBarItem(title: "Games", image: UIImage(systemName: "gamecontroller"), tag: 1),
            UITabBarItem(title: "Apps", image: UIImage(systemName: "square.stack.3d.up.fill"), tag: 2),
            UITabBarItem(title: "Arcade", image: UIImage(systemName: "dpad.fill"), tag: 3),
            UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 4)
        ]
        tabBar.selectedItem = tabBar.items?[selectedIndex]
        tabBar.tintColor = tintColor
        tabBar.delegate = context.coordinator
        return tabBar
    }

    func updateUIView(_ uiView: UITabBar, context: Context) {
        uiView.selectedItem = uiView.items?[selectedIndex]
        uiView.tintColor = tintColor
    }

    class Coordinator: NSObject, UITabBarDelegate {
        var parent: NativeTabBarRepresentable

        init(_ parent: NativeTabBarRepresentable) {
            self.parent = parent
        }

        func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            if let index = tabBar.items?.firstIndex(of: item) {
                parent.selectedIndex = index
            }
        }
    }
}

struct TabBarSettingsSheet: View {
    @Binding var tintColorIndex: Int
    @Binding var blurRadius: Float
    @Binding var refractionFactor: Float
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Tab Tint Color") {
                    Picker("Color", selection: $tintColorIndex) {
                        Text("Blue").tag(0)
                        Text("Purple").tag(1)
                        Text("Pink").tag(2)
                        Text("Orange").tag(3)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Blur Radius: \(String(format: "%.1f", blurRadius))") {
                    Slider(value: $blurRadius, in: 0...15)
                }

                Section("Refraction Factor: \(String(format: "%.2f", refractionFactor))") {
                    Slider(value: $refractionFactor, in: 0.5...2.5)
                }

                Section {
                    Button("Reset to Defaults", role: .destructive) {
                        tintColorIndex = 0
                        blurRadius = 3.0
                        refractionFactor = 1.42
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        TabBarDemoView()
    }
}
