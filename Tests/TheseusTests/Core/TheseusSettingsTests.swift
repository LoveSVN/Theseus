import XCTest
@testable import Theseus

final class TheseusSettingsTests: XCTestCase {

    var settings: TheseusSettings!

    override func setUp() {
        super.setUp()
        settings = TheseusSettings.shared
        settings.resetToDefaults()
    }

    override func tearDown() {
        settings.resetToDefaults()
        super.tearDown()
    }

    // MARK: - Tier Override

    func testTierOverrideApplied() {
        settings.tierOverride = .tier0
        XCTAssertEqual(settings.effectiveTier, .tier0)

        settings.tierOverride = .tier3
        XCTAssertEqual(settings.effectiveTier, .tier3)

        settings.tierOverride = nil
        XCTAssertEqual(settings.effectiveTier, TheseusCapability.deviceTier)
    }

    // MARK: - iOS Version Override

    func testIOSVersionOverrideApplied() {
        settings.iosVersionOverride = 13
        XCTAssertEqual(settings.effectiveIOSVersion, 13)

        settings.iosVersionOverride = nil
        XCTAssertEqual(settings.effectiveIOSVersion, TheseusCapability.iosMajorVersion)
    }

    // MARK: - Refraction Policy Override

    func testRefractionPolicyOverrideApplied() {
        settings.refractionPolicyOverride = .off
        XCTAssertEqual(settings.effectiveRefractionPolicy, .off)

        settings.refractionPolicyOverride = .trueRefraction
        XCTAssertEqual(settings.effectiveRefractionPolicy, .trueRefraction)
    }

    // MARK: - Refraction Quality Override

    func testRefractionQualityOverrideApplied() {
        settings.refractionQualityOverride = .low
        XCTAssertEqual(settings.effectiveRefractionQuality, .low)

        settings.refractionQualityOverride = .high
        XCTAssertEqual(settings.effectiveRefractionQuality, .high)
    }

    // MARK: - Fallback Mode

    func testShouldUseFallback() {
        settings.forceFallback = true
        XCTAssertTrue(settings.shouldUseFallback)

        settings.forceFallback = false
        settings.tierOverride = .tier0
        XCTAssertTrue(settings.shouldUseFallback)

        settings.tierOverride = .tier3
        settings.refractionPolicyOverride = .off
        XCTAssertTrue(settings.shouldUseFallback)
    }

    // MARK: - Environment Simulation

    func testEnvironmentSimulation() {
        settings.simulateLowPowerMode = true
        XCTAssertTrue(settings.isLowPowerModeActive)
        XCTAssertTrue(settings.isConstrained)

        settings.simulateLowPowerMode = false
        settings.simulateReduceTransparency = true
        XCTAssertTrue(settings.isReduceTransparencyActive)

        settings.simulateReduceTransparency = false
        settings.simulateReduceMotion = true
        XCTAssertTrue(settings.isReduceMotionActive)
    }

    // MARK: - Policy Computation

    func testReduceTransparencyReturnsOffPolicy() {
        settings.simulateReduceTransparency = true
        settings.refractionPolicyOverride = nil
        XCTAssertEqual(settings.effectiveRefractionPolicy, .off)
    }

    func testConstrainedReturnsCheapApproxPolicy() {
        settings.simulateLowPowerMode = true
        settings.simulateReduceTransparency = false
        settings.refractionPolicyOverride = nil
        XCTAssertEqual(settings.effectiveRefractionPolicy, .cheapApprox)
    }

    func testTierBasedPolicySelection() {
        settings.simulateLowPowerMode = false
        settings.simulateReduceTransparency = false
        settings.refractionPolicyOverride = nil

        settings.tierOverride = .tier0
        XCTAssertEqual(settings.effectiveRefractionPolicy, .cheapApprox)

        settings.tierOverride = .tier3
        XCTAssertEqual(settings.effectiveRefractionPolicy, .trueRefraction)
    }

    func testTier1PolicyDependsOnIOSVersion() {
        settings.simulateLowPowerMode = false
        settings.simulateReduceTransparency = false
        settings.tierOverride = .tier1
        settings.refractionPolicyOverride = nil

        settings.iosVersionOverride = 17
        XCTAssertEqual(settings.effectiveRefractionPolicy, .trueRefraction)

        settings.iosVersionOverride = 16
        XCTAssertEqual(settings.effectiveRefractionPolicy, .cheapApprox)
    }

    func testTier2PolicyDependsOnIOSVersion() {
        settings.simulateLowPowerMode = false
        settings.simulateReduceTransparency = false
        settings.tierOverride = .tier2
        settings.refractionPolicyOverride = nil

        settings.iosVersionOverride = 15
        XCTAssertEqual(settings.effectiveRefractionPolicy, .trueRefraction)

        settings.iosVersionOverride = 14
        XCTAssertEqual(settings.effectiveRefractionPolicy, .cheapApprox)
    }

    // MARK: - Quality Computation

    func testQualityByTier() {
        settings.simulateLowPowerMode = false
        settings.refractionQualityOverride = nil

        settings.tierOverride = .tier0
        XCTAssertEqual(settings.effectiveRefractionQuality, .low)

        settings.tierOverride = .tier1
        XCTAssertEqual(settings.effectiveRefractionQuality, .low)

        settings.tierOverride = .tier2
        XCTAssertEqual(settings.effectiveRefractionQuality, .medium)
    }

    func testTier3QualityDependsOnIOSVersion() {
        settings.simulateLowPowerMode = false
        settings.tierOverride = .tier3
        settings.refractionQualityOverride = nil

        settings.iosVersionOverride = 17
        XCTAssertEqual(settings.effectiveRefractionQuality, .high)

        settings.iosVersionOverride = 16
        XCTAssertEqual(settings.effectiveRefractionQuality, .medium)
    }

    func testConstrainedReturnsLowQuality() {
        settings.simulateLowPowerMode = true
        settings.refractionQualityOverride = nil
        XCTAssertEqual(settings.effectiveRefractionQuality, .low)
    }

    // MARK: - Component-Specific Policy

    func testComponentPolicyWhenBasePolicyIsOff() {
        settings.refractionPolicyOverride = .off
        XCTAssertEqual(settings.effectivePolicy(for: .tabBar), .off)
        XCTAssertEqual(settings.effectivePolicy(for: .button), .off)
        XCTAssertEqual(settings.effectivePolicy(for: .slider), .off)
    }

    func testTier0AlwaysReturnsCheapApproxForComponents() {
        settings.tierOverride = .tier0
        settings.refractionPolicyOverride = .trueRefraction
        XCTAssertEqual(settings.effectivePolicy(for: .tabBar), .cheapApprox)
        XCTAssertEqual(settings.effectivePolicy(for: .button), .cheapApprox)
    }

    func testTier1OnlyTabBarGetsBasePolicy() {
        settings.tierOverride = .tier1
        settings.refractionPolicyOverride = .trueRefraction
        XCTAssertEqual(settings.effectivePolicy(for: .tabBar), .trueRefraction)
        XCTAssertEqual(settings.effectivePolicy(for: .button), .cheapApprox)
        XCTAssertEqual(settings.effectivePolicy(for: .slider), .cheapApprox)
    }

    func testTier2TabBarAndSwitchGetBasePolicy() {
        settings.tierOverride = .tier2
        settings.refractionPolicyOverride = .trueRefraction
        XCTAssertEqual(settings.effectivePolicy(for: .tabBar), .trueRefraction)
        XCTAssertEqual(settings.effectivePolicy(for: .switch), .trueRefraction)
        XCTAssertEqual(settings.effectivePolicy(for: .button), .cheapApprox)
    }

    func testTier3AllComponentsGetBasePolicy() {
        settings.tierOverride = .tier3
        settings.refractionPolicyOverride = .trueRefraction
        XCTAssertEqual(settings.effectivePolicy(for: .tabBar), .trueRefraction)
        XCTAssertEqual(settings.effectivePolicy(for: .switch), .trueRefraction)
        XCTAssertEqual(settings.effectivePolicy(for: .button), .trueRefraction)
        XCTAssertEqual(settings.effectivePolicy(for: .slider), .trueRefraction)
        XCTAssertEqual(settings.effectivePolicy(for: .glassView), .trueRefraction)
    }

    // MARK: - Reset

    func testResetToDefaultsClearsAllOverrides() {
        settings.tierOverride = .tier3
        settings.iosVersionOverride = 17
        settings.refractionPolicyOverride = .trueRefraction
        settings.refractionQualityOverride = .high
        settings.forceFallback = true
        settings.simulateLowPowerMode = true
        settings.simulateReduceTransparency = true
        settings.simulateReduceMotion = true

        settings.resetToDefaults()

        XCTAssertNil(settings.tierOverride)
        XCTAssertNil(settings.iosVersionOverride)
        XCTAssertNil(settings.refractionPolicyOverride)
        XCTAssertNil(settings.refractionQualityOverride)
        XCTAssertFalse(settings.forceFallback)
        XCTAssertNil(settings.simulateLowPowerMode)
        XCTAssertNil(settings.simulateReduceTransparency)
        XCTAssertNil(settings.simulateReduceMotion)
    }

    // MARK: - Notification

    func testSettingsChangePostsNotification() {
        let expectation = expectation(description: "Settings change notification")

        let observer = NotificationCenter.default.addObserver(
            forName: TheseusSettings.settingsDidChangeNotification,
            object: settings,
            queue: nil
        ) { _ in
            expectation.fulfill()
        }

        settings.tierOverride = .tier2

        waitForExpectations(timeout: 1.0)
        NotificationCenter.default.removeObserver(observer)
    }
}
