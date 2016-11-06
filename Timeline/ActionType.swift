//
//  ActionType.swift
//  Timeline
//
//  Created by James Bean on 6/28/16.
//
//

/// Function to be performed by a `Timeline`.
public typealias ActionBody = () -> ()

/**
 Protocol defining structures of timed, performable events.
 */
public protocol ActionType {
   
    /// The function to be performed at a given time.
    var body: ActionBody { get }
}

/**
 An event that occurs only once at a specific offset from the beginning of a timeline.
 */
public struct AtomicAction: ActionType {
    
    /// The offset from the beginning of a timeline when the body shall be performed.
    public let timeStamp: Seconds
    
    /// The function to be performed when called.
    public let body: ActionBody

    /**
     Create an `AtomicAction`.
     */
    public init(timeStamp: Seconds, body: @escaping () -> ()) {
        self.timeStamp = timeStamp
        self.body = body
    }
}

/*
 An event that repeats at a given interval of time.
 */
public struct LoopingAction: ActionType {
    
    /// The interval between the calls of the body.
    public let timeInterval: Seconds
    
    /// The function to be performed when called.
    public let body: ActionBody
    
    /**
     Create a `LoopingAction`.
     */
    public init(timeInterval: Seconds, body: @escaping () -> ()) {
        self.timeInterval = timeInterval
        self.body = body
    }
}
