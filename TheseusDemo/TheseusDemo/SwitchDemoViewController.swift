import UIKit
import Theseus

class SwitchDemoViewController: UIViewController {

    private let nativeSwitch = UISwitch()
    private let theseusSwitch = TheseusSwitch()
    private let gradientLayer = CAGradientLayer()

    private struct Defaults {
        static let onColorIndex = 0
        static let offColorIndex = 0
        static let thumbColorIndex = 0
        static let onColors: [UIColor] = [
            UIColor(red: 0.259, green: 0.831, blue: 0.318, alpha: 1.0), // Green (0x42d451)
            .systemBlue,
            .systemPurple,
            .systemOrange
        ]
        static let offColors: [UIColor] = [
            UIColor(white: 0.878, alpha: 1.0), // Light gray (0xe0e0e0)
            UIColor(red: 1.0, green: 0.8, blue: 0.8, alpha: 1.0),
            UIColor(red: 1.0, green: 0.85, blue: 0.9, alpha: 1.0),
            UIColor(red: 0.85, green: 0.78, blue: 0.72, alpha: 1.0)
        ]
        static let thumbColors: [UIColor] = [
            .white,
            UIColor(white: 0.15, alpha: 1.0),
            UIColor(red: 1.0, green: 0.98, blue: 0.94, alpha: 1.0),
            UIColor(red: 0.85, green: 0.85, blue: 0.87, alpha: 1.0)
        ]
    }

    // Current settings
    private var currentOnColorIndex = Defaults.onColorIndex
    private var currentOffColorIndex = Defaults.offColorIndex
    private var currentThumbColorIndex = Defaults.thumbColorIndex

    private var isDarkMode: Bool {
        get { AppearanceManager.shared.isDarkMode }
        set { AppearanceManager.shared.isDarkMode = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientBackground()
        setupNavigationBar()
        setupSwitches()
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
    }

    private func setupNavigationBar() {
        title = "Switch"

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
        let settingsVC = SwitchSettingsViewController(
            onColorIndex: currentOnColorIndex,
            offColorIndex: currentOffColorIndex,
            thumbColorIndex: currentThumbColorIndex
        )
        settingsVC.delegate = self

        let nav = UINavigationController(rootViewController: settingsVC)
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        }
        present(nav, animated: true)
    }

    private func applyDefaults() {
        currentOnColorIndex = Defaults.onColorIndex
        currentOffColorIndex = Defaults.offColorIndex
        currentThumbColorIndex = Defaults.thumbColorIndex

        applyColors()
    }

    private func applyColors() {
        theseusSwitch.onTintColor = Defaults.onColors[currentOnColorIndex]
        theseusSwitch.offTintColor = Defaults.offColors[currentOffColorIndex]
        theseusSwitch.thumbTintColor = Defaults.thumbColors[currentThumbColorIndex]
        nativeSwitch.onTintColor = Defaults.onColors[currentOnColorIndex]
    }

    private func setupSwitches() {
        // Native Switch
        let nativeStack = createSwitchStack(
            label: "Native UISwitch",
            switchView: nativeSwitch
        )
        nativeSwitch.addTarget(self, action: #selector(nativeSwitchChanged), for: .valueChanged)

        // Liquid Glass Switch
        let liquidStack = createSwitchStack(
            label: "TheseusSwitch",
            switchView: theseusSwitch
        )
        theseusSwitch.onValueChanged = { [weak self] isOn in
            self?.nativeSwitch.setOn(isOn, animated: true)
        }

        let mainStack = UIStackView(arrangedSubviews: [nativeStack, liquidStack])
        mainStack.axis = .vertical
        mainStack.spacing = 50
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.widthAnchor.constraint(equalToConstant: 280)
        ])
    }

    private func createSwitchStack(label: String, switchView: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 16, weight: .medium)
        labelView.textColor = .label

        let stack = UIStackView(arrangedSubviews: [labelView, switchView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing

        return stack
    }

    @objc private func nativeSwitchChanged() {
        theseusSwitch.setOn(nativeSwitch.isOn, animated: true)
    }
}

// MARK: - Settings Delegate

extension SwitchDemoViewController: SwitchSettingsDelegate {
    func settingsDidChange(onColorIndex: Int, offColorIndex: Int, thumbColorIndex: Int) {
        currentOnColorIndex = onColorIndex
        currentOffColorIndex = offColorIndex
        currentThumbColorIndex = thumbColorIndex
        applyColors()
    }

    func settingsDidReset() {
        applyDefaults()
    }
}

// MARK: - Settings View Controller

protocol SwitchSettingsDelegate: AnyObject {
    func settingsDidChange(onColorIndex: Int, offColorIndex: Int, thumbColorIndex: Int)
    func settingsDidReset()
}

class SwitchSettingsViewController: UIViewController {

    weak var delegate: SwitchSettingsDelegate?

    private let onColorSegment = UISegmentedControl(items: ["Green", "Blue", "Purple", "Orange"])
    private let offColorSegment = UISegmentedControl(items: ["Gray", "Red", "Pink", "Brown"])
    private let thumbColorSegment = UISegmentedControl(items: ["White", "Black", "Cream", "Silver"])

    private var initialOnColorIndex: Int
    private var initialOffColorIndex: Int
    private var initialThumbColorIndex: Int

    init(onColorIndex: Int, offColorIndex: Int, thumbColorIndex: Int) {
        self.initialOnColorIndex = onColorIndex
        self.initialOffColorIndex = offColorIndex
        self.initialThumbColorIndex = thumbColorIndex
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

        // On Color
        let onLabel = createLabel("On Color")
        onColorSegment.selectedSegmentIndex = initialOnColorIndex
        onColorSegment.addTarget(self, action: #selector(settingsChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSettingRow(label: onLabel, control: onColorSegment))

        // Off Color
        let offLabel = createLabel("Off Color")
        offColorSegment.selectedSegmentIndex = initialOffColorIndex
        offColorSegment.addTarget(self, action: #selector(settingsChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSettingRow(label: offLabel, control: offColorSegment))

        // Thumb Color
        let thumbLabel = createLabel("Thumb Color")
        thumbColorSegment.selectedSegmentIndex = initialThumbColorIndex
        thumbColorSegment.addTarget(self, action: #selector(settingsChanged), for: .valueChanged)
        contentStack.addArrangedSubview(createSettingRow(label: thumbLabel, control: thumbColorSegment))

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

    @objc private func settingsChanged() {
        delegate?.settingsDidChange(
            onColorIndex: onColorSegment.selectedSegmentIndex,
            offColorIndex: offColorSegment.selectedSegmentIndex,
            thumbColorIndex: thumbColorSegment.selectedSegmentIndex
        )
    }

    @objc private func resetToDefaults() {
        onColorSegment.selectedSegmentIndex = 0
        offColorSegment.selectedSegmentIndex = 0
        thumbColorSegment.selectedSegmentIndex = 0
        delegate?.settingsDidReset()
    }
}
