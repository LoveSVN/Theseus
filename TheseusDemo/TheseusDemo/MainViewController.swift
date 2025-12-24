import UIKit
import Theseus

class MainViewController: UITableViewController {

    private let demos: [(title: String, subtitle: String, viewController: () -> UIViewController)] = [
        ("Tab Bar", "Native UITabBar vs TheseusTabBar", { TabBarDemoViewController() }),
        ("Switch", "Native UISwitch vs TheseusSwitch", { SwitchDemoViewController() }),
        ("Slider", "Native UISlider vs TheseusSlider", { SliderDemoViewController() }),
        ("Glass View", "Draggable TheseusView with morphing", { ViewDemoViewController() })
    ]

    private let tierLabel = UILabel()
    private let iosLabel = UILabel()
    private let qualityLabel = UILabel()
    private let policyLabel = UILabel()
    private let environmentLabel = UILabel()

    private lazy var headerView: UIView = {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground

        tierLabel.font = .systemFont(ofSize: 14, weight: .medium)
        tierLabel.textColor = .label
        tierLabel.translatesAutoresizingMaskIntoConstraints = false

        iosLabel.font = .systemFont(ofSize: 12, weight: .regular)
        iosLabel.textColor = .secondaryLabel
        iosLabel.translatesAutoresizingMaskIntoConstraints = false

        qualityLabel.font = .systemFont(ofSize: 12, weight: .regular)
        qualityLabel.textColor = .secondaryLabel
        qualityLabel.translatesAutoresizingMaskIntoConstraints = false

        policyLabel.font = .systemFont(ofSize: 12, weight: .regular)
        policyLabel.textColor = .secondaryLabel
        policyLabel.translatesAutoresizingMaskIntoConstraints = false

        environmentLabel.font = .systemFont(ofSize: 12, weight: .regular)
        environmentLabel.textColor = .secondaryLabel
        environmentLabel.numberOfLines = 0
        environmentLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [tierLabel, iosLabel, qualityLabel, policyLabel, environmentLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])

        return container
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Theseus Demo"
        navigationController?.navigationBar.prefersLargeTitles = true

        // Add settings button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(showSettings)
        )

        // Add header with device info
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 130)
        tableView.tableHeaderView = headerView

        updateHeaderLabels()

        // Observe environment and settings changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshDisplay),
            name: TheseusEnvironment.stateDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshDisplay),
            name: TheseusSettings.settingsDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func showSettings() {
        let settingsVC = SettingsViewController(style: .insetGrouped)
        let nav = UINavigationController(rootViewController: settingsVC)
        present(nav, animated: true)
    }

    @objc private func refreshDisplay() {
        updateHeaderLabels()
    }

    private func updateHeaderLabels() {
        let settings = TheseusSettings.shared

        // Show effective tier (with override indicator)
        let effectiveTier = settings.effectiveTier
        let tierOverridden = settings.tierOverride != nil
        tierLabel.text = "Tier: \(effectiveTier.description)\(tierOverridden ? " (Override)" : "")"

        // Show iOS version (with override indicator)
        let effectiveIOS = settings.effectiveIOSVersion
        let iosOverridden = settings.iosVersionOverride != nil
        iosLabel.text = "iOS \(iosOverridden ? "\(effectiveIOS) (Simulated)" : TheseusCapability.iosVersionString) | Metal: \(TheseusCapability.isMetalAvailable ? "Yes" : "No")"

        // Show effective policy and quality
        let policy = settings.effectiveRefractionPolicy
        let quality = settings.effectiveRefractionQuality
        qualityLabel.text = "Policy: \(policy.description) @ \(quality.description)"

        // Show environment state
        var envFlags: [String] = []
        if settings.isLowPowerModeActive {
            envFlags.append(settings.simulateLowPowerMode != nil ? "LowPower(Sim)" : "LowPower")
        }
        if settings.isReduceTransparencyActive {
            envFlags.append(settings.simulateReduceTransparency != nil ? "ReduceTransparency(Sim)" : "ReduceTransparency")
        }
        if settings.isReduceMotionActive {
            envFlags.append(settings.simulateReduceMotion != nil ? "ReduceMotion(Sim)" : "ReduceMotion")
        }
        policyLabel.text = "Env: \(envFlags.isEmpty ? "Normal" : envFlags.joined(separator: ", "))"

        // Show active quality
        environmentLabel.text = "Quality: \(quality.description)"
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "DemoCell")
        let demo = demos[indexPath.row]

        cell.textLabel?.text = demo.title
        cell.detailTextLabel?.text = demo.subtitle
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let demo = demos[indexPath.row]
        let viewController = demo.viewController()
        viewController.title = demo.title
        navigationController?.pushViewController(viewController, animated: true)
    }
}
