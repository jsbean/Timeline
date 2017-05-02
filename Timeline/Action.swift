////
////  Action.swift
////  Timeline
////
////  Created by James Bean on 6/28/16.
////
////

import Foundation

/// Closure performed by `Timeline` at a given time.
public typealias ActionBody = () -> ()

/// Interface for actions which can be performed by a `Timeline`.
public protocol Action: class {
    
    // MARK: - Instance Properties
    
    /// Identifiers of an `Action`.
    var identifier: String { get }
    
    /// The closure to be performed by the `Timeline`.
    var body: ActionBody { get }
}

/// Wrapper for a single, non-looping closure.
public class AtomicAction: Action {
    
    // MARK: - Instance Properties
    
    /// Identifiers of an `Action`.
    public let identifier: String
    
    /// The closure to be performed by the `Timeline`.
    public let body: ActionBody
    
    // MARK: - Initializers
    
    /// Creates an `AtomicAction` with the given `identifiers` for performing the given `body`.
    public init(identifier: String, body: @escaping ActionBody) {
        self.identifier = identifier
        self.body = body
    }
}

/// Wrapper for a looping-closure, to be performed at the given `interval`.
public class LoopingAction: Action {
    
    // MARK: - Instance Properties
    
    /// Identifiers of an `Action`.
    public let identifier: String
    
    /// The closure to be performed by the `Timeline`.
    public let body: ActionBody
    
    /// The interval at which the closure shall be performed by the `Timeline`.
    public let interval: Seconds
    
    // MARK: - Initializers
    
    /// Creates a `LoopingAction` with the given `identifiers` for performing the given `body`
    /// at the given `interval`.
    public init(identifier: String, interval: Seconds, body: @escaping ActionBody) {
        self.identifier = identifier
        self.interval = interval
        self.body = body
    }
}
