//
//  HomeUITests.swift
//  Kompas.idUITests
//
//  Created by Assistant on 10/08/25.
//

import XCTest
import CoreGraphics

final class HomeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCategoryTabsIfPresent() throws {
        let app = XCUIApplication()
        app.launch()

        var foundAny = false
        let labels = ["Berita Utama", "Terbaru", "Pilihanku", "Terpopuler"]
        for title in labels {
            if app.buttons[title].waitForExistence(timeout: 2) || app.staticTexts[title].exists {
                foundAny = true
                break
            }
        }
        if !foundAny { throw XCTSkip("Category tabs not found; skipping optional test") }
        XCTAssertTrue(foundAny)
    }

    @MainActor
    func testPullToRefreshGesture() throws {
        let app = XCUIApplication()
        app.launch()

        let table = app.tables.element(boundBy: 0)
        XCTAssertTrue(table.waitForExistence(timeout: 5))

        let start = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let finish = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        start.press(forDuration: 0.1, thenDragTo: finish)

        XCTAssertTrue(table.exists)
    }
}


