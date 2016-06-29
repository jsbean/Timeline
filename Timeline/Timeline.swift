//
//  Timer.swift
//  Timer
//
//  Created by James Bean on 5/15/16.
//
//

import Foundation
import QuartzCore
import DictionaryTools

/// Time unit for beats-per-minute.
public typealias Tempo = Double

/// Time unit for seconds.
public typealias Seconds = Double

/// Time unit inverse to the `rate` of a `Timeline`.
public typealias Frames = UInt

/// Function to be performed by a `Timeline`.
public typealias Action = () -> ()

/**
 Scheduler that performs functions at given times.
 
 **Examples:**
 
 Schedule singular, atomic events at a given time in `Seconds`:
 
 ```
 let timeline = Timeline()
 timeline.add(at: 1) { print("one second") }
 timeline.start()
 
 // after one second:
 // => one second
 ```
 
 Schedule a looping action with a time interval between firings:
 
 ```
 timeline.addLooping(interval: 1) { print("every second") }
 
 // after one second:
 // => every second
 // after two seconds:
 // => every second
 ...
 ```
 
 Schedule a looping action at a tempo in beats-per-minute:
 
 ```
 timeline.addLooping(at: 60) { print("bpm: 60") }
 ```
 
 Schedule a looping action with an optional offset:
 
 ```
 timeline.addLooping(at: 60) { self.showMetronome() }
 timeline.addLooping(at: 60, offset: 0.2) { self.hideMetronome() }
 ```
 
 - TODO: Conform to `SequenceType` & `CollectionType`.
 - TODO: Encapsulate `registry` below abstraction barrier
*/
public final class Timeline {
    
    /**
     Storage of actions.
     - TODO: Make private.
    */
    public var registry = SortedOrderedDictionary<[ActionType], Frames>()
    
    /// - returns: `true` if the internal timer is running. Otherwise, `false`.
    public var isActive: Bool = false
    
    /// Offset in `Seconds` of internal timer.
    public var currentOffset: Seconds {
        return seconds(from: currentFrame)
    }
    
    /// Amount of time in `Seconds` until the next event, if present. Otherwise, `nil`.
    public var secondsUntilNext: Seconds? {
        guard let nextFrames = next()?.0 else { return nil }
        return seconds(from: nextFrames - currentFrame)
    }
    
    /// Offset in `Seconds` of the next event, if present. Otherwise, `nil`.
    public var offsetOfNext: Seconds? {
        guard let next = next() else { return nil }
        return seconds(from: next.0)
    }
    
    // Internal timer
    private var timer: NSTimer = NSTimer()
    
    // Start time
    private var startTime: Seconds = 0
    
    // The amount of time in seconds that has elapsed since starting or resuming from paused.
    private var secondsElapsed: Seconds {
        return CACurrentMediaTime() - startTime
    }
    
    // How often the timer should advance.
    private let rate: Seconds
    
    // The inverted rate.
    private var interval: Seconds { return 1 / rate }
    
    // make private -- internal only for testing
    internal var currentFrame: Frames = 0
    
    // MARK: - Initializers
    
    /**
     Create a Timeline with an update rate.
     */
    public init(rate: Seconds = 1/60) {
        self.rate = rate
    }
    
    // MARK: - Instance Methods
    
    // MARK: Modifying the actions in the timeline
    
    /**
     Add a given `action` at a given `timeStamp` in seconds.
     */
    public func add(at timeStamp: Seconds, action function: Action) {
        let action = AtomicAction(timeStamp: timeStamp, function: function)
        add(action, at: timeStamp)
    }
    
    /**
     Add a looping action at a given `tempo`.
     */
    public func addLooping(
        at tempo: Tempo,
        offset: Seconds = 0,
        action function: Action
    )
    {
        let timeInterval = tempo / 60
        let action = LoopingAction(timeInterval: timeInterval, function: function)
        add(action, at: offset)
    }
    
    /**
     Add a looping action with the given `interval` between firings.
     */
    public func addLooping(
        interval interval: Seconds,
        offset: Seconds = 0,
        action function: Action
    )
    {
        let action = LoopingAction(timeInterval: interval, function: function)
        add(action, at: offset)
    }
    
    public func add(action: ActionType, at timeStamp: Seconds) {
        registry.safelyAppend(action, toArrayWith: frames(from: timeStamp))
    }
    
    /**
     Clear all elements from the timeline.
     */
    public func clear() {
        registry = SortedOrderedDictionary()
    }
    
    // MARK: Operating the timeline
    
    /**
     Start the timeline.
     */
    public func start() {
        currentFrame = 0
        startTime = CACurrentMediaTime()
        isActive = true
        timer = makeTimer()
    }
    
    /**
     Stop the timeline.
     */
    public func stop() {
        timer.invalidate()
        isActive = false
        currentFrame = 0
    }
    
    /**
     Pause the timeline.
     */
    public func pause() {
        timer.invalidate()
        isActive = false
        startTime = CACurrentMediaTime()
    }
    
    /**
     Resume the timeline.
     */
    public func resume() {
        if isActive { return }
        timer = makeTimer()
        isActive = true
    }
    
    /**
     Jump to a given offset.
     */
    public func skip(to time: Seconds) {
        pause()
        currentFrame = frames(from: time)
    }
    
    private func makeTimer() -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(
            rate,
            target: self,
            selector: #selector(advance),
            userInfo: nil,
            repeats: true
        )
    }

    @objc internal func advance() {
        if let actions = registry[currentFrame] {
            actions.forEach {
                
                // perform function
                $0.function()
                
                // if looping action,
                if let loopingAction = $0 as? LoopingAction {
                    add(loopingAction, at: secondsElapsed + loopingAction.timeInterval)
                }
            }
        }
        currentFrame += 1
    }
    
    private func frames(from seconds: Seconds) -> Frames {
        return Frames(seconds * interval)
    }
    
    private func seconds(from frames: Frames) -> Seconds {
        return Seconds(frames) / interval
    }
}

extension Timeline: GeneratorType {
    
    // update to self.filter when sequenceType conformance occurs
    public func next() -> (Frames, [ActionType])? {
        return registry
            .lazy
            .filter { $0.0 > self.currentFrame }
            .sort { $0.0 < $1.0 }
            .first
    }
}

extension Timeline: CustomStringConvertible {
    
    public var description: String {
        return registry.map { "\($0)" }.joinWithSeparator("\n")
    }
}