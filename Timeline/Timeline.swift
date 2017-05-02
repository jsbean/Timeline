//
//  Timeline.swift
//  Timeline
//
//  Created by James Bean on 5/1/17.
//
//

import Foundation

public typealias Frames = Int

// TODO: Make Clock protocol 
// Implement DispatchTime for newer iOS
public class Clock {
    
    /// - returns: Current offset in `Seconds`.
    private static var now: Seconds {
        return Date().timeIntervalSince1970
    }
    
    private var startTime: Seconds = Clock.now
    
    /// - returns: Time elapsed since `start()`.
    public var elapsed: Seconds {
        return Clock.now - startTime
    }
    
    /// Stores the current time for measurement.
    public func start() {
        startTime = Clock.now
    }
}

public class Timeline: TimelineProtocol {

    // MARK: - Instance Properties
    
    /// Schedule that store actions to be performed by their offset time.
    ///
    /// At each offset point, any number of `Actions` can be performed.
    ///
    /// - TODO: Implement `ScheduleProtocol`.
    public var schedule: [Frames: [Action]]
    
    /// Current state of the `Timeline`.
    public var state: TimelineState = .stopped
    
    /// The rate at which the `Timeline` is played-back. Defaults to `1`.
    public var playbackRate: Double = 1
    
    internal var rate: Seconds

    internal var interval: Seconds {
        return 1 / rate
    }

    private var clock = Clock()
    
    private var timer: DispatchSourceTimer?
    
    // MARK: - Initializers
    
    /// Creates an empty `Timeline`.
    public init(rate: Seconds = 1/60) {
        self.rate = 1.0 / 120
        self.schedule = [:]
    }
    
    // MARK: - Instance Methods
    
    /// Adds the given `action` at the given `offset` in `Seconds`.
    public func add(
        action body: @escaping ActionBody,
        identifier: String,
        at offset: Seconds
    )
    {
        let action = AtomicAction(identifier: identifier, body: body)
        add(action, at: offset)
    }
    
    /// Adds the given `action`, to be performed every `interval`, offset by the given
    /// `offset`.
    public func loop(
        action body:  @escaping ActionBody,
        identifier: String,
        every interval: Seconds,
        offsetBy offset: Seconds
    )
    {
        let action = LoopingAction(identifier: identifier, interval: interval, body: body)
        add(action, at: offset)
    }
    
    private func add(_ action: Action, at offset: Seconds) {
        let offset = frames(seconds: offset)
        schedule.safelyAppend(action, toArrayWith: offset)
    }
    
    /// Removes all of the `Actions` from the `Timeline` with the given identifiers
    public func removeAll(identifiers: [String] = []) {
        
        // If no identifiers are provided, clear schedule entirely
        guard !identifiers.isEmpty else {
            schedule = [:]
            return
        }
        
        // Otherwise, remove the actions with matching the given identifiers
        for (offset, actions) in schedule {

            // Remove the actions with identifiers that match those requested for removal
            let filtered = actions.filter { action in
                !identifiers.contains(action.identifier)
            }
            
            // If no actions are left in an array, remove value at given offset
            schedule[offset] = filtered.isEmpty ? nil : filtered
        }
    }
    
    /// Starts the `Timeline`.
    public func start() {
        timer = makeTimer()
        clock.start()
        state = .playing
    }
    
    /// Stops the `Timeline` from executing, and is placed at the beginning.
    public func stop() {
        timer?.cancel()
        state = .stopped
    }
    
    /// Pauses the `Timeline`.
    ///
    /// - warning: Not currently available.
    ///
    public func pause() {
        fatalError()
    }
    
    /// Resumes the `Timeline`.
    ///
    /// - warning: Not currently available.
    ///
    public func resume() {
        fatalError()
    }
    
    /// Skips the given `time` in `Seconds`.
    ///
    /// - warning: Not currently available.
    public func skip(to time: Seconds) {
        fatalError()
    }
    
    private func makeTimer() -> DispatchSourceTimer {
        
        // Ensure that there is no zombie timer
        //self.timer?.invalidate()
        self.timer?.cancel()

        if #available(OSX 10.12, iOS 10, *) {
            
            let queue = DispatchQueue(label: "com.bean.timer", attributes: .concurrent)
            let timer = DispatchSource.makeTimerSource(queue: queue)
            
            let interval = DispatchTimeInterval.nanoseconds(Int(rate * 1_000_000_000))
            
            timer.scheduleRepeating(deadline: .now(), interval: interval)
            timer.setEventHandler {
                self.advance()
            }
            
            timer.resume()
            return timer
            
        } else {

            fatalError()
//            
//            // Create a `Timer` that will call the `advance` method at the given `rate`
//            timer = Timer.scheduledTimer(
//                timeInterval: rate,
//                target: self,
//                selector: #selector(advance),
//                userInfo: nil,
//                repeats: true
//            )

        }

        // Fire the `advance` method immediately, as the above method only starts after the
        // delay of `rate`.
        //timer.fire()
        
        
        // Return the timer
        //return timer
    }
    
    @objc internal func advance() {

        let currentFrame = frames(seconds: clock.elapsed)
        
        print("current frame: \(currentFrame); elapsed: \(clock.elapsed)")

        // Retrieve the actions that need to be performed now, if any
        if let actions = schedule[currentFrame] {
            
            print("actions: \(actions)")

            actions.forEach { action in
                
                // perform the action
                action.body()
                
                // if looping action, add next action
                if let loopingAction = action as? LoopingAction {
                    add(loopingAction, at: clock.elapsed + loopingAction.interval)
                }
            }
        }
    }
    
    // MARK: - Helper functions
    
    internal func frames(seconds: Seconds) -> Frames {
        return Frames(round(seconds * interval))
    }
    
    internal func seconds(frames: Frames) -> Seconds {
        return Seconds(frames) / interval
    }
}

//extension Timeline: Collection {
//    
//    // MARK: - Collection
//
//    /// Start index. Forwards `registry.keyStorage.startIndex`.
//    public var startIndex: Int {
//        return schedule.keys.startIndex
//    }
//
//    /// End index. Forwards `registry.keyStorage.endIndex`.
//    public var endIndex: Int {
//        //return schedule.keys.endIndex
//        return schedule.keys.map {
//    }
//
//    /// Next index. Forwards `registry.keyStorage.index(after:)`.
//    public func index(after i: Int) -> Int {
//        guard i != endIndex else { fatalError("Cannot increment endIndex") }
//        return schedule.keys.index(after: i)
//    }
//
//    /**
//     - returns: Value at the given `index`. Will crash if index out-of-range.
//     */
//    public subscript (index: Int) -> (Int, [Action]) {
//
//        let key = schedule.keys[index]
//
//        guard let actions = schedule[key] else {
//            fatalError("Values not stored correctly")
//        }
//
//        return (key, actions)
//    }
//
//    /**
//     - returns: Array of actions at the given `frames`, if present. Otherwise, `nil`.
//     */
//    public subscript (frames: Int) -> [ActionType]? {
//        return registry[frames]
//    }
//
//    /**
//     - returns: Array of actions at the given `seconds`, if present. Otherwise, `nil`.
//     */
//    public subscript (seconds: Seconds) -> [ActionType]? {
//        return registry[frames(from: seconds)]
//    }
//}
//
//extension Timeline: CustomStringConvertible {
//
//    public var description: String {
//        return registry.map { "\($0)" }.joined(separator: "\n")
//    }
//}
