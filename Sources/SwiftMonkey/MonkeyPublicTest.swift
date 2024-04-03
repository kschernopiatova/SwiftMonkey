//
//  File.swift
//  
//
//  Created by Ksenia Chernopiatova on 3.04.24.
//

import Foundation
import XCTest

extension Monkey {
    
    public func addDefaultTestPublicActions(app: XCUIApplication) {
        self.addClickAction(app: app, weight: 25)
        self.addSwipeAction(app: app, weight: 15)
        self.addDoubleClickAction(app: app, weight: 10)
        self.addLongPressAction(app: app, weight: 10)
    }
    
    public func addClickAction(app: XCUIApplication, weight: Double) {
        addAction(weight: weight, action: {
            self.addTestTapAction(app: app, weight: weight)
        })
    }
    
    public func addDoubleClickAction(app: XCUIApplication, weight: Double) {
        addAction(weight: weight, action: {
            self.addTestDoubleTapAction(app: app, weight: weight)
        })
    }
    
    public func addLongPressAction(app: XCUIApplication, weight: Double) {
        addAction(weight: weight, action: {
            self.addTestLongPressAction(app: app, weight: weight)
        })
    }
    
    public func addSwipeAction(app: XCUIApplication, weight: Double) {
        addAction(weight: weight, action: {
            self.addTestSwipeAction(app: app, weight: weight)
        })
    }
    
    public func addRotateAction(weight: Double) {
        addAction(weight: weight, action: {
            self.addTestRotateAction(weight: weight)
        })
    }
    
    public func addVolumeUpAction(weight: Double) {
        addAction(weight: weight, action: {
            self.addTestVolumeUpAction(weight: weight)
        })
    }
    
    public func addVolumeDownAction(weight: Double) {
        addAction(weight: weight, action: {
            self.addTestVolumeDownAction(weight: weight)
        })
    }
}
