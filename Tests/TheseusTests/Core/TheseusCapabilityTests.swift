import XCTest
@testable import Theseus

final class TheseusCapabilityTests: XCTestCase {

    // MARK: - Device Tier

    func testDeviceTierComparison() {
        XCTAssertTrue(DeviceTier.tier0 < DeviceTier.tier1)
        XCTAssertTrue(DeviceTier.tier1 < DeviceTier.tier2)
        XCTAssertTrue(DeviceTier.tier2 < DeviceTier.tier3)
        XCTAssertFalse(DeviceTier.tier3 < DeviceTier.tier0)
    }

    // MARK: - Refraction Quality

    func testRefractionQualityFrameRates() {
        XCTAssertEqual(RefractionQuality.low.frameRate, 15)
        XCTAssertEqual(RefractionQuality.medium.frameRate, 30)
        XCTAssertEqual(RefractionQuality.high.frameRate, 60)
    }

    func testRefractionQualityRenderScales() {
        XCTAssertEqual(RefractionQuality.low.renderScale, 0.25)
        XCTAssertEqual(RefractionQuality.medium.renderScale, 0.5)
        XCTAssertEqual(RefractionQuality.high.renderScale, 1.0)
    }

    // MARK: - Quality Level

    func testQualityLevelMaxBlurRadius() {
        XCTAssertEqual(QualityLevel.low.maxBlurRadius, 16)
        XCTAssertEqual(QualityLevel.medium.maxBlurRadius, 32)
        XCTAssertEqual(QualityLevel.high.maxBlurRadius, 64)
        XCTAssertEqual(QualityLevel.ultra.maxBlurRadius, 100)
    }

    func testQualityLevelRenderScale() {
        XCTAssertEqual(QualityLevel.low.renderScale, 0.5)
        XCTAssertEqual(QualityLevel.medium.renderScale, 0.75)
        XCTAssertEqual(QualityLevel.high.renderScale, 1.0)
        XCTAssertEqual(QualityLevel.ultra.renderScale, 1.0)
    }

    // MARK: - Device Info

    func testPhysicalMemoryGBIsPositive() {
        XCTAssertGreaterThan(TheseusCapability.physicalMemoryGB, 0)
    }

    func testProcessorCountIsPositive() {
        XCTAssertGreaterThan(TheseusCapability.processorCount, 0)
    }

    // MARK: - iOS Version

    func testIOSMajorVersionInRange() {
        let version = TheseusCapability.iosMajorVersion
        XCTAssertGreaterThanOrEqual(version, 13)
    }
}
