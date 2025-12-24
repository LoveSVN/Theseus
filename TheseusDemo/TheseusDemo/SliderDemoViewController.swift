import UIKit
import Theseus

class SliderDemoViewController: UIViewController {

    private let nativeSlider = UISlider()
    private let theseusSlider = TheseusSlider()
    private let valueLabel = UILabel()
    private let gradientLayer = CAGradientLayer()

    private struct Defaults {
        static let trackColorIndex = 0
        static let backColorIndex = 0
        static let knobColorIndex = 0
        static let trackThickness: Float = 6.0
        static let discreteEnabled = false

        static let trackColors: [UIColor] = [
            UIColor(white: 0.4, alpha: 1.0),
            .systemBlue,
            .systemPurple,
            .systemGreen
        ]
        static let backColors: [UIColor] = [
            UIColor(white: 0.8, alpha: 1.0),
            UIColor(white: 0.5, alpha: 1.0),
            UIColor(red: 0.9, green: 0.85, blue: 0.78, alpha: 1.0),
            UIColor(red: 0.78, green: 0.85, blue: 0.9, alpha: 1.0)
        ]
        static let knobColors: [UIColor] = [
            .white,
            UIColor(white: 0.15, alpha: 1.0),
            UIColor(red: 1.0, green: 0.98, blue: 0.94, alpha: 1.0),
            UIColor(red: 0.85, green: 0.9, blue: 1.0, alpha: 1.0)
        ]
    }

    // Current settings
    private var currentTrackColorIndex = Defaults.trackColorIndex
    private var currentBackColorIndex = Defaults.backColorIndex
    private var currentKnobColorIndex = Defaults.knobColorIndex
    private var currentTrackThickness = Defaults.trackThickness
    private var currentDiscreteEnabled = Defaults.discreteEnabled

    private var isDarkMode: Bool {
        get { AppearanceManager.shared.isDarkMode }
        set { AppearanceManager.shared.isDarkMode = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientBackground()
        setupNavigationBar()
        setupSliders()
        applyDefaults()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAppearance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func setupGradientBackground() {
        updateGradientColors()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func updateGradientColors() {
        if isDarkMode {
            gradientLayer.colors = [
                UIColor(red: 0.12, green: 0.18, blue: 0.20, alpha: 1.0).cgColor,
                UIColor(red: 0.15, green: 0.20, blue: 0.25, alpha: 1.0).cgColor,
                UIColor(red: 0.18, green: 0.22, blue: 0.28, alpha: 1.0).cgColor
            ]
        } else {
            gradientLayer.colors = [
                UIColor(red: 0.82, green: 0.92, blue: 0.88, alpha: 1.0).cgColor,
                UIColor(red: 0.78, green: 0.90, blue: 0.92, alpha: 1.0).cgColor,
                UIColor(red: 0.80, green: 0.85, blue: 0.95, alpha: 1.0).cgColor
            ]
        }
    }

    private func setupNavigationBar() {
        title = "Slider"

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

        updateGradientColors()
    }

    @objc private func showSettings() {
        let settingsVC = SliderSettingsViewController(
            trackColorIndex: currentTrackColorIndex,
            backColorIndex: currentBackColorIndex,
            knobColorIndex: currentKnobColorIndex,
            trackThickness: currentTrackThickness,
            discreteEnabled: currentDiscreteEnabled
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
        currentTrackColorIndex = Defaults.trackColorIndex
        currentBackColorIndex = Defaults.backColorIndex
        currentKnobColorIndex = Defaults.knobColorIndex
        currentTrackThickness = Defaults.trackThickness
        currentDiscreteEnabled = Defaults.discreteEnabled

        applySettings()
    }

    private func applySettings() {
        theseusSlider.trackColor = Defaults.trackColors[currentTrackColorIndex]
        theseusSlider.backColor = Defaults.backColors[currentBackColorIndex]
        theseusSlider.knobColor = Defaults.knobColors[currentKnobColorIndex]
        theseusSlider.lineSize = CGFloat(currentTrackThickness)
        theseusSlider.trackCornerRadius = CGFloat(currentTrackThickness) / 2

        nativeSlider.minimumTrackTintColor = Defaults.trackColors[currentTrackColorIndex]
        nativeSlider.maximumTrackTintColor = Defaults.backColors[currentBackColorIndex]

        if currentDiscreteEnabled {
            theseusSlider.positionsCount = 5
            theseusSlider.markPositions = true
        } else {
            theseusSlider.positionsCount = 0
            theseusSlider.markPositions = false
        }
    }

    private func setupSliders() {
        // Value label
        valueLabel.text = "Value: 50"
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        // Native Slider
        let nativeLabel = UILabel()
        nativeLabel.text = "Native UISlider"
        nativeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nativeLabel.textColor = .label

        nativeSlider.minimumValue = 0
        nativeSlider.maximumValue = 100
        nativeSlider.value = 50
        nativeSlider.addTarget(self, action: #selector(nativeSliderChanged), for: .valueChanged)

        let nativeStack = UIStackView(arrangedSubviews: [nativeLabel, nativeSlider])
        nativeStack.axis = .vertical
        nativeStack.spacing = 8

        // Liquid Glass Slider
        let liquidLabel = UILabel()
        liquidLabel.text = "TheseusSlider"
        liquidLabel.font = .systemFont(ofSize: 14, weight: .medium)
        liquidLabel.textColor = .label

        theseusSlider.minimumValue = 0
        theseusSlider.maximumValue = 100
        theseusSlider.setValue(50)
        theseusSlider.addTarget(self, action: #selector(liquidSliderChanged), for: .valueChanged)
        theseusSlider.translatesAutoresizingMaskIntoConstraints = false

        let liquidStack = UIStackView(arrangedSubviews: [liquidLabel, theseusSlider])
        liquidStack.axis = .vertical
        liquidStack.spacing = 8

        // Main stack
        let mainStack = UIStackView(arrangedSubviews: [valueLabel, nativeStack, liquidStack])
        mainStack.axis = .vertical
        mainStack.spacing = 30
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            theseusSlider.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func nativeSliderChanged() {
        let value = CGFloat(nativeSlider.value)
        theseusSlider.setValue(value)
        updateValueLabel(value)
    }

    @objc private func liquidSliderChanged() {
        let value = theseusSlider.value
        nativeSlider.value = Float(value)
        updateValueLabel(value)
    }

    private func updateValueLabel(_ value: CGFloat) {
        valueLabel.text = "Value: \(Int(value))"
    }
}

// MARK: - Settings Delegate

extension SliderDemoViewController: SliderSettingsDelegate {
    func settingsDidChange(trackColorIndex: Int, backColorIndex: Int, knobColorIndex: Int, trackThickness: Float, discreteEnabled: Bool) {
        currentTrackColorIndex = trackColorIndex
        currentBackColorIndex = backColorIndex
        currentKnobColorIndex = knobColorIndex
        currentTrackThickness = trackThickness
        currentDiscreteEnabled = discreteEnabled
        applySettings()
    }

    func settingsDidReset() {
        applyDefaults()
    }
}

// MARK: - Settings View Controller

protocol SliderSettingsDelegate: AnyObject {
    func settingsDidChange(trackColorIndex: Int, backColorIndex: Int, knobColorIndex: Int, trackThickness: Float, discreteEnabled: Bool)
    func settingsDidReset()
}

class SliderSettingsViewController: UIViewController {

    weak var delegate: SliderSettingsDelegate?

    private let trackColorSegment = UISegmentedControl(items: ["Gray", "Blue", "Purple", "Green"])
    private let backColorSegment = UISegmentedControl(items: ["Light", "Dark", "Warm", "Cool"])
    private let knobColorSegment = UISegmentedControl(items: ["White", "Black", "Cream", "Tinted"])
    private let trackThicknessSlider = UISlider()
    private let trackThicknessLabel = UILabel()
    private let discreteToggle = UISwitch()

    private var initialTrackColorIndex: Int
    private var initialBackColorIndex: Int
    private var initialKnobColorIndex: Int
    private var initialTrackThickness: Float
    private var initialDiscreteEnabled: Bool

    init(trackColorIndex: Int, backColorIndex: Int, knobColorIndex: Int, trackThickness: Float, discreteEnabled: Bool) {
        self.initialTrackColorIndex = trackColorIndex
        self.initialBackColorIndex = backColorIndex
        self.initialKnobColorIndex = knobColorIndex
        self.initialTrackThickness = trackThickness
        self.initialDiscreteEnabled = discreteEnabled
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
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        // Track Color
        let trackLabel = createLabel("Track Color")
        trackColorSegment.selectedSegmentIndex = initialTrackColorIndex
        trackColorSegment.addTarget(self, action: #selector(settingsChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSettingRow(label: trackLabel, control: trackColorSegment))

        // Back Color
        let backLabel = createLabel("Background Color")
        backColorSegment.selectedSegmentIndex = initialBackColorIndex
        backColorSegment.addTarget(self, action: #selector(settingsChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSettingRow(label: backLabel, control: backColorSegment))

        // Knob Color
        let knobLabel = createLabel("Knob Color")
        knobColorSegment.selectedSegmentIndex = initialKnobColorIndex
        knobColorSegment.addTarget(self, action: #selector(settingsChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSettingRow(label: knobLabel, control: knobColorSegment))

        // Track Thickness
        let thicknessLabel = createLabel("Track Thickness")
        trackThicknessLabel.text = String(format: "%.0f", initialTrackThickness)
        trackThicknessLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        trackThicknessLabel.textColor = .secondaryLabel
        trackThicknessSlider.minimumValue = 2
        trackThicknessSlider.maximumValue = 12
        trackThicknessSlider.value = initialTrackThickness
        trackThicknessSlider.addTarget(self, action: #selector(thicknessChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSliderRow(label: thicknessLabel, valueLabel: trackThicknessLabel, slider: trackThicknessSlider))

        // Discrete Toggle
        let discreteLabel = createLabel("Discrete (5 steps)")
        discreteToggle.isOn = initialDiscreteEnabled
        discreteToggle.addTarget(self, action: #selector(settingsChanged), for: .valueChanged)

        let discreteRow = UIStackView(arrangedSubviews: [discreteLabel, discreteToggle])
        discreteRow.axis = .horizontal
        discreteRow.alignment = .center
        discreteRow.distribution = .equalSpacing
        contentStack.addArrangedSubview(discreteRow)

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

    private func createSliderRow(label: UILabel, valueLabel: UILabel, slider: UISlider) -> UIStackView {
        let headerStack = UIStackView(arrangedSubviews: [label, valueLabel])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [headerStack, slider])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    @objc private func settingsChanged() {
        notifyDelegate()
    }

    @objc private func thicknessChanged() {
        trackThicknessLabel.text = String(format: "%.0f", trackThicknessSlider.value)
        notifyDelegate()
    }

    private func notifyDelegate() {
        delegate?.settingsDidChange(
            trackColorIndex: trackColorSegment.selectedSegmentIndex,
            backColorIndex: backColorSegment.selectedSegmentIndex,
            knobColorIndex: knobColorSegment.selectedSegmentIndex,
            trackThickness: trackThicknessSlider.value,
            discreteEnabled: discreteToggle.isOn
        )
    }

    @objc private func resetToDefaults() {
        trackColorSegment.selectedSegmentIndex = 0
        backColorSegment.selectedSegmentIndex = 0
        knobColorSegment.selectedSegmentIndex = 0
        trackThicknessSlider.value = 6.0
        trackThicknessLabel.text = "6"
        discreteToggle.isOn = false
        delegate?.settingsDidReset()
    }
}
