import XCTest
@testable import Theseus

final class TheseusConfigurationTests: XCTestCase {

    // MARK: - Default Values

    func testDefaultValues() {
        let config = TheseusConfiguration()
        XCTAssertEqual(config.blur.radius, 1.0)
        XCTAssertEqual(config.shape.cornerRadius, 18.0)
        XCTAssertEqual(config.opacity, 1.0)
        XCTAssertEqual(config.refraction.intensity, 1.45)
        XCTAssertEqual(config.refraction.edgeWidth, 15.0)
        XCTAssertEqual(config.edgeEffects.rimRange, 45.0)
        XCTAssertEqual(config.edgeEffects.glareRange, 450.0)
        XCTAssertEqual(config.morph.scale.x, 1.0)
        XCTAssertEqual(config.morph.scale.y, 1.0)
        XCTAssertEqual(config.morph.tension, 0.18)
        XCTAssertEqual(config.morph.friction, 0.88)
        XCTAssertEqual(config.captureMethod, .surfaceBased)
        XCTAssertNil(config.blur.sigma)
        XCTAssertNil(config.quality)
        XCTAssertNil(config.capturePadding)
    }

    // MARK: - Computed Properties

    func testEffectiveSigma() {
        var config = TheseusConfiguration()
        config.blur.radius = 9.0
        // effectiveSigma = radius * 0.3
        XCTAssertEqual(config.effectiveSigma, 9.0 * 0.3, accuracy: 0.0001)

        // Override takes precedence
        config.blur.sigma = 5.0
        XCTAssertEqual(config.effectiveSigma, 5.0)
    }

    func testEffectiveCapturePadding() {
        var config = TheseusConfiguration()
        config.blur.radius = 10.0
        config.shape.padding = CGPoint(x: 2, y: 3)
        // defaultPadding = blur.radius * 1.2 = 12.0
        // result = (12.0 + 2, 12.0 + 3) = (14, 15)
        var padding = config.effectiveCapturePadding
        XCTAssertEqual(padding.x, 14.0)
        XCTAssertEqual(padding.y, 15.0)

        // Override takes precedence
        config.capturePadding = CGPoint(x: 5, y: 6)
        // result = (5 + 2, 6 + 3) = (7, 9)
        padding = config.effectiveCapturePadding
        XCTAssertEqual(padding.x, 7.0)
        XCTAssertEqual(padding.y, 9.0)
    }

    // MARK: - Blur Radius Clamping by Quality

    func testEffectiveBlurRadiusClampedByQuality() {
        var config = TheseusConfiguration()
        config.blur.radius = 50.0

        // Low quality maxBlurRadius = 16
        XCTAssertEqual(config.effectiveBlurRadius(for: .low), 16)

        // Medium quality maxBlurRadius = 32
        XCTAssertEqual(config.effectiveBlurRadius(for: .medium), 32)

        // High quality maxBlurRadius = 64
        XCTAssertEqual(config.effectiveBlurRadius(for: .high), 50)

        // Ultra quality maxBlurRadius = 100
        config.blur.radius = 80.0
        XCTAssertEqual(config.effectiveBlurRadius(for: .ultra), 80)

        // Small value shouldn't be clamped
        config.blur.radius = 5.0
        XCTAssertEqual(config.effectiveBlurRadius(for: .low), 5)
    }
}
