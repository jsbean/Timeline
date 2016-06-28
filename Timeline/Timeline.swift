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

public typealias Seconds = Double
public typealias Frames = UInt
public typealias Action = () -> ()

/**
 Timeline
 
 - TODO: Conform to `SequenceType` & `CollectionType`, make `regsitry` private.
*/
public final class Timeline {
    
    // Storage
    public var registry = SortedOrderedDictionary<[Action], Frames>()
    
    public var loopingActions: [LoopingAction] = []
    
    // Internal timer
    private var timer: NSTimer = NSTimer()
    
    // Start time
    private var startTime: Seconds = 0

    // If the timer is currently running
    private var timerIsActive: Bool = false
    
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

    // Offset in seconds of timer.
    public var currentOffset: Seconds {
        return seconds(from: currentFrame)
    }
    
    // Amount of time in seconds until the next event, if present. Otherwise, `nil`.
    public var secondsUntilNext: Seconds? {
        guard let nextFrames = next()?.0 else { return nil }
        return seconds(from: nextFrames - currentFrame)
    }
    
    // Offset in seconds of the next event, if present. Otherwise, `nil`.
    public var offsetOfNext: Seconds? {
        guard let next = next() else { return nil }
        return seconds(from: next.0)
    }
    
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
    public func add(at timeStamp: Seconds, action: Action) {
        registry.safelyAppend(action, toArrayWith: frames(from: timeStamp))
    }
    
    // generalize action
    public func add(with interval: Seconds, loopingAction: Action) {
        let loopingAction = LoopingAction(timeInterval: interval, action: loopingAction)
        loopingActions.append(loopingAction)
    }
    
    /**
     Clear all elements from the timeline.
     */
    public func clear() {
        registry = SortedOrderedDictionary()
    }
    
    // MARK: Operating the timeline.
    
    /**
     Start the timeline.
     */
    public func start() {
        currentFrame = 0
        startTime = CACurrentMediaTime()
        timerIsActive = true
        timer = makeTimer()
    }
    
    /**
     Stop the timeline.
     */
    public func stop() {
        timer.invalidate()
        timerIsActive = false
        currentFrame = 0
    }
    
    /**
     Pause the timeline.
     */
    public func pause() {
        timer.invalidate()
        timerIsActive = false
        startTime = CACurrentMediaTime()
    }
    
    /**
     Resume the timeline.
     */
    public func resume() {
        if timerIsActive { return }
        timer = makeTimer()
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
        if let actions = registry[currentFrame] { actions.forEach { $0() } }
        if next() == nil {
            print("next is nil")
            // check if there are looping actions that need to be executed
            if !loopingActions.isEmpty {
                print("there are looping actions")
                for action in loopingActions {
                    add(at: action.timeInterval + secondsElapsed) { action.action() }
                }
            } else {
                stop()
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
    public func next() -> (Frames, [Action])? {
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