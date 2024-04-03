//
//  File.swift
//  
//
//  Created by Ksenia Chernopiatova on 3.04.24.
//

import Foundation
import XCTest

extension Monkey {
    
    internal func addTestTapAlertAction(app: XCUIApplication) {
        for i in 0 ..< app.alerts.count {
            let alert = app.alerts.element(boundBy: i)
            let buttons = alert.descendants(matching: .button)
            XCTAssertNotEqual(buttons.count, 0, "No buttons in alert")
            let index = self.r.randomInt(lessThan: buttons.count)
            let button = buttons.element(boundBy: index)
            button.tap()
        }
    }
    
    internal func closeAlerts(app: XCUIApplication) {
        if (app.buttons["Cancel"].exists) {
            app.buttons["Cancel"].tap()
        }
    }
    
    internal func addTestTapAction(app: XCUIApplication, weight: Double) {
        self.addTestTapAlertAction(app: app)
        self.closeAlerts(app: app)
        var buttons = app.buttons
        if (buttons.count == 0) {
            buttons = app.staticTexts
        }
        var button: XCUIElement
        repeat {
            var index = self.r.randomInt(lessThan: buttons.count)
            button = buttons.element(boundBy: index)
        } while !button.isHittable
        button.tap()
    }
    
    internal func addTestDoubleTapAction(app: XCUIApplication, weight: Double) {
        self.addTestTapAlertAction(app: app)
        self.closeAlerts(app: app)
        var buttons = app.buttons
        if (buttons.count == 0) {
            buttons = app.staticTexts
        }
        var button: XCUIElement
        repeat {
            var index = self.r.randomInt(lessThan: buttons.count)
            button = buttons.element(boundBy: index)
        } while !button.isHittable
        button.doubleTap()
    }
    
    internal func addTestLongPressAction(app: XCUIApplication, weight: Double) {
        self.addTestTapAlertAction(app: app)
        self.closeAlerts(app: app)
        var buttons = app.buttons
        if (buttons.count == 0) {
            buttons = app.staticTexts
        }
        var button: XCUIElement
        repeat {
            var index = self.r.randomInt(lessThan: buttons.count)
            button = buttons.element(boundBy: index)
        } while !button.isHittable
        button.press(forDuration: 0.5)
    }
    
    internal func addTestSwipeAction(app: XCUIApplication, weight: Double) {
        self.addTestTapAlertAction(app: app)
        self.closeAlerts(app: app)
        let startCoordinate = app.coordinate(withNormalizedOffset: .zero).withOffset(self.randomOffset())
        let endCoordinate = app.coordinate(withNormalizedOffset: .zero).withOffset(self.randomOffset())
        startCoordinate.press(forDuration: 0.2, thenDragTo: endCoordinate)
    }
    
    internal func addTestRotateAction(weight: Double) {
        let orient = [UIDeviceOrientation.portrait , UIDeviceOrientation.portraitUpsideDown, 
                      UIDeviceOrientation.landscapeLeft, UIDeviceOrientation.landscapeRight]
        XCUIDevice.shared.orientation = orient[Int(arc4random_uniform(UInt32(orient.count)))]
    }
    
    internal func addTestVolumeUpAction(weight: Double) {
        addAction(weight: weight) {
            XCUIDevice.shared.press(XCUIDevice.Button.volumeUp)
        }
    }
    
    internal func addTestVolumeDownAction(weight: Double) {
        addAction(weight: weight) {
            XCUIDevice.shared.press(XCUIDevice.Button.volumeDown)
        }
    }
}
