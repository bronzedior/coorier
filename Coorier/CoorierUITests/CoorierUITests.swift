//
//  CoorierUITests.swift
//  CoorierUITests
//
//  Created by Christopher Hardy Gunawan on 22/10/26.
//

import XCTest

final class CoorierUITests: XCTestCase {

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
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testTwoPlayersOpenGameRoomDirectly() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Start"].tap()
        app.buttons["Debug menu"].tap()
        app.buttons["Add player"].tap()
        app.buttons["Ready for work"].tap()

        let nameField = app.textFields["Your name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText("Host\n")
        app.buttons["This is me"].tap()

        XCTAssertTrue(app.staticTexts["That's you!"].waitForExistence(timeout: 5))
        app.buttons["Next"].tap()
        app.buttons["Next"].tap()
        app.buttons["Got it!"].tap()
        let hostSeat = app.descendants(matching: .any).matching(identifier: "host-seat").firstMatch
        XCTAssertTrue(hostSeat.waitForExistence(timeout: 3))
        XCTAssertEqual(hostSeat.frame.midX, app.frame.midX, accuracy: 20)
        XCTAssertGreaterThan(hostSeat.frame.midY, app.frame.midY)
        app.buttons["Let's Work"].tap()

        XCTAssertTrue(app.staticTexts["Adulting 101"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCompletedGameOpensEndPageDirectly() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-localGame", "2", "-autoplay"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Adulting 101"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Good Luck\nOn Your Next Shift"].waitForExistence(timeout: 120))
    }

    @MainActor
    func testGameStartsWithReadyLetters() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-localGame", "3"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Adulting 101"].waitForExistence(timeout: 5))
        let readyLetters = app.descendants(matching: .any).matching(identifier: "ready-letter")
        XCTAssertGreaterThan(readyLetters.count, 0)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
