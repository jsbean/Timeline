//
//  Timeline.swift
//  Timeline
//
//  Created by James Bean on 5/1/17.
//
//

import Foundation
import Collections

public typealias Frames = UInt64

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

/// Consider implementing fully fledged type Schedule
public typealias Schedule = SortedDictionary<Seconds, [Action]>

public class Timeline: TimelineProtocol {
    
    // MARK: - Instance Properties
    
    /// Schedule that store actions to be performed by their offset time.
    ///
    /// At each offset point, any number of `Actions` can be performed.
    ///
    /// - TODO: Implement `ScheduleProtocol`.
    public var schedule: Schedule
    
    private var playbackOffsets: [Frames] = []
    
    private var playbackIndex: Int = 0
    
    /// Current state of the `Timeline`.
    public var status: TimelineStatus = .stopped
    
    /// - TODO: Make a computed property
    internal var currentFrame: Frames {
        return frameOffset + frames(seconds: clock.elapsed, rate: rate)
    }
    
    /// The rate at which the `Timeline` is played-back. Defaults to `1`.
    public var playbackRate: Double = 1
    
    ///
    internal var rate: Seconds
    
    internal var frameOffset: Frames = 0

    /// Clock.
    ///
    /// - TODO: Implement Clock protocol.
    public var clock = Clock()
    
    /// Timer.
    ///
    /// - TODO: Implement Timer protocol.
    public var timer: DispatchSourceTimer?
    
    /// Closure to be called when the `Timeline` has reached the end.
    public var completion: (() -> ())?
    
    // MARK: - Initializers
    
    /// Creates an empty `Timeline`.
    public init(rate: Seconds = 1/120, completion: (() -> ())? = nil) {
        self.rate = rate
        self.schedule = [:]
        self.completion = completion
    }
    
    // MARK: - Instance Methods
    
    /// Adds the given `action` at the given `offset` in `Seconds`.
    public func add(
        action body: @escaping Action.Body,
        identifier: String,
        at offset: Seconds
    )
    {
        let action = Action(kind: .atomic, identifier: identifier, body: body)
        add(action, at: offset)
    }
    
    /// Adds the given `action`, to be performed every `interval`, offset by the given
    /// `offset`.
    public func loop(
        action body:  @escaping Action.Body,
        identifier: String,
        every interval: Seconds,
        offsetBy offset: Seconds = 0
    )
    {
        let action = Action(
            kind: .looping(interval: interval, status: .source),
            identifier: identifier,
            body: body
        )

        add(action, at: offset)
    }
    
    private func add(_ action: Action, at offset: Seconds) {
        schedule.safelyAppend(action, toArrayWith: offset)
    }
    
    /// Removes all of the `Actions` from the `Timeline` with the given identifiers
    ///
    /// - TODO: Refactor to `Schedule` struct
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
            schedule[offset] = !filtered.isEmpty ? filtered : nil
        }
    }
    
    /// Starts the `Timeline`.
    public func start() {
        playbackIndex = 0
        frameOffset = 0
        status = .playing
        timer = makeTimer()
        clock.start()
    }
    
    /// Stops the `Timeline` from executing, and is placed at the beginning.
    public func stop() {
        frameOffset = 0
        timer?.cancel()
        status = .stopped
    }
    
    /// Pauses the `Timeline`.
    public func pause() {
        frameOffset = currentFrame
        timer?.cancel()
        status = .paused(frameOffset)
    }
    
    /// Resumes the `Timeline`.
    public func resume() {
        timer = makeTimer()
        clock.start()
        status = .playing
    }
    
    /// Skips the given `time` in `Seconds`.
    ///
    /// - warning: Not currently available.
    public func skip(to time: Seconds) {
        fatalError()
    }
    
    private func makeTimer() -> DispatchSourceTimer {
        
        timer?.cancel()

        if #available(OSX 10.12, iOS 10, *) {
            
            //let interval = DispatchTimeInterval.nanoseconds(Int(rate * 1_000_000_000))
            let interval = DispatchTimeInterval.milliseconds(4)
            
            let queue = DispatchQueue(
                label: "com.bean.timer",
                qos: .userInteractive,
                attributes: .concurrent
            )

            let timer = DispatchSource.makeTimerSource(queue: queue)
            timer.setEventHandler(handler: advance)
            timer.scheduleRepeating(deadline: .now(), interval: interval)
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
    }
    
    private var next: (Seconds, Frames, [Action])? {

        guard playbackIndex < schedule.keys.endIndex else {
            return nil
        }

        let (nextSeconds, nextActions) = schedule[playbackIndex]
        
        return (
            nextSeconds,
            frames(seconds: nextSeconds, rate: self.rate * playbackRate),
            nextActions
        )
    }
    
    private var previous: (Seconds, Frames, [Action])? {
        
        guard playbackIndex > schedule.keys.startIndex else {
            return nil
        }
        
        let (prevSeconds, prevActions) = schedule[playbackIndex - 1]
        
        return (
            prevSeconds,
            frames(seconds: prevSeconds, rate: self.rate * playbackRate),
            prevActions
        )
    }
    
    // loops: [Seconds: Action]
    var loops: [Seconds: Action] = [:]
    
    @objc internal func advance() {

        guard let (nextSeconds, nextFrame, nextActions) = next else {
            completion?()
            stop()
            return
        }
        
        if currentFrame >= nextFrame {
            
            nextActions.forEach { action in
                
                // perform the action body
                action.body()
                
                if case let .looping(interval, _) = action.kind {
                    add(action.echo, at: nextSeconds + interval)
                }
            }
            
            playbackIndex += 1
        }
    }
}

func clearEchoes(from actions: [Action]) -> [Action]? {
    
    let filtered = actions.filter { action in
        switch action.kind {
        case .atomic:
            return true
        case let .looping(_, status) where status == .source:
            return true
        default:
            return false
        }
    }
    
    return !filtered.isEmpty ? filtered : nil
}

internal func frames(seconds: Seconds, rate: Seconds) -> Frames {
    let interval = 1 / rate
    return Frames(round(seconds * interval))
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
extension Timeline: CustomStringConvertible {

    public var description: String {
        return schedule.map { "\($0)" }.joined(separator: "\n")
    }
}
