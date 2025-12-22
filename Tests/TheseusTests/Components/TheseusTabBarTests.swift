import XCTest
@testable import Theseus

final class TheseusTabBarTests: XCTestCase {

    // MARK: - Default State

    func testDefaultState() {
        let tabBar = TheseusTabBar()
        XCTAssertTrue(tabBar.items.isEmpty)
        XCTAssertEqual(tabBar.selectedIndex, 0)
    }

    // MARK: - Items Management

    func testItemsManagement() {
        let tabBar = TheseusTabBar()
        tabBar.items = [
            TheseusTabBarItem(icon: UIImage(systemName: "house"), title: "Home"),
            TheseusTabBarItem(icon: UIImage(systemName: "gear"), title: "Settings")
        ]
        XCTAssertEqual(tabBar.items.count, 2)

        tabBar.items = []
        XCTAssertTrue(tabBar.items.isEmpty)
    }

    // MARK: - Selection

    func testSelectionIndex() {
        let tabBar = TheseusTabBar()
        tabBar.items = [
            TheseusTabBarItem(icon: nil, title: "One"),
            TheseusTabBarItem(icon: nil, title: "Two"),
            TheseusTabBarItem(icon: nil, title: "Three")
        ]

        tabBar.selectedIndex = 2
        XCTAssertEqual(tabBar.selectedIndex, 2)

        tabBar.selectedIndex = 0
        XCTAssertEqual(tabBar.selectedIndex, 0)
    }

    // MARK: - Glass Properties

    func testGlassProperties() {
        let tabBar = TheseusTabBar()

        tabBar.glassBlurRadius = 10.0
        XCTAssertEqual(tabBar.glassBlurRadius, 10.0)

        tabBar.glassRefractionFactor = 2.0
        XCTAssertEqual(tabBar.glassRefractionFactor, 2.0)
    }

    // MARK: - Colors

    func testColorConfiguration() {
        let tabBar = TheseusTabBar()

        tabBar.selectedTintColor = .red
        XCTAssertEqual(tabBar.selectedTintColor, .red)

        tabBar.unselectedTintColor = .gray
        XCTAssertEqual(tabBar.unselectedTintColor, .gray)
    }

    // MARK: - Tab Bar Item

    func testTabBarItemInit() {
        let item = TheseusTabBarItem(icon: UIImage(systemName: "star"), title: "Favorites")
        XCTAssertEqual(item.title, "Favorites")
        XCTAssertNotNil(item.icon)

        let textOnlyItem = TheseusTabBarItem(icon: nil, title: "Text Only")
        XCTAssertNil(textOnlyItem.icon)
    }
}
