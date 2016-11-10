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

/// Time unit inverse to the `rate` of a `Timeline`.
public typealias Frames = UInt

/**
 Scheduler that performs actions at given times.
 
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
*/
public final class Timeline {
    
    // MARK: - Instance Properties
    
    /// Offset in `Seconds` of internal timer.
    internal var currentOffset: Seconds {
        return seconds(from: currentFrame)
    }
 
    // The current frame.
    internal private(set) var currentFrame: Frames = 0
    
    /// Storage of actions.
    fileprivate var registry = SortedDictionary<Frames, [ActionType]>()
    
    // Internal timer.
    private var timer: Timer!
    
    // Clock that measures how much time has passed, in ms
    // TODO: Consider encapsulating this
    private var clock = DispatchTime(uptimeNanoseconds: 0)
    
    // Start time.
    private var startTime: Seconds = 0
    
    // The amount of time in seconds that has elapsed since starting or resuming from paused.
    // TODO: Remove QuartzCore dependency if possible
    private var secondsElapsed: Seconds {
        
        // FIXME: Make converter
        return seconds(from: clock.uptimeNanoseconds) - startTime
    }

    // The inverted rate.
    private var interval: Seconds { return 1 / rate }
    
    /// - returns: `true` if the internal timer is running. Otherwise, `false`.
    public private(set) var isActive: Bool = false
    
    // How often the timer should advance.
    public let rate: Seconds
    
    // MARK: - Initializers
    
    /**
     Create a Timeline with an update rate.
     */
    public init(rate: Seconds = 1/60) {
        self.rate = rate
    }
    
    // MARK: - Instance Methods
    
    // MARK: Modifying the timeline
    
    /**
     Add a given `action` at a given `timeStamp` in seconds.
     */
    public func add(at timeStamp: Seconds, body: @escaping ActionBody) {
        let action = AtomicAction(timeStamp: timeStamp, body: body)
        add(action, at: timeStamp)
    }
    
    /**
     Add a looping action at a given `tempo`.
     */
    public func addLooping(
        at tempo: Tempo,
        offset: Seconds = 0,
        body: @escaping ActionBody
    )
    {
        let timeInterval = tempo / 60
        let action = LoopingAction(timeInterval: timeInterval, body: body)
        add(action, at: offset)
    }
    
    /**
     Add a looping action with the given `interval` between firings.
     */
    public func addLooping(
        interval: Seconds,
        offset: Seconds = 0,
        body: @escaping ActionBody
    )
    {
        let action = LoopingAction(timeInterval: interval, body: body)
        add(action, at: offset)
    }
    
    public func add(_ action: ActionType, at timeStamp: Seconds) {
        registry.safelyAppend(action, toArrayWith: frames(from: timeStamp))
    }
    
    /**
     Clear all elements from the timeline.
     */
    public func clear() {
        registry = SortedDictionary()
    }
    
    // MARK: Operating the timeline
    
    /**
     Start the timeline.
     
     - TODO: Consider moving the reinitialization of `timer` to the beginning!
     */
    public func start() {
        currentFrame = 0
        startTime = seconds(from: clock.uptimeNanoseconds)
        isActive = true
        timer = makeTimer()
    }
    
    /**
     Stop the timeline.
     */
    public func stop() {
        pause()
        currentFrame = 0
    }
    
    /**
     Pause the timeline.
     */
    public func pause() {
        timer?.invalidate()
        isActive = false
    }
    
    /**
     Resume the timeline.
     */
    public func resume() {
        if isActive { return }
        timer = makeTimer()
        isActive = true
        startTime = seconds(from: clock.uptimeNanoseconds)
    }
    
    /**
     Jump to a given offset.
     */
    public func skip(to time: Seconds) {
        pause()
        currentFrame = frames(from: time)
    }
    
    private func makeTimer() -> Timer {
        self.timer?.invalidate()
        let timer = Timer.scheduledTimer(
            timeInterval: rate,
            target: self,
            selector: #selector(advance),
            userInfo: nil,
            repeats: true
        )
        timer.fire()
        return timer
    }

    // FIXME: We are accumulating drift here by incrementing currentFrame, and not checking
    //   it against `secondsElapsed`.
    @objc internal func advance() {
        
        // TODO: Calculate offset time since start of `Timer` with `DispatchTime`,
        //  then, calculate `currentFrame` from this offset

        if let actions = registry[currentFrame] {
            
            actions.forEach {
                
                // perform function
                $0.body()
                
                // if looping action, add next action
                if let loopingAction = $0 as? LoopingAction {
                    add(loopingAction, at: secondsElapsed + loopingAction.timeInterval)
                }
            }
        }
        
        currentFrame += 1
    }
    
    internal func frames(from seconds: Seconds) -> Frames {
        return Frames(seconds * interval)
    }
    
    internal func frames(from clock: DispatchTime) -> Frames {
        return frames(from: seconds(from: clock))
    }
    
    internal func seconds(from frames: Frames) -> Seconds {
        return Seconds(frames) / interval
    }
    
    internal func seconds(from clock: DispatchTime) -> Seconds {
        return seconds(from: clock.uptimeNanoseconds)
    }
    
    internal func seconds(from nanoseconds: UInt64) -> Seconds {
        return Seconds(nanoseconds / 1_000_000_000)
    }
}

extension Timeline: Collection {
    
    /// Start index. Forwards `registry.keyStorage.startIndex`.
    public var startIndex: Int { return registry.keyStorage.startIndex }
    
    /// End index. Forwards `registry.keyStorage.endIndex`.
    public var endIndex: Int { return registry.keyStorage.endIndex }
    
    /// Next index. Forwards `registry.keyStorage.index(after:)`.
    public func index(after i: Int) -> Int {
        guard i != endIndex else { fatalError("Cannot increment endIndex") }
        return registry.keyStorage.index(after: i)
    }
    
    /**
     - returns: Value at the given `index`. Will crash if index out-of-range.
     */
    public subscript (index: Int) -> (Frames, [ActionType]) {
        
        let key = registry.keyStorage[index]
        
        guard let actions = registry[key] else {
            fatalError("Values not stored correctly")
        }
        
        return (key, actions)
    }
    
    /**
     - returns: Array of actions at the given `frames`, if present. Otherwise, `nil`.
    */
    public subscript (frames: Frames) -> [ActionType]? {
        return registry[frames]
    }
    
    /**
     - returns: Array of actions at the given `seconds`, if present. Otherwise, `nil`.
     */
    public subscript (seconds: Seconds) -> [ActionType]? {
        return registry[frames(from: seconds)]
    }
}

extension Timeline: CustomStringConvertible {
    
    public var description: String {
        return registry.map { "\($0)" }.joined(separator: "\n")
    }
}
