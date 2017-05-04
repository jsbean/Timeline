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

/// Consider implementing fully fledged type Schedule
public typealias Schedule = SortedDictionary<Seconds, [Action]>

/// Store closures to be performed at offsets.
///
/// Playback can occur at real-time, or modified by the `playbackRate`.
///
public class Timeline {
    
    // MARK: - Instance Properties
    
    /// Closure to be called when the `Timeline` has reached the end.
    public var completion: (() -> ())?

    /// The rate at which the `Timeline` is played-back. Defaults to `1`.
    ///
    /// - TODO: Add didSet to make mutable.
    public var playbackRate: Double = 1
    
    /// Current state of the `Timeline`.
    public var status: TimelineStatus = .stopped
    
    /// 
    internal var playbackIndex: Int = 0
    
    /// The current frame.
    internal var currentFrame: Frames {
        return frameOffset + frames(seconds: clock.elapsed, rate: rate)
    }

    /// Scale of `Seconds` to `Frames`.
    internal var rate: Seconds
    
    /// Frames stored at `pause()`, as starting point upon `resume()`.
    internal var frameOffset: Frames = 0
    
    // MARK: - Mechanisms
    
    /// Schedule that store actions to be performed by their offset time.
    ///
    /// At each offset point, any number of `Actions` can be performed.
    ///
    /// - TODO: Implement `ScheduleProtocol`.
    public var schedule: Schedule
    
    /// Calls the `advance()` function rapidly.
    public var timer: Timer?

    /// Clock.
    ///
    /// Measures timing between successive shots of the `timer`, to ensure accuracy and to 
    /// prevent drifting.
    public var clock = Clock()

    // MARK: - Initializers
    
    /// Creates an empty `Timeline`.
    public init(rate: Seconds = 1/120, completion: (() -> ())? = nil) {
        self.rate = rate
        self.schedule = [:]
        self.completion = completion
    }
    
    // MARK: - Instance Methods
    
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
        timer?.stop()
        status = .stopped
    }
    
    /// Pauses the `Timeline`.
    public func pause() {
        frameOffset = currentFrame
        timer?.stop()
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
    
    private func makeTimer() -> Timer {
        self.timer?.stop()
        let timer = Timer(interval: 1/120, performing: advance)
        timer.start()
        return timer
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
