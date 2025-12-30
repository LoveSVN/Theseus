import SwiftUI
import UIKit
import Theseus

struct HeroPreview: View {
    var body: some View {
        HeroContainerRepresentable()
            .frame(width: 400, height: 400)
    }
}

struct HeroContainerRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> HeroContainer {
        HeroContainer()
    }

    func updateUIView(_ uiView: HeroContainer, context: Context) {}
}

class HeroContainer: UIView {
    private let backgroundImageView = UIImageView()
    private var lens: TheseusView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        clipsToBounds = true
        backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        backgroundImageView.contentMode = .scaleAspectFit
        addSubview(backgroundImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.frame = bounds

        if lens == nil && bounds.width > 0 {
            setupBackground()
            setupLens()
        }
    }

    private func setupBackground() {
        if let logo = UIImage(named: "theseus_logo") {
            backgroundImageView.image = logo
        }
    }

    private func setupLens() {
        let lensSize: CGFloat = 140

        var config = TheseusConfiguration()
        config.blur.radius = 3.0
        config.shape.cornerRadius = lensSize / 2
        config.refraction.intensity = 1.42
        config.refraction.edgeWidth = 22.0
        config.refraction.dispersion = 4.0
        config.shape.padding = CGPoint(x: 15, y: 15)
        config.theme.tintColor = .clear
        config.edgeEffects.rimRange = 45.0
        config.edgeEffects.rimGlow = 1.0
        config.edgeEffects.rimHardness = 12.0
        config.edgeEffects.glareRange = 450.0
        config.edgeEffects.glareIntensity = 0.8
        config.edgeEffects.lightAngle = .pi * 0.75
        config.edgeEffects.glareFocus = 0.75
        config.edgeEffects.nearColor = .clear
        config.edgeEffects.farColor = .clear

        let glassLens = TheseusView(configuration: config)
        glassLens.sourceView = self
        glassLens.frame = CGRect(x: 0, y: 0, width: lensSize, height: lensSize)
        glassLens.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(glassLens)
        lens = glassLens

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        glassLens.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let lens = lens else { return }
        let translation = gesture.translation(in: self)
        lens.center = CGPoint(
            x: lens.center.x + translation.x,
            y: lens.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: self)
        lens.invalidateBackground()
    }
}

struct SwitchPreview: View {
    var body: some View {
        SwitchDualContainerRepresentable()
            .frame(width: 400, height: 400)
    }
}

struct SwitchDualContainerRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> SwitchDualContainer {
        SwitchDualContainer()
    }

    func updateUIView(_ uiView: SwitchDualContainer, context: Context) {}
}

class SwitchDualContainer: UIView {
    private let darkBackground = UIImageView()
    private let lightBackground = UIImageView()
    private var darkSwitch: TheseusSwitch?
    private var lightSwitch: TheseusSwitch?

    private let onColor = UIColor(red: 0.259, green: 0.831, blue: 0.318, alpha: 1.0)
    private let offColor = UIColor(white: 0.878, alpha: 1.0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        clipsToBounds = true
        addSubview(darkBackground)
        addSubview(lightBackground)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let halfHeight = bounds.height / 2
        darkBackground.frame = CGRect(x: 0, y: 0, width: bounds.width, height: halfHeight)
        lightBackground.frame = CGRect(x: 0, y: halfHeight, width: bounds.width, height: halfHeight)

        if darkSwitch == nil && bounds.width > 0 {
            setupBackgrounds()
            setupSwitches()
        }
    }

    private func setupBackgrounds() {
        darkBackground.image = renderGradient(isDark: true, size: darkBackground.bounds.size)
        lightBackground.image = renderGradient(isDark: false, size: lightBackground.bounds.size)
    }

    private func renderGradient(isDark: Bool, size: CGSize) -> UIImage {
        guard size.width > 0, size.height > 0 else { return UIImage() }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(origin: .zero, size: size)
            if isDark {
                gradientLayer.colors = [
                    UIColor(red: 0.15, green: 0.15, blue: 0.20, alpha: 1.0).cgColor,
                    UIColor(red: 0.20, green: 0.18, blue: 0.25, alpha: 1.0).cgColor,
                    UIColor(red: 0.18, green: 0.20, blue: 0.28, alpha: 1.0).cgColor
                ]
            } else {
                gradientLayer.colors = [
                    UIColor(red: 0.95, green: 0.85, blue: 0.82, alpha: 1.0).cgColor,
                    UIColor(red: 0.92, green: 0.80, blue: 0.85, alpha: 1.0).cgColor,
                    UIColor(red: 0.88, green: 0.78, blue: 0.82, alpha: 1.0).cgColor
                ]
            }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.render(in: ctx.cgContext)
        }
    }

    private func setupSwitches() {
        let halfHeight = bounds.height / 2

        let dark = TheseusSwitch()
        dark.isOn = true
        dark.onTintColor = onColor
        dark.offTintColor = offColor
        dark.frame = CGRect(x: 0, y: 0, width: 63, height: 28)
        dark.center = CGPoint(x: bounds.midX, y: halfHeight / 2)
        addSubview(dark)
        darkSwitch = dark

        let light = TheseusSwitch()
        light.isOn = true
        light.onTintColor = onColor
        light.offTintColor = offColor
        light.frame = CGRect(x: 0, y: 0, width: 63, height: 28)
        light.center = CGPoint(x: bounds.midX, y: halfHeight + halfHeight / 2)
        addSubview(light)
        lightSwitch = light
    }
}

struct SliderPreview: View {
    var body: some View {
        SliderDualContainerRepresentable()
            .frame(width: 400, height: 400)
    }
}

struct SliderDualContainerRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> SliderDualContainer {
        SliderDualContainer()
    }

    func updateUIView(_ uiView: SliderDualContainer, context: Context) {}
}

class SliderDualContainer: UIView {
    private let darkBackground = UIImageView()
    private let lightBackground = UIImageView()
    private var darkSlider: TheseusSlider?
    private var lightSlider: TheseusSlider?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        clipsToBounds = true
        addSubview(darkBackground)
        addSubview(lightBackground)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let halfHeight = bounds.height / 2
        darkBackground.frame = CGRect(x: 0, y: 0, width: bounds.width, height: halfHeight)
        lightBackground.frame = CGRect(x: 0, y: halfHeight, width: bounds.width, height: halfHeight)

        if darkSlider == nil && bounds.width > 0 {
            setupBackgrounds()
            setupSliders()
        }
    }

    private func setupBackgrounds() {
        darkBackground.image = renderGradient(isDark: true, size: darkBackground.bounds.size)
        lightBackground.image = renderGradient(isDark: false, size: lightBackground.bounds.size)
    }

    private func renderGradient(isDark: Bool, size: CGSize) -> UIImage {
        guard size.width > 0, size.height > 0 else { return UIImage() }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(origin: .zero, size: size)
            if isDark {
                gradientLayer.colors = [
                    UIColor(red: 0.15, green: 0.15, blue: 0.20, alpha: 1.0).cgColor,
                    UIColor(red: 0.20, green: 0.18, blue: 0.25, alpha: 1.0).cgColor,
                    UIColor(red: 0.18, green: 0.20, blue: 0.28, alpha: 1.0).cgColor
                ]
            } else {
                gradientLayer.colors = [
                    UIColor(red: 0.95, green: 0.85, blue: 0.82, alpha: 1.0).cgColor,
                    UIColor(red: 0.92, green: 0.80, blue: 0.85, alpha: 1.0).cgColor,
                    UIColor(red: 0.88, green: 0.78, blue: 0.82, alpha: 1.0).cgColor
                ]
            }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.render(in: ctx.cgContext)
        }
    }

    private func setupSliders() {
        let halfHeight = bounds.height / 2
        let sliderWidth: CGFloat = 300
        let sliderHeight: CGFloat = 44

        let dark = TheseusSlider()
        dark.minimumValue = 0
        dark.maximumValue = 100
        dark.setValue(50)
        dark.trackColor = .systemBlue
        dark.frame = CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight)
        dark.center = CGPoint(x: bounds.midX, y: halfHeight / 2)
        addSubview(dark)
        darkSlider = dark

        let light = TheseusSlider()
        light.minimumValue = 0
        light.maximumValue = 100
        light.setValue(50)
        light.trackColor = .systemBlue
        light.frame = CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight)
        light.center = CGPoint(x: bounds.midX, y: halfHeight + halfHeight / 2)
        addSubview(light)
        lightSlider = light
    }
}

struct TabBarPreview: View {
    @State private var selectedIndex = 0

    private let items = [
        TheseusTabBarItem(icon: UIImage(systemName: "doc.text.image"), title: "Today"),
        TheseusTabBarItem(icon: UIImage(systemName: "gamecontroller"), title: "Games"),
        TheseusTabBarItem(icon: UIImage(systemName: "square.stack.3d.up.fill"), title: "Apps"),
        TheseusTabBarItem(icon: UIImage(systemName: "dpad.fill"), title: "Arcade"),
        TheseusTabBarItem(icon: UIImage(systemName: "magnifyingglass"), title: "Search")
    ]

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                GradientBackground(isDarkMode: true)
                VStack {
                    Spacer()
                    TheseusTabBarRepresentable(
                        items: items,
                        selectedIndex: $selectedIndex,
                        selectedTintColor: .systemBlue,
                        unselectedTintColor: .white,
                        glassBlurRadius: 3.0,
                        glassRefractionFactor: 1.42
                    )
                    .frame(height: 60)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .frame(height: 200)

            ZStack {
                GradientBackground(isDarkMode: false)
                VStack {
                    Spacer()
                    TheseusTabBarRepresentable(
                        items: items,
                        selectedIndex: $selectedIndex,
                        selectedTintColor: .systemBlue,
                        unselectedTintColor: .black,
                        glassBlurRadius: 3.0,
                        glassRefractionFactor: 1.42
                    )
                    .frame(height: 60)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .frame(height: 200)
        }
        .frame(width: 400, height: 400)
    }
}

struct GlassViewPreview: View {
    var body: some View {
        GlassDemoContainerRepresentable(
            isDarkMode: false,
            blurRadius: 12.0,
            cornerRadius: 40.0,
            refractionFactor: 1.8,
            fresnelFactor: 1.4,
            glareAngle: 135.0,
            continuousUpdate: false
        )
        .frame(width: 400, height: 400)
    }
}

struct SettingsPreview: View {
    @State private var blurRadius: Float = 8.0
    @State private var refractionFactor: Float = 1.0
    @State private var cornerRadius: Float = 20.0
    @State private var animating = false

    var body: some View {
        HStack(spacing: 0) {
            SettingsLensContainerRepresentable(
                blurRadius: CGFloat(blurRadius),
                refractionFactor: CGFloat(refractionFactor),
                cornerRadius: CGFloat(cornerRadius)
            )
            .frame(width: 200)

            ZStack {
                Color(UIColor.systemGroupedBackground)

                VStack(spacing: 16) {
                    ParameterRow(label: "blur", value: blurRadius, range: 0...30)
                    ParameterRow(label: "refraction", value: refractionFactor, range: 0...3)
                    ParameterRow(label: "corner", value: cornerRadius, range: 0...50)
                }
                .padding()
            }
            .frame(width: 200)
        }
        .frame(width: 400, height: 400)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.5)) {
                blurRadius = Float.random(in: 5...25)
                refractionFactor = Float.random(in: 0.8...2.5)
                cornerRadius = Float.random(in: 10...45)
            }
        }
    }
}

private struct ParameterRow: View {
    let label: String
    let value: Float
    let range: ClosedRange<Float>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.secondary.opacity(0.2))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.blue)
                        .frame(width: geo.size.width * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)))
                }
            }
            .frame(height: 8)

            Text(String(format: "%.1f", value))
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
        }
        .frame(height: 60)
    }
}

struct SettingsLensContainerRepresentable: UIViewRepresentable {
    let blurRadius: CGFloat
    let refractionFactor: CGFloat
    let cornerRadius: CGFloat

    func makeUIView(context: Context) -> SettingsLensContainer {
        SettingsLensContainer()
    }

    func updateUIView(_ uiView: SettingsLensContainer, context: Context) {
        uiView.updateLens(
            blurRadius: blurRadius,
            refractionFactor: refractionFactor,
            cornerRadius: cornerRadius
        )
    }
}

class SettingsLensContainer: UIView {
    private let backgroundImageView = UIImageView()
    private var lens: TheseusView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        clipsToBounds = true
        backgroundImageView.contentMode = .scaleAspectFill
        addSubview(backgroundImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.frame = bounds

        if lens == nil && bounds.width > 0 {
            setupBackground()
            setupLens()
        }
    }

    private func setupBackground() {
        guard bounds.width > 0, bounds.height > 0 else { return }

        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { ctx in
            let colors = [
                UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0),
                UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0),
                UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0),
                UIColor(red: 0.8, green: 0.4, blue: 1.0, alpha: 1.0)
            ]

            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = colors.map { $0.cgColor }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.render(in: ctx.cgContext)

            ctx.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.3).cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(x: 20, y: 50, width: 80, height: 80))
            ctx.cgContext.fillEllipse(in: CGRect(x: 100, y: 250, width: 60, height: 60))
            ctx.cgContext.fill(CGRect(x: 30, y: 300, width: 50, height: 50))
        }
        backgroundImageView.image = image
    }

    private func setupLens() {
        let lensSize: CGFloat = 100

        var config = TheseusConfiguration()
        config.blur.radius = 8
        config.shape.cornerRadius = 20
        config.refraction.intensity = 1.0
        config.shape.padding = CGPoint(x: 10, y: 10)
        config.theme.tintColor = .clear
        config.edgeEffects.nearColor = .clear
        config.edgeEffects.farColor = .clear

        let glassLens = TheseusView(configuration: config)
        glassLens.sourceView = self
        glassLens.frame = CGRect(x: 0, y: 0, width: lensSize, height: lensSize)
        glassLens.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(glassLens)
        lens = glassLens

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        glassLens.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let lens = lens else { return }
        let translation = gesture.translation(in: self)
        lens.center = CGPoint(
            x: lens.center.x + translation.x,
            y: lens.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: self)
        lens.invalidateBackground()
    }

    func updateLens(blurRadius: CGFloat, refractionFactor: CGFloat, cornerRadius: CGFloat) {
        lens?.blur.radius = blurRadius
        lens?.refraction.intensity = refractionFactor
        lens?.shape.cornerRadius = cornerRadius
        lens?.invalidateBackground()
    }
}

struct FallbackPreview: View {
    @State private var currentMode = 0
    private let modes = ["Metal", "Approx", "Fallback"]
    private let tiers = ["Tier 3", "Tier 2", "Tier 1", "Tier 0"]
    @State private var currentTier = 0

    var body: some View {
        HStack(spacing: 0) {
            FallbackLensContainerRepresentable(
                useFallback: currentMode == 2,
                tier: currentTier
            )
            .frame(width: 200)

            ZStack {
                Color(UIColor.systemGroupedBackground)

                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Rendering")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(modes[currentMode])
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(currentMode == 2 ? .orange : .blue)
                    }

                    Divider()

                    VStack(spacing: 8) {
                        Text("Device")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(tiers[currentTier])
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }

                    Divider()

                    VStack(spacing: 8) {
                        Text("iOS")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("iOS \(13 + currentTier)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                }
                .padding()
            }
            .frame(width: 200)
        }
        .frame(width: 400, height: 400)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentMode = (currentMode + 1) % modes.count
                currentTier = (currentTier + 1) % tiers.count
            }
        }
    }
}

struct FallbackLensContainerRepresentable: UIViewRepresentable {
    let useFallback: Bool
    let tier: Int

    func makeUIView(context: Context) -> FallbackLensContainer {
        FallbackLensContainer()
    }

    func updateUIView(_ uiView: FallbackLensContainer, context: Context) {
        uiView.updateMode(useFallback: useFallback, tier: tier)
    }
}

class FallbackLensContainer: UIView {
    private let backgroundImageView = UIImageView()
    private var lens: TheseusView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        clipsToBounds = true
        backgroundImageView.contentMode = .scaleAspectFill
        addSubview(backgroundImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.frame = bounds

        if lens == nil && bounds.width > 0 {
            setupBackground()
            setupLens()
        }
    }

    private func setupBackground() {
        guard bounds.width > 0, bounds.height > 0 else { return }

        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { ctx in
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = [
                UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0).cgColor,
                UIColor(red: 0.8, green: 0.3, blue: 0.6, alpha: 1.0).cgColor,
                UIColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 1.0).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.render(in: ctx.cgContext)

            ctx.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.3).cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(x: 15, y: 40, width: 70, height: 70))
            ctx.cgContext.fillEllipse(in: CGRect(x: 90, y: 220, width: 50, height: 50))
            ctx.cgContext.fill(CGRect(x: 25, y: 280, width: 45, height: 45))
            ctx.cgContext.fillEllipse(in: CGRect(x: 120, y: 100, width: 40, height: 40))
        }
        backgroundImageView.image = image
    }

    private func setupLens() {
        let lensSize: CGFloat = 100

        var config = TheseusConfiguration()
        config.blur.radius = 12
        config.shape.cornerRadius = lensSize / 2
        config.refraction.intensity = 1.6
        config.shape.padding = CGPoint(x: 10, y: 10)
        config.theme.tintColor = .clear
        config.edgeEffects.nearColor = .clear
        config.edgeEffects.farColor = .clear

        let glassLens = TheseusView(configuration: config)
        glassLens.sourceView = self
        glassLens.frame = CGRect(x: 0, y: 0, width: lensSize, height: lensSize)
        glassLens.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(glassLens)
        lens = glassLens

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        glassLens.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let lens = lens else { return }
        let translation = gesture.translation(in: self)
        lens.center = CGPoint(
            x: lens.center.x + translation.x,
            y: lens.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: self)
        lens.invalidateBackground()
    }

    func updateMode(useFallback: Bool, tier: Int) {
        let settings = TheseusSettings.shared
        let tiers: [DeviceTier] = [.tier3, .tier2, .tier1, .tier0]
        settings.tierOverride = tiers[min(tier, 3)]

        if useFallback {
            settings.refractionPolicyOverride = .off
        } else {
            settings.refractionPolicyOverride = .trueRefraction
        }

        lens?.invalidateBackground()
    }
}

#Preview("Hero") {
    HeroPreview()
}

#Preview("Switch") {
    SwitchPreview()
}

#Preview("Slider") {
    SliderPreview()
}

#Preview("TabBar") {
    TabBarPreview()
}

#Preview("GlassView") {
    GlassViewPreview()
}

#Preview("Settings") {
    SettingsPreview()
}

#Preview("Fallback") {
    FallbackPreview()
}
