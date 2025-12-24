import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: TabBarDemoView()) {
                    DemoRow(
                        icon: "rectangle.split.3x1",
                        title: "Tab Bar",
                        description: "Liquid glass tab bar component"
                    )
                }

                NavigationLink(destination: SwitchDemoView()) {
                    DemoRow(
                        icon: "switch.2",
                        title: "Switch",
                        description: "Toggle switch with glass morphing"
                    )
                }

                NavigationLink(destination: SliderDemoView()) {
                    DemoRow(
                        icon: "slider.horizontal.3",
                        title: "Slider",
                        description: "Slider with liquid glass knob"
                    )
                }

                NavigationLink(destination: GlassViewDemoView()) {
                    DemoRow(
                        icon: "rectangle.on.rectangle",
                        title: "Glass View",
                        description: "Custom glass effect view"
                    )
                }

                NavigationLink(destination: SettingsView()) {
                    DemoRow(
                        icon: "gearshape.fill",
                        title: "Settings",
                        description: "Configure device tier and quality"
                    )
                }
            }
            .navigationTitle("Theseus Demo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isDarkMode.toggle() }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct DemoRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}
