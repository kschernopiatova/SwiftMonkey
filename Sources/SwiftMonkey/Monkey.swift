import UIKit
import XCTest

public class Monkey {
    public typealias ActionClosure = () -> Void
    
    public var topPanelPadding: CGFloat = 20
    public var bottomPanelPadding: CGFloat = 20
    
    var r: Random
    let frame: CGRect
    var randomActions: [(accumulatedWeight: Double, action: ActionClosure)]
    var totalWeight: Double
    var actionCounter = 0

    public convenience init(frame: CGRect) {
        let time = Date().timeIntervalSinceReferenceDate
        let seed = UInt32(UInt64(time * 1000) & 0xffffffff)
        self.init(seed: seed, frame: frame)
    }

    public init(seed: UInt32, frame: CGRect) {
        self.r = Random(seed: seed)
        self.frame = frame
        self.randomActions = []
        self.totalWeight = 0
    }

    public func monkeyAround(iterations: Int) {
        for _ in 1 ... iterations {
            actRandomly()
        }
    }

    /// Generate random events or fixed-interval events based forever, for a specific duration or until the app crashes.
    ///
    /// - Parameter duration: The duration for which to generate the random events.
    ///                       Set to `.infinity` by default.
    public func monkeyAround(forDuration duration: TimeInterval = .infinity) {
        let monkeyTestingTime = Date().timeIntervalSince1970
        repeat {
            actRandomly()
        } while ((Date().timeIntervalSince1970 - monkeyTestingTime) < duration)
    }

    /// Generate one random event.
    public func actRandomly() {
        let x = r.randomDouble() * totalWeight
        for action in randomActions {
            if x < action.accumulatedWeight {
                action.action()
                return
            }
        }
    }

    public func addAction(weight: Double, action: @escaping ActionClosure) {
        totalWeight += weight
        randomActions.append((accumulatedWeight: totalWeight, action: action))
    }
    
    func actInForeground(_ action: @escaping ActionClosure) -> ActionClosure {
        guard #available(iOS 9.0, *) else {
            return action
        }
        
        let app = XCUIApplication()
        let closure: ActionClosure = {
            if app.state != .runningForeground {
                app.activate()
            }
            action()
        }
        return {
            if Thread.isMainThread {
                closure()
            } else {
                DispatchQueue.main.async(execute: closure)
            }
        }
    }

    public func randomCGFloat(lessThan: CGFloat = 1) -> CGFloat {
        return CGFloat(r.randomDouble(lessThan: Double(lessThan)))
    }

    public func randomPoint() -> CGPoint {
        return randomPoint(inRect: frame)
    }
    
    public func randomOffset() -> CGVector {
        let point = randomPoint()
        return CGVector(dx: point.x, dy: point.y)
    }

    public func randomPointAvoidingPanelAreas() -> CGPoint {
        let frameWithoutTopAndBottom = CGRect(x: 0, y: topPanelPadding, width: frame.width, height: frame.height - topPanelPadding - bottomPanelPadding)
        return randomPoint(inRect: frameWithoutTopAndBottom)
    }
    
    public func randomPoint(inRect rect: CGRect) -> CGPoint {
        return CGPoint(x: rect.origin.x + randomCGFloat(lessThan: rect.size.width), y: rect.origin.y +  randomCGFloat(lessThan: rect.size.height))
    }
}

