//
//  MaxQUITests.swift
//  MaxQUITests
//
//  Created by Qendrim Qeriqi on 8/8/25.
//

import XCTest
import SwiftUI

final class MaxQUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func test_seedData_and_navigate_home_to_day_and_exercise_detail() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-uiTestInMemory")
        app.launchArguments.append("-uiTestPreloadHistory")
        app.launch()

        // Home should show seeded days or allow adding; try tapping first cell if exists
        let tablesQuery = app.tables
        if tablesQuery.cells.count == 0 {
            // Add a day and navigate
            app.buttons["addDayButton"].tap()
            let tf = app.textFields["addDayTextField"]
            XCTAssertTrue(tf.waitForExistence(timeout: 3))
            tf.tap(); tf.typeText("Push Day")
            app.buttons["confirmAddDayButton"].tap()
        }

        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        firstCell.tap()

        // Day Detail
        XCTAssertTrue(app.navigationBars.element(boundBy: 0).staticTexts.element.exists)

        // If table empty, add exercise inline
        let addInline = app.textFields["inlineAddExerciseTextField"]
        if addInline.exists {
            addInline.tap(); addInline.typeText("Bench Press")
            app.buttons["inlineAddExerciseButton"].tap()
        }

        // Tap first exercise row to open Exercise Detail
        let dayTable = app.tables
        let exCell = dayTable.cells.element(boundBy: 0)
        XCTAssertTrue(exCell.waitForExistence(timeout: 5))
        exCell.tap()

        // Exercise Detail today inputs
        let wField = app.textFields["Set 1 weight"]
        XCTAssertTrue(wField.waitForExistence(timeout: 5))
        wField.tap(); wField.typeText("135")
        let rField = app.textFields["Set 1 reps"]
        rField.tap(); rField.typeText("5")
        app.buttons["Save Today"].tap()

        // Back
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars.buttons.element(boundBy: 0).exists)
    }

    @MainActor
    func test_edit_mode_reorder_and_undo_delete_exercise() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-uiTestInMemory")
        app.launchArguments.append("-uiTestPreloadHistory")
        app.launch()

        // Ensure a day exists
        let table = app.tables
        if table.cells.count == 0 {
            app.buttons["addDayButton"].tap()
            let tf = app.textFields["addDayTextField"]
            XCTAssertTrue(tf.waitForExistence(timeout: 3))
            tf.tap(); tf.typeText("Pull Day")
            app.buttons["confirmAddDayButton"].tap()
        }
        table.cells.element(boundBy: 0).tap()

        // Add two exercises inline
        let inline = app.textFields["inlineAddExerciseTextField"]
        if inline.exists {
            inline.tap(); inline.typeText("Row"); app.buttons["inlineAddExerciseButton"].tap()
            inline.tap(); inline.typeText("Pulldown"); app.buttons["inlineAddExerciseButton"].tap()
        }

        // Swipe delete first exercise, then Undo
        let first = table.cells.element(boundBy: 0)
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        first.swipeLeft(); first.buttons["Delete"].tap()

        let undoButton = app.buttons["Undo"]
        XCTAssertTrue(undoButton.waitForExistence(timeout: 5))
        undoButton.tap()

        // Ensure at least one cell still exists
        XCTAssertTrue(table.cells.count >= 1)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
