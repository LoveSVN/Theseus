import UIKit
import Theseus

class ViewDemoViewController: UIViewController {

    private let backgroundImageView = UIImageView()
    private var theseusView: TheseusView!
    private var gestureHandler: TheseusGestureDeformer?

    // Default values (from patch.diff / TheseusConfiguration)
    private struct Defaults {
        static let blurRadius: Float = 10.0
        static let cornerRadius: Float = 16.0
        static let refractionFactor: Float = 1.42
        static let fresnelFactor: Float = 1.0
        static let glareAngle: Float = 45.0
        static let tintColorIndex = 0
        static let continuousUpdate = false

        static let tintColors: [UIColor] = [
            .clear,
            UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.3),
            UIColor(red: 0.9, green: 0.5, blue: 0.6, alpha: 0.3),
            UIColor(red: 0.9, green: 0.8, blue: 0.4, alpha: 0.3)
        ]
    }

    // Current settings
    private var currentBlurRadius = Defaults.blurRadius
    private var currentCornerRadius = Defaults.cornerRadius
    private var currentRefractionFactor = Defaults.refractionFactor
    private var currentFresnelFactor = Defaults.fresnelFactor
    private var currentGlareAngle = Defaults.glareAngle
    private var currentTintColorIndex = Defaults.tintColorIndex
    private var currentContinuousUpdate = Defaults.continuousUpdate

    private var isDarkMode: Bool {
        get { AppearanceManager.shared.isDarkMode }
        set { AppearanceManager.shared.isDarkMode = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupNavigationBar()
        setupTheseusView()
        applyDefaults()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAppearance()
    }

    private func setupBackground() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = view.bounds
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImageView)

        updateBackgroundGradient()
        addDecorations()
    }

    private func updateBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        if isDarkMode {
            gradientLayer.colors = [
                UIColor(red: 0.18, green: 0.15, blue: 0.22, alpha: 1.0).cgColor,
                UIColor(red: 0.20, green: 0.18, blue: 0.22, alpha: 1.0).cgColor,
                UIColor(red: 0.22, green: 0.20, blue: 0.18, alpha: 1.0).cgColor,
                UIColor(red: 0.22, green: 0.22, blue: 0.18, alpha: 1.0).cgColor
            ]
        } else {
            gradientLayer.colors = [
                UIColor(red: 0.88, green: 0.82, blue: 0.95, alpha: 1.0).cgColor,
                UIColor(red: 0.92, green: 0.80, blue: 0.88, alpha: 1.0).cgColor,
                UIColor(red: 0.95, green: 0.88, blue: 0.82, alpha: 1.0).cgColor,
                UIColor(red: 0.95, green: 0.92, blue: 0.82, alpha: 1.0).cgColor
            ]
        }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
        }
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        backgroundImageView.image = gradientImage
    }

    private func addDecorations() {
        let colors: [UIColor] = [.white, .systemTeal, .systemGreen]
        for i in 0..<5 {
            let circle = UIView()
            let size = CGFloat.random(in: 40...120)
            circle.frame = CGRect(
                x: CGFloat.random(in: 0...view.bounds.width - size),
                y: CGFloat.random(in: 100...view.bounds.height - 200),
                width: size,
                height: size
            )
            circle.backgroundColor = colors[i % colors.count].withAlphaComponent(0.3)
            circle.layer.cornerRadius = size / 2
            backgroundImageView.addSubview(circle)
        }
    }

    private func setupNavigationBar() {
        title = "Glass View"

        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(showSettings)
        )

        let darkModeButton = UIBarButtonItem(
            image: UIImage(systemName: "moon.fill"),
            style: .plain,
            target: self,
            action: #selector(toggleDarkMode)
        )

        navigationItem.rightBarButtonItems = [darkModeButton, settingsButton]
    }

    @objc private func toggleDarkMode() {
        isDarkMode.toggle()
        updateAppearance()
    }

    private func updateAppearance() {
        if let items = navigationItem.rightBarButtonItems, items.count > 0 {
            items[0].image = UIImage(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
        }

        updateBackgroundGradient()
    }

    @objc private func showSettings() {
        let settingsVC = GlassViewSettingsViewController(
            blurRadius: currentBlurRadius,
            cornerRadius: currentCornerRadius,
            refractionFactor: currentRefractionFactor,
            fresnelFactor: currentFresnelFactor,
            glareAngle: currentGlareAngle,
            tintColorIndex: currentTintColorIndex,
            continuousUpdate: currentContinuousUpdate
        )
        settingsVC.delegate = self

        let nav = UINavigationController(rootViewController: settingsVC)
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        }
        present(nav, animated: true)
    }

    private func applyDefaults() {
        currentBlurRadius = Defaults.blurRadius
        currentCornerRadius = Defaults.cornerRadius
        currentRefractionFactor = Defaults.refractionFactor
        currentFresnelFactor = Defaults.fresnelFactor
        currentGlareAngle = Defaults.glareAngle
        currentTintColorIndex = Defaults.tintColorIndex
        currentContinuousUpdate = Defaults.continuousUpdate

        applySettings()
    }

    private func applySettings() {
        theseusView.blur.radius = CGFloat(currentBlurRadius)
        theseusView.shape.cornerRadius = CGFloat(currentCornerRadius)
        theseusView.refraction.intensity = CGFloat(currentRefractionFactor)
        theseusView.edgeEffects.rimGlow = CGFloat(currentFresnelFactor)
        theseusView.edgeEffects.lightAngle = CGFloat(currentGlareAngle) * .pi / 180
        theseusView.theme.tintColor = Defaults.tintColors[currentTintColorIndex]
        theseusView.continuousUpdate = currentContinuousUpdate
    }

    private func setupTheseusView() {
        var config = TheseusConfiguration()
        config.blur.radius = CGFloat(Defaults.blurRadius)
        config.shape.cornerRadius = CGFloat(Defaults.cornerRadius)
        config.refraction.intensity = CGFloat(Defaults.refractionFactor)
        config.shape.padding = CGPoint(x: 15, y: 15)

        theseusView = TheseusView(configuration: config)
        theseusView.sourceView = backgroundImageView
        theseusView.frame = CGRect(x: 80, y: 200, width: 200, height: 150)
        view.addSubview(theseusView)

        gestureHandler = TheseusGestureDeformer(targetView: theseusView)
        gestureHandler?.positionProvider = { [weak self] translation, currentCenter, bounds in
            guard let self = self else { return nil }

            var newCenter = CGPoint(
                x: currentCenter.x + translation.x,
                y: currentCenter.y + translation.y
            )

            let glassSize = self.theseusView.bounds.size
            let minX = glassSize.width / 2
            let maxX = bounds.width - glassSize.width / 2
            let minY = glassSize.height / 2 + 100
            let maxY = bounds.height - glassSize.height / 2 - 50

            newCenter.x = max(minX, min(maxX, newCenter.x))
            newCenter.y = max(minY, min(maxY, newCenter.y))

            return newCenter
        }

        let instructionLabel = UILabel()
        instructionLabel.text = "Drag me!"
        instructionLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        instructionLabel.textColor = .label
        instructionLabel.textAlignment = .center
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        theseusView.addSubview(instructionLabel)

        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: theseusView.centerXAnchor),
            instructionLabel.centerYAnchor.constraint(equalTo: theseusView.centerYAnchor)
        ])
    }

}

// MARK: - Settings Delegate

extension ViewDemoViewController: GlassViewSettingsDelegate {
    func settingsDidChange(blurRadius: Float, cornerRadius: Float, refractionFactor: Float, fresnelFactor: Float, glareAngle: Float, tintColorIndex: Int, continuousUpdate: Bool) {
        currentBlurRadius = blurRadius
        currentCornerRadius = cornerRadius
        currentRefractionFactor = refractionFactor
        currentFresnelFactor = fresnelFactor
        currentGlareAngle = glareAngle
        currentTintColorIndex = tintColorIndex
        currentContinuousUpdate = continuousUpdate
        applySettings()
    }

    func settingsDidReset() {
        applyDefaults()
    }
}

// MARK: - Settings View Controller

protocol GlassViewSettingsDelegate: AnyObject {
    func settingsDidChange(blurRadius: Float, cornerRadius: Float, refractionFactor: Float, fresnelFactor: Float, glareAngle: Float, tintColorIndex: Int, continuousUpdate: Bool)
    func settingsDidReset()
}

class GlassViewSettingsViewController: UIViewController {

    weak var delegate: GlassViewSettingsDelegate?

    private let blurSlider = UISlider()
    private let blurValueLabel = UILabel()
    private let cornerRadiusSlider = UISlider()
    private let cornerRadiusValueLabel = UILabel()
    private let refractionSlider = UISlider()
    private let refractionValueLabel = UILabel()
    private let fresnelSlider = UISlider()
    private let fresnelValueLabel = UILabel()
    private let glareAngleSlider = UISlider()
    private let glareAngleValueLabel = UILabel()
    private let tintSegment = UISegmentedControl(items: ["None", "Blue", "Pink", "Gold"])
    private let continuousToggle = UISwitch()

    private var initialBlurRadius: Float
    private var initialCornerRadius: Float
    private var initialRefractionFactor: Float
    private var initialFresnelFactor: Float
    private var initialGlareAngle: Float
    private var initialTintColorIndex: Int
    private var initialContinuousUpdate: Bool

    init(blurRadius: Float, cornerRadius: Float, refractionFactor: Float, fresnelFactor: Float, glareAngle: Float, tintColorIndex: Int, continuousUpdate: Bool) {
        self.initialBlurRadius = blurRadius
        self.initialCornerRadius = cornerRadius
        self.initialRefractionFactor = refractionFactor
        self.initialFresnelFactor = fresnelFactor
        self.initialGlareAngle = glareAngle
        self.initialTintColorIndex = tintColorIndex
        self.initialContinuousUpdate = continuousUpdate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissSettings)
        )

        setupControls()
    }

    @objc private func dismissSettings() {
        dismiss(animated: true)
    }

    private func setupControls() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        // Blur Radius
        blurValueLabel.text = String(format: "%.0f", initialBlurRadius)
        blurSlider.minimumValue = 0
        blurSlider.maximumValue = 30
        blurSlider.value = initialBlurRadius
        blurSlider.addTarget(self, action: #selector(blurChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSliderRow(label: "Blur Radius", valueLabel: blurValueLabel, slider: blurSlider))

        // Corner Radius
        cornerRadiusValueLabel.text = String(format: "%.0f", initialCornerRadius)
        cornerRadiusSlider.minimumValue = 0
        cornerRadiusSlider.maximumValue = 75
        cornerRadiusSlider.value = initialCornerRadius
        cornerRadiusSlider.addTarget(self, action: #selector(cornerRadiusChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSliderRow(label: "Corner Radius", valueLabel: cornerRadiusValueLabel, slider: cornerRadiusSlider))

        // Refraction Factor
        refractionValueLabel.text = String(format: "%.2f", initialRefractionFactor)
        refractionSlider.minimumValue = 0
        refractionSlider.maximumValue = 2.5
        refractionSlider.value = initialRefractionFactor
        refractionSlider.addTarget(self, action: #selector(refractionChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSliderRow(label: "Refraction Factor", valueLabel: refractionValueLabel, slider: refractionSlider))

        // Fresnel Factor
        fresnelValueLabel.text = String(format: "%.1f", initialFresnelFactor)
        fresnelSlider.minimumValue = 0
        fresnelSlider.maximumValue = 2
        fresnelSlider.value = initialFresnelFactor
        fresnelSlider.addTarget(self, action: #selector(fresnelChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSliderRow(label: "Fresnel Factor", valueLabel: fresnelValueLabel, slider: fresnelSlider))

        // Glare Angle
        glareAngleValueLabel.text = String(format: "%.0f", initialGlareAngle)
        glareAngleSlider.minimumValue = 0
        glareAngleSlider.maximumValue = 360
        glareAngleSlider.value = initialGlareAngle
        glareAngleSlider.addTarget(self, action: #selector(glareAngleChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSliderRow(label: "Glare Angle", valueLabel: glareAngleValueLabel, slider: glareAngleSlider))

        // Tint Color
        let tintLabel = createLabel("Tint Color")
        tintSegment.selectedSegmentIndex = initialTintColorIndex
        tintSegment.addTarget(self, action: #selector(settingsChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSettingRow(label: tintLabel, control: tintSegment))

        // Continuous Update Toggle
        let continuousLabel = createLabel("Continuous Update")
        continuousToggle.isOn = initialContinuousUpdate
        continuousToggle.addTarget(self, action: #selector(settingsChanged), for: .valueChanged)

        let continuousRow = UIStackView(arrangedSubviews: [continuousLabel, continuousToggle])
        continuousRow.axis = .horizontal
        continuousRow.alignment = .center
        continuousRow.distribution = .equalSpacing
        contentStack.addArrangedSubview(continuousRow)

        // Reset Button
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset to Defaults", for: .normal)
        resetButton.setTitleColor(.systemRed, for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        resetButton.addTarget(self, action: #selector(resetToDefaults), for: .touchUpInside)
        contentStack.addArrangedSubview(resetButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func createLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        return label
    }

    private func createSettingRow(label: UILabel, control: UIView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [label, control])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func createSliderRow(label: String, valueLabel: UILabel, slider: UISlider) -> UIStackView {
        let titleLabel = createLabel(label)
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = .secondaryLabel

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [headerStack, slider])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    @objc private func blurChanged() {
        blurValueLabel.text = String(format: "%.0f", blurSlider.value)
        notifyDelegate()
    }

    @objc private func cornerRadiusChanged() {
        cornerRadiusValueLabel.text = String(format: "%.0f", cornerRadiusSlider.value)
        notifyDelegate()
    }

    @objc private func refractionChanged() {
        refractionValueLabel.text = String(format: "%.2f", refractionSlider.value)
        notifyDelegate()
    }

    @objc private func fresnelChanged() {
        fresnelValueLabel.text = String(format: "%.1f", fresnelSlider.value)
        notifyDelegate()
    }

    @objc private func glareAngleChanged() {
        glareAngleValueLabel.text = String(format: "%.0f", glareAngleSlider.value)
        notifyDelegate()
    }

    @objc private func settingsChanged() {
        notifyDelegate()
    }

    private func notifyDelegate() {
        delegate?.settingsDidChange(
            blurRadius: blurSlider.value,
            cornerRadius: cornerRadiusSlider.value,
            refractionFactor: refractionSlider.value,
            fresnelFactor: fresnelSlider.value,
            glareAngle: glareAngleSlider.value,
            tintColorIndex: tintSegment.selectedSegmentIndex,
            continuousUpdate: continuousToggle.isOn
        )
    }

    @objc private func resetToDefaults() {
        blurSlider.value = 10.0
        blurValueLabel.text = "10"
        cornerRadiusSlider.value = 16.0
        cornerRadiusValueLabel.text = "16"
        refractionSlider.value = 1.42
        refractionValueLabel.text = "1.42"
        fresnelSlider.value = 1.0
        fresnelValueLabel.text = "1.0"
        glareAngleSlider.value = 45.0
        glareAngleValueLabel.text = "45"
        tintSegment.selectedSegmentIndex = 0
        continuousToggle.isOn = false

        delegate?.settingsDidReset()
    }
}
