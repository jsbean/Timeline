//
//  Timeline.swift
//  Timeline
//
//  Created by James Bean on 5/1/17.
//
//

import Foundation
import Collections

/// Quantization of `Seconds` values by the `rate`.
public typealias Frames = UInt64

/// Store closures to be performed at offsets.
///
/// Playback can occur at real-time, or modified by the `playbackRate`.
///
public class Timeline {
    
    // MARK: - Associated Types

    /// Storage of arrays of `Action` objects to be performed at offsets.
    public typealias Schedule = SortedDictionary<Seconds, [Action]>
    
    // MARK: - Nested Types
    
    /// Status of the `Timeline`.
    public enum Status {
        
        /// The `Timeline` is playing.
        case playing
        
        /// The `Timeline` is stopped.
        case stopped
        
        /// The `Timeline` is paused at the given frame offset.
        case paused(Frames)
    }
    
    // MARK: - Instance Properties
    
    /// Closure to be called when the `Timeline` has reached the end.
    public var completion: (() -> ())?

    /// The rate at which the `Timeline` is played-back. Defaults to `1`.
    ///
    /// - TODO: Add didSet to make mutable.
    public var playbackRate: Double = 1
    
    /// Current state of the `Timeline`.
    public var status: Status = .stopped
    
    /// Privately modified index of current events.
    internal private(set) var playbackIndex: Int = 0
    
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
    
    /// Creates a new `Timer`, making sure that the previous `Timer` has been killed.
    private func makeTimer() -> Timer {
        self.timer?.stop()
        let timer = Timer(interval: 1/120, performing: advance)
        timer.start()
        return timer
    }
    
    /// - returns: The seconds, frames, and actions values of the next event, if present.
    /// Otherwise, `nil`.
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
    
    /// - returns: The seconds, frames, and actions values of the previous event, if present.
    /// Otherwise, `nil`.
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

    /// Called rapidly by the `timer`, a check is made based on the elapsed time whether or not
    /// actions need to be executed.
    ///
    /// If so, `playbackIndex` is incremented.
    private func advance() {

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

/// Converts seconds into frames for the given rate.
internal func frames(seconds: Seconds, rate: Seconds) -> Frames {
    let interval = 1 / rate
    return Frames(round(seconds * interval))
}

extension Timeline: CustomStringConvertible {

    // MARK: - CustomStringConvertible
    
    /// Printed description.
    public var description: String {
        return schedule.map { "\($0)" }.joined(separator: "\n")
    }
}
