//
//  flamingoUITests.swift
//  flamingoUITests
//
//  Created by Alexis Creuzot on 26/05/2020.
//  Copyright © 2020 alexiscreuzot. All rights reserved.
//

import XCTest

class flamingoUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launchArguments = ["screenshots"]
        setupSnapshot(app)
        app.launch()
                
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(8)
        snapshot("0_top")
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(8)
        snapshot("1_news")
        app.tabBars.buttons.element(boundBy: 2).tap()
        snapshot("3_settings")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
