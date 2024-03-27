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

    var regularActions: [(interval: Int, action: ActionClosure)]
    var actionCounter = 0

    /**
        Create a Monkey object with a randomised seed.
        This instance will generate a different stream of
        events each time it is created.

        There is an XCTest bug to be aware of when finding
        the frame to use. Here is an example of how to work
        around this problem:

        ```
        let application = XCUIApplication()

        // Workaround for bug in Xcode 7.3 and later. Snapshots are not properly
        // updated when you initially call app.frame, resulting in a zero-sized rect.
        // Doing a random query seems to update everything properly.
        _ = application.descendants(matching: .any).element(boundBy: 0).frame

        let monkey = Monkey(frame: application.frame)
        ```

        - parameter frame: The frame to generate events in.
          Should be set to the size of the device being tested.
    */
    public convenience init(frame: CGRect) {
        let time = Date().timeIntervalSinceReferenceDate
        let seed = UInt32(UInt64(time * 1000) & 0xffffffff)
        self.init(seed: seed, frame: frame)
    }

    /**
        Create a Monkey object with a fixed seed.
        This instance will generate the exact same stream of
        events each time it is created.
        Create a Monkey object with a randomised seed.
        This instance will generate a different stream of
        events each time it is created.

        There is an XCTest bug to be aware of when finding
        the frame to use. Here is an example of how to work
        around this problem:

        ```
        let application = XCUIApplication()

        // Workaround for bug in Xcode 7.3 and later. Snapshots are not properly
        // updated when you initially call app.frame, resulting in a zero-sized rect.
        // Doing a random query seems to update everything properly.
        _ = application.descendants(matching: .any).element(boundBy: 0).frame

        let monkey = Monkey(seed: 0, frame: application.frame)
        ```

        - parameter seed: The random seed to use. Each value
          will generate a different stream of events.
        - parameter frame: The frame to generate events in.
          Should be set to the size of the device being tested.
    */
    public init(seed: UInt32, frame: CGRect) {
        self.r = Random(seed: seed)
        self.frame = frame
        self.randomActions = []
        self.totalWeight = 0
        self.regularActions = []
    }

    /**
        Generate a number of random events.

        - Parameter iterations: The number of random events
          to generate. Does not include any fixed interval
          events that may also be generated.
    */
    public func monkeyAround(iterations: Int) {
        for _ in 1 ... iterations {
            actRandomly()
            actRegularly()
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
            actRegularly()
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

    /// Generate any pending fixed-interval events.
    public func actRegularly() {
        actionCounter += 1

        for action in regularActions {
            if actionCounter % action.interval == 0 {
                action.action()
            }
        }
    }

    /**
        Add a block for generating randomised events.

        - parameter weight: The relative probability of this
          event being generated. Can be any value larger than
          zero. Probabilities will be normalised to the sum
          of all relative probabilities.
        - parameter action: The block to run when this event
          is generated.
    */
    public func addAction(weight: Double, action: @escaping ActionClosure) {
        totalWeight += weight
        randomActions.append((accumulatedWeight: totalWeight, action: actInForeground(action)))
    }

    /**
        Add a block for fixed-interval events.

        - parameter interval: How often to generate this
          event. One of these events will be generated after
          this many randomised events have been generated.
        - parameter action: The block to run when this event
          is generated.
    */
    public func addAction(interval: Int, action: @escaping ActionClosure) {
        regularActions.append((interval: interval, action: actInForeground(action)))
    }

    /**
     Wrap your action with this function to make sure your actions are dispatched inside the app under test
     and not in some other app that the Monkey randomly opened.
     */
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

    /**
        Generate a random `Int`.

        - parameter lessThan: The returned value will be
          less than this value, and greater than or equal to zero.
    */
    public func randomInt(lessThan: Int) -> Int {
        return r.randomInt(lessThan: lessThan)
    }

    /**
        Generate a random `UInt`.

        - parameter lessThan: The returned value will be
          less than this value, and greater than or equal to  zero.
    */
    public func randomUInt(lessThan: UInt) -> UInt {
        return r.randomUInt(lessThan: lessThan)
    }

    /**
        Generate a random `CGFloat`.

        - parameter lessThan: The returned value will be
          less than this value, and greater than or equal to zero.
    */
    public func randomCGFloat(lessThan: CGFloat = 1) -> CGFloat {
        return CGFloat(r.randomDouble(lessThan: Double(lessThan)))
    }

    /// Generate a random `CGPoint` inside the frame of the app.
    public func randomPoint() -> CGPoint {
        return randomPoint(inRect: frame)
    }

    /**
        Generate a random `CGPoint` inside the frame of the app,
        avoiding the areas at the top and bottom of the screen
        that trigger a panel pull-out.
    */
    public func randomPointAvoidingPanelAreas() -> CGPoint {
        let frameWithoutTopAndBottom = CGRect(x: 0, y: topPanelPadding, width: frame.width, height: frame.height - topPanelPadding - bottomPanelPadding)
        return randomPoint(inRect: frameWithoutTopAndBottom)
    }

    /**
        Generate a random `CGPoint` inside the given `CGRect`.

        - parameter inRect: The rect within which to pick the point.
    */
    public func randomPoint(inRect rect: CGRect) -> CGPoint {
        return CGPoint(x: rect.origin.x + randomCGFloat(lessThan: rect.size.width), y: rect.origin.y +  randomCGFloat(lessThan: rect.size.height))
    }

    /// Generate a random `CGRect` inside the frame of the app.
    public func randomRect() -> CGRect {
        return rect(around: randomPoint(), inRect: frame)
    }

    /**
        Generate a random `CGRect` inside the frame of the app,
        sized to a given fraction of the whole frame.

        - parameter sizeFraction: The fraction of the size of
          the frame to use as the of the area for generated
          points.
    */
    public func randomRect(sizeFraction: CGFloat) -> CGRect {
        return rect(around: randomPoint(), sizeFraction: sizeFraction, inRect: frame)
    }

    /**
        Generate an array of random `CGPoints` in a loose cluster.

        - parameter count: Number of points to generate.
    */
    public func randomClusteredPoints(count: Int) -> [CGPoint] {
        let centre = randomPoint()
        let clusterRect = rect(around: centre, inRect: frame)

        var points = [ centre ]
        for _ in 1..<count {
            points.append(randomPoint(inRect: clusterRect))
        }

        return points
    }

    func rect(around point: CGPoint, sizeFraction: CGFloat = 3, inRect: CGRect) -> CGRect {
        let size: CGFloat = min(frame.size.width, frame.size.height) / sizeFraction
        let x0: CGFloat = (point.x - frame.origin.x) * (frame.size.width - size) / frame.size.width + frame.origin.x
        let y0: CGFloat = (point.y - frame.origin.y) * (frame.size.height - size) / frame.size.width  + frame.origin.y
        return CGRect(x: x0, y: y0, width: size, height: size)
    }

    func sleep(_ seconds: Double) {
        if seconds>0 {
            usleep(UInt32(seconds * 1000000.0))
        }
    }
}

