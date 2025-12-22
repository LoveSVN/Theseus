import XCTest
@testable import Theseus

final class TheseusSliderTests: XCTestCase {

    // MARK: - Default Values

    func testDefaultValues() {
        let slider = TheseusSlider()
        XCTAssertEqual(slider.minimumValue, 0.0)
        XCTAssertEqual(slider.maximumValue, 1.0)
        XCTAssertEqual(slider.value, 0.0)
    }

    // MARK: - Value Constraints

    func testValueClamping() {
        let slider = TheseusSlider()
        slider.minimumValue = 0
        slider.maximumValue = 100

        slider.setValue(-10)
        XCTAssertEqual(slider.value, 0)

        slider.setValue(150)
        XCTAssertEqual(slider.value, 100)

        slider.setValue(50)
        XCTAssertEqual(slider.value, 50)
    }

    func testLowerBoundEnforcement() {
        let slider = TheseusSlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.lowerBoundValue = 25

        slider.setValue(10)
        XCTAssertEqual(slider.value, 25)

        slider.setValue(50)
        XCTAssertEqual(slider.value, 50)
    }

    // MARK: - Increase/Decrease

    func testIncreaseDecrease() {
        let slider = TheseusSlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.setValue(50)

        slider.increase()
        XCTAssertEqual(slider.value, 51)

        slider.decrease()
        XCTAssertEqual(slider.value, 50)

        slider.increaseBy(10)
        XCTAssertEqual(slider.value, 60)

        slider.decreaseBy(20)
        XCTAssertEqual(slider.value, 40)
    }

    func testBoundaryBehavior() {
        let slider = TheseusSlider()
        slider.minimumValue = 0
        slider.maximumValue = 100

        slider.setValue(100)
        slider.increase()
        XCTAssertEqual(slider.value, 100)

        slider.setValue(0)
        slider.decrease()
        XCTAssertEqual(slider.value, 0)
    }

    // MARK: - Negative Values

    func testNegativeRange() {
        let slider = TheseusSlider()
        slider.minimumValue = -100
        slider.maximumValue = 100
        slider.setValue(-50)
        XCTAssertEqual(slider.value, -50)
    }

    // MARK: - Intrinsic Content Size

    func testIntrinsicContentSize() {
        let slider = TheseusSlider()
        XCTAssertEqual(slider.intrinsicContentSize.height, 44.0)
    }
}
