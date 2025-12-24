import SwiftUI
import Theseus

struct GlassViewDemoView: View {
    @State private var showingSettings = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    // Settings
    @State private var blurRadius: Float = 20.0
    @State private var cornerRadius: Float = 24.0
    @State private var opacity: Float = 1.0

    var body: some View {
        ZStack {
            // Colorful background to show glass effect
            LinearGradient(
                colors: isDarkMode
                    ? [Color(red: 0.1, green: 0.1, blue: 0.2),
                       Color(red: 0.2, green: 0.15, blue: 0.3),
                       Color(red: 0.15, green: 0.2, blue: 0.35)]
                    : [Color(red: 1.0, green: 0.6, blue: 0.5),
                       Color(red: 0.9, green: 0.5, blue: 0.7),
                       Color(red: 0.6, green: 0.4, blue: 0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative shapes behind glass
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.6))
                        .frame(width: 120, height: 120)
                        .offset(x: -80, y: -150)

                    Circle()
                        .fill(Color.blue.opacity(0.6))
                        .frame(width: 80, height: 80)
                        .offset(x: 100, y: -100)

                    Circle()
                        .fill(Color.green.opacity(0.6))
                        .frame(width: 100, height: 100)
                        .offset(x: -60, y: 120)

                    Circle()
                        .fill(Color.purple.opacity(0.6))
                        .frame(width: 60, height: 60)
                        .offset(x: 120, y: 100)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Glass view in center
            VStack {
                Text("Theseus Glass View")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)

                GlassViewContainerRepresentable(
                    blurRadius: CGFloat(blurRadius),
                    cornerRadius: CGFloat(cornerRadius),
                    opacity: CGFloat(opacity)
                )
                .frame(width: 200, height: 120)

                Text("Drag to interact")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
            }
        }
        .navigationTitle("Glass View")
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
            GlassViewSettingsSheet(
                blurRadius: $blurRadius,
                cornerRadius: $cornerRadius,
                opacity: $opacity
            )
        }
    }
}

struct GlassViewContainerRepresentable: UIViewRepresentable {
    var blurRadius: CGFloat
    var cornerRadius: CGFloat
    var opacity: CGFloat

    func makeUIView(context: Context) -> GlassViewContainer {
        let container = GlassViewContainer()
        container.updateConfiguration(
            blurRadius: blurRadius,
            cornerRadius: cornerRadius,
            opacity: opacity
        )
        return container
    }

    func updateUIView(_ uiView: GlassViewContainer, context: Context) {
        uiView.updateConfiguration(
            blurRadius: blurRadius,
            cornerRadius: cornerRadius,
            opacity: opacity
        )
    }
}

class GlassViewContainer: UIView {
    private var theseusView: TheseusView?
    private var gestureHandler: TheseusGestureDeformer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        clipsToBounds = false

        var config = TheseusConfiguration()
        config.blur.radius = 20
        config.shape.cornerRadius = 24
        config.shape.padding = CGPoint(x: 15, y: 15)

        let glass = TheseusView(configuration: config)
        glass.frame = bounds
        glass.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(glass)

        theseusView = glass

        gestureHandler = TheseusGestureDeformer(targetView: glass)
        gestureHandler?.positionProvider = { translation, currentCenter, bounds in
            return CGPoint(
                x: currentCenter.x + translation.x,
                y: currentCenter.y + translation.y
            )
        }
    }

    func updateConfiguration(blurRadius: CGFloat, cornerRadius: CGFloat, opacity: CGFloat) {
        theseusView?.blur.radius = blurRadius
        theseusView?.shape.cornerRadius = cornerRadius
        theseusView?.opacity = opacity
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if let rootView = window?.rootViewController?.view {
            theseusView?.sourceView = rootView
        }
    }
}

struct GlassViewSettingsSheet: View {
    @Binding var blurRadius: Float
    @Binding var cornerRadius: Float
    @Binding var opacity: Float
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Blur Radius: \(String(format: "%.0f", blurRadius))") {
                    Slider(value: $blurRadius, in: 0...50)
                }

                Section("Corner Radius: \(String(format: "%.0f", cornerRadius))") {
                    Slider(value: $cornerRadius, in: 0...60)
                }

                Section("Opacity: \(String(format: "%.2f", opacity))") {
                    Slider(value: $opacity, in: 0...1)
                }

                Section {
                    Button("Reset to Defaults", role: .destructive) {
                        blurRadius = 20.0
                        cornerRadius = 24.0
                        opacity = 1.0
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
        GlassViewDemoView()
    }
}
