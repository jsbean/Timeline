//
//  TimelineProtocol.swift
//  Timeline
//
//  Created by James Bean on 5/1/17.
//
//

import Collections

//public protocol ScheduleProtocol {
//    subscript (offset: Int) -> Action? { get }
//}
//
//public protocol TimerProtocol {
//
//}
//
//public protocol ClockProtocol {
//    
//}

public enum TimelineStatus {
    case stopped
    case playing
    case paused(Frames)
}

/// Interface for `Timeline` types.
///
/// Objects that conform to the `Timeline` provide a means for storing and executing closures 
/// at given offset times.
///
public protocol TimelineProtocol: class {
    
    // MARK: Building the `Timeline`.
    
    /// Schedule that store actions to be performed by their offset time.
    //var schedule: [Frames: [Action]] { get set }
    var schedule: SortedDictionary<Seconds, [Action]> { get set }
    
    /// Adds the given `action` at the given `offset` in `Seconds`.
    func add(action: @escaping Action.Body, identifier: String, at offset: Seconds)
    
    /// Adds the given `action`, to be performed every `interval`, offset by the given
    /// `offset`.
    func loop(
        action: @escaping Action.Body,
        identifier: String,
        every interval: Seconds,
        offsetBy offset: Seconds
    )
    
    /// Removes all of the `Actions` from the `Timeline` with the given identifiers
    func removeAll(identifiers: [String])
    
    // MARK: Operating the `Timeline`.
    
    /// The current status of the `Timeline`.
    var status: TimelineStatus { get }
    
    /// The rate at which the `Timeline` is played-back. Defaults to `1`.
    var playbackRate: Double { get set }
    
    /// Starts the `Timeline`.
    func start()
    
    /// Stops the `Timeline` from executing, and is placed at the beginning.
    func stop()
    
    /// Pauses the `Timeline`.
    func pause()
    
    /// Resumes the `Timeline`.
    func resume()
    
    /// Skips the given `time` in `Seconds`.
    func skip(to time: Seconds)
}
