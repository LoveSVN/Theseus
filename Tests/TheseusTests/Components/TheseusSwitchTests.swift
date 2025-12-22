import XCTest
@testable import Theseus

final class TheseusSwitchTests: XCTestCase {

    // MARK: - State Management

    func testDefaultIsOnState() {
        let switchControl = TheseusSwitch()
        XCTAssertFalse(switchControl.isOn)
    }

    func testIsOnCanBeToggled() {
        let switchControl = TheseusSwitch()
        switchControl.isOn = true
        XCTAssertTrue(switchControl.isOn)
        switchControl.isOn = false
        XCTAssertFalse(switchControl.isOn)
    }

    func testSetOnAnimated() {
        let switchControl = TheseusSwitch()
        switchControl.setOn(true, animated: true)
        XCTAssertTrue(switchControl.isOn)
    }

    func testSettingSameValueIsNoOp() {
        let switchControl = TheseusSwitch()
        var changeCount = 0
        switchControl.onValueChanged = { _ in changeCount += 1 }
        switchControl.isOn = false
        XCTAssertEqual(changeCount, 0)
    }

    // MARK: - Colors

    func testColorConfiguration() {
        let switchControl = TheseusSwitch()
        switchControl.onTintColor = .blue
        switchControl.offTintColor = .red
        switchControl.thumbTintColor = .black

        XCTAssertEqual(switchControl.onTintColor, .blue)
        XCTAssertEqual(switchControl.offTintColor, .red)
        XCTAssertEqual(switchControl.thumbTintColor, .black)
    }

    // MARK: - Intrinsic Content Size

    func testIntrinsicContentSize() {
        let switchControl = TheseusSwitch()
        let size = switchControl.intrinsicContentSize
        XCTAssertEqual(size.width, 62.0)
        XCTAssertEqual(size.height, 30.0)
    }

    // MARK: - Callback Behavior

    func testValueChangedNotCalledOnProgrammaticChange() {
        let switchControl = TheseusSwitch()
        var callbackCalled = false
        switchControl.onValueChanged = { _ in callbackCalled = true }
        switchControl.isOn = true
        XCTAssertFalse(callbackCalled)
    }
}
