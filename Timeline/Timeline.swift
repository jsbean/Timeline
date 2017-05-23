//
//  Timeline.swift
//  Timeline
//
//  Created by James Bean on 5/1/17.
//
//

import Foundation
import Collections
import ArithmeticTools

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
        case paused(Seconds)
    }
    
    // MARK: - Instance Properties

    /// The rate at which the `Timeline` is played-back. Defaults to `1`.
    public var playbackRate: Double {
        didSet {
            guard case .playing = status else { return }
            pause()
            resume()
        }
    }
    
    /// Current state of the `Timeline`.
    public var status: Status = .stopped
    
    /// Privately modified index of current events.
    internal private(set) var playbackIndex: Int = 0
    
    /// The current frame.
    internal var currentFrame: Frames {
        return frames(
            scheduledDate: clock.elapsed + lastPausedDate,
            lastPausedDate: lastPausedDate,
            rate: rate,
            playbackRate: 1 // always move through time as if playback rate doesn't matter
        )
    }

    /// Scale of `Seconds` to `Frames`.
    internal var rate: Seconds
    
    /// Seconds (in schedule-time) of last pause.
    internal var lastPausedDate: Seconds = 0

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
    
    /// Closure to be called when the `Timeline` has reached the end.
    public var completion: (() -> ())?
    
    /// Identifier of `Timeline`.
    public let identifier: String

    // MARK: - Initializers
    
    /// Creates an empty `Timeline`.
    public init(
        identifier: String = "",
        actions: [(Seconds, Action)] = [],
        rate: Seconds = 1/120,
        playbackRate: Double = 1,
        completion: (() -> ())? = nil
    )
    {
        self.identifier = identifier
        self.rate = rate
        self.playbackRate = playbackRate
        self.schedule = [:]
        self.completion = completion
        actions.forEach { offset, action in add(action, at: offset) }
    }
    
    // MARK: - Instance Methods
    
    /// Starts the `Timeline`.
    public func start() {
        
        if case .playing = status {
            return
        }
        
        playbackIndex = 0
        lastPausedDate = 0
        clock.start()
        timer = makeTimer()
        status = .playing
    }
    
    /// Stops the `Timeline` from executing, and is placed at the beginning.
    public func stop() {
        
        if case .stopped = status {
            return
        }
        
        lastPausedDate = 0
        timer?.stop()
        status = .stopped
    }
    
    /// Pauses the `Timeline`.
    public func pause() {

        if case .paused = status {
            return
        }
        
        lastPausedDate += clock.elapsed * playbackRate
        timer?.stop()
        status = .paused(lastPausedDate)
    }
    
    /// Resumes the `Timeline`.
    public func resume() {
        
        if case .playing = status {
            return
        }
        
        clock.start()
        timer = makeTimer()
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

        let nextFrames = frames(
            scheduledDate: nextSeconds,
            lastPausedDate: lastPausedDate,
            rate: rate,
            playbackRate: playbackRate
        )
        
        return (
            nextSeconds,
            nextFrames,
            nextActions
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
internal func frames(
    scheduledDate: Seconds,
    lastPausedDate: Seconds = 0,
    rate: Seconds,
    playbackRate: Double
) -> Frames
{

    // TODO: Prevent against division by zero!
    
    let interval = 1 / rate
    
    let timeSincePlaybackRateChange = scheduledDate - lastPausedDate
    
    guard timeSincePlaybackRateChange > 0 else {
        return 0
    }
    
    let playbackInterval = interval / playbackRate
    
    return Frames(
        round(
            lastPausedDate * interval +
            playbackInterval * timeSincePlaybackRateChange
        )
    )
}

extension Timeline: CustomStringConvertible {

    // MARK: - CustomStringConvertible
    
    /// Printed description.
    public var description: String {
        return schedule.map { "\($0)" }.joined(separator: "\n")
    }
}
