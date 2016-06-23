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

// TODO: inject Duration framework
public typealias Seconds = Double

public typealias Action = () -> ()

/// Description
public final class Timeline {
    
    // Storage
    public var registry: [UInt: [Action]] = [:]
    
    // Internal timer
    private var timer: NSTimer = NSTimer()
    
    // Start time
    private var startTime: Seconds = 0
    
    // How often the timer should advance
    private let rate: Seconds
    
    // If the timer is currently running
    private var timerIsActive: Bool = false
    
    // The amount of time in seconds that has elapsed since starting or resuming from paused.
    private var secondsElapsed: Seconds {
        return CACurrentMediaTime() - startTime
    }
    
    // MARK: - Initializers
    
    /**
     Create a Timeline with an update interval.
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
        registry.safelyAppend(action, toArrayWithKey: frames(from: timeStamp))
    }
    
    /**
     Clear all elements from the timeline.
     */
    public func clear() {
        registry = [:]
    }
    
    // MARK: Operating the timeline.
    
    /**
     Start the timeline.
     */
    public func start() {
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
    
    private func makeTimer() -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(
            rate,
            target: self,
            selector: #selector(advance),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func advance() {
        if let actions = registry[frames(from: secondsElapsed)] {
            actions.forEach { $0() }
        }
    }
    
    private func frames(from seconds: Seconds) -> UInt {
        return UInt(round(seconds * rate))
    }
}

