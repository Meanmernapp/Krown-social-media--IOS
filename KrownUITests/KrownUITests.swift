//
//  KrownUITests.swift
//  KrownUITests
//
//  Created by Anders Teglgaard on 10/10/2018.
//  Copyright © 2018 KrownUnity. All rights reserved.
//

import XCTest

class KrownUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        // continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        // XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testKrown() {

        let app = XCUIApplication()
        // if not logged in then login else execute tests
        if app.buttons["Login Button"].exists {
            login()
        }
        // HomeView
        sleep(6)
        takeScreenshots()

    }

    func login() {
        // Login Procedure if facebook has already logged via safari

        let app = XCUIApplication()
        allowPushNotificationsIfNeeded()
        // Login screen
        app.buttons["Login Button"].tap()
        app.buttons["Agree"].tap()

        addUIInterruptionMonitor(withDescription: "“Krown” Wants to Use “facebook.com” to Sign In") { (alerts) -> Bool in
            if alerts.buttons["Continue"].exists {
                alerts.buttons["Continue"].tap()
            }
            return true
        }
        XCUIApplication().tap()

        sleep(3)
        let webViewsQuery = app.webViews
        // if statement for checking login type
        if webViewsQuery.staticTexts["Bekræft login"].exists {
            webViewsQuery.buttons["Fortsæt"].tap()
        } else if webViewsQuery.staticTexts["Confirm Login"].exists {
            webViewsQuery/*@START_MENU_TOKEN@*/.buttons["Continue"]/*[[".otherElements[\"Confirm Login\"]",".otherElements[\"main\"].buttons[\"Continue\"]",".buttons[\"Continue\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        } else {
            webViewsQuery.staticTexts["Log in with the Facebook app"].tap()
            sleep(3)
            app.buttons["Open"].tap()
            sleep(3)
            app.webViews/*@START_MENU_TOKEN@*/.buttons["Continue"]/*[[".otherElements[\"Confirm login\"]",".otherElements[\"main\"].buttons[\"Continue\"]",".buttons[\"Continue\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        sleep(2)
    }

    func allowPushNotificationsIfNeeded() {
        addUIInterruptionMonitor(withDescription: "“Krown” Would Like to Send You Notifications") { (alerts) -> Bool in
            if alerts.buttons["Allow"].exists {
                alerts.buttons["Allow"].tap()
            }
            return true
        }
        XCUIApplication().tap()
    }

    func allowLocationIfNeeded() {
        addUIInterruptionMonitor(withDescription: "Allow “Krown” to access your location?") { (alerts) -> Bool in
            if alerts.buttons["Always Allow"].exists {
                alerts.buttons["Always Allow"].tap()
            }
            return true
        }
        XCUIApplication().tap()
    }

    func takeScreenshots() {
        allowLocationIfNeeded()

        let app = XCUIApplication()
        if app.staticTexts["Krown needs access to your location to find your potential matches. Please go to settings and set location access to 'Always'"].exists {
            XCUIApplication().buttons["No thanks"]/*@START_MENU_TOKEN@*/.tap()/*[[".tap()",".press(forDuration: 0.7);"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        }

        sleep(7) // Make sure that the response comes before continuing
        snapshot("0HomeScreen")

        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 0)
        element/*@START_MENU_TOKEN@*/.buttons["swipeCard_eventBtn"]/*[[".buttons[\"Swipe Card - Event Button\"]",".buttons[\"swipeCard_eventBtn\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("1SwipeCard_Events")
        app.buttons["arrow down"].tap()
        element.buttons["swipeCard_profileBtn"].tap()
        sleep(3)
        snapshot("2SwipeCard_Profile")
        app.buttons["Button"].tap()
        app.buttons["Chat Icon"].tap()
        sleep(3)
        snapshot("3Chat_List")
        let ChatListViewCell = app.tables.containing(.cell, identifier: "chatList_userCell").firstMatch
        ChatListViewCell.tap()
        snapshot("4Chat_Detail")
        app.navigationBars["Krown.ChatViewVC"].buttons["BackArrow"].tap()
        app.buttons["Chat Icon"].tap()
        app.buttons["Menu Icon"].tap()
        sleep(3)
        snapshot("5Menu")
        let MenuViewEventCell = app.tables.containing(.cell, identifier: "menu_suggestedEvent").firstMatch
        MenuViewEventCell.tap()
        sleep(3)
        snapshot("6Suggested_Event")

        XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .button).element.tap()

        app.tables/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier: "Scope")/*[[".cells.containing(.staticText, identifier:\"   Suggested events\")",".cells.containing(.staticText, identifier:\"Scope\")",".cells.containing(.staticText, identifier:\"Preferences\")",".cells.containing(.staticText, identifier:\"Anders\")"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[2]]@END_MENU_TOKEN@*/.children(matching: .button).element(boundBy: 1).tap()

        snapshot("7ScopeSettings")
        // TODO: There should be a view of getting a match

    }

}
