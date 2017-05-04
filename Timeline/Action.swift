////
////  Action.swift
////  Timeline
////
////  Created by James Bean on 6/28/16.
////
////

import Foundation

public final class Action {
    
    public typealias Body = () -> ()
    
    public enum LoopingStatus {
        case source
        case echo
    }
    
    public enum Kind {
        case atomic
        case looping(interval: Seconds, status: LoopingStatus)
    }
    
    public var echo: Action {
        
        guard case let .looping(interval, _) = kind else {
            fatalError("Can only create an echo of a looping Action")
        }
        
        return Action(
            kind: .looping(interval: interval, status: .echo),
            identifier: identifier,
            body: body
        )
    }
    
    public let kind: Kind
    public let identifier: String
    public let body: Body
    
    public init(kind: Kind, identifier: String = "", body: @escaping Body) {
        self.kind = kind
        self.identifier = identifier
        self.body = body
    }
}

//public class Action {
//    
//    public typealias Body = () -> ()
//    
//    public let identifier: String
//    public let body: Body
//    
//    public init(identifier: String = "", body: @escaping Body) {
//        self.identifier = identifier
//        self.body = body
//    }
//}
//
//public class LoopingAction: Action {
//    
//    public enum Kind {
//        case origin
//        case source
//    }
//    
//    public let interval: Seconds
//    
//    public init(identifier: String = "", body: @escaping Body, interval: Seconds) {
//        self.interval = interval
//        super.init(identifier: identifier, body: body)
//    }
//}



//
//
///// Closure performed by `Timeline` at a given time.
//public typealias ActionBody = () -> ()
//
///// Interface for actions which can be performed by a `Timeline`.
//public protocol Action: class {
//    
//    // MARK: - Instance Properties
//    
//    /// Identifiers of an `Action`.
//    var identifier: String { get }
//    
//    /// The closure to be performed by the `Timeline`.
//    var body: ActionBody { get }
//}
//
///// Wrapper for a single, non-looping closure.
//public class AtomicAction: Action {
//    
//    // MARK: - Instance Properties
//    
//    /// Identifiers of an `Action`.
//    public let identifier: String
//    
//    /// The closure to be performed by the `Timeline`.
//    public let body: ActionBody
//    
//    // MARK: - Initializers
//    
//    /// Creates an `AtomicAction` with the given `identifiers` for performing the given `body`.
//    public init(identifier: String, body: @escaping ActionBody) {
//        self.identifier = identifier
//        self.body = body
//    }
//}
//
//public protocol LoopingAction: Action {
//    
//    var interval: Seconds { get }
//}
//
///// Wrapper for a looping-closure, to be performed at the given `interval`.
//public class LoopingActionSource: Action {
//    
//    // MARK: - Instance Properties
//    
//    /// Identifiers of an `Action`.
//    public let identifier: String
//    
//    /// The closure to be performed by the `Timeline`.
//    public let body: ActionBody
//    
//    /// The interval at which the closure shall be performed by the `Timeline`.
//    public let interval: Seconds
//    
//    // MARK: - Initializers
//    
//    /// Creates a `LoopingAction` with the given `identifiers` for performing the given `body`
//    /// at the given `interval`.
//    public init(identifier: String, interval: Seconds, body: @escaping ActionBody) {
//        self.identifier = identifier
//        self.interval = interval
//        self.body = body
//    }
//}
//
//public class LoopingActionEcho: Action {
//    
//    // MARK: - Instance Properties
//    
//    /// Identifiers of an `Action`.
//    public let identifier: String
//    
//    /// The closure to be performed by the `Timeline`.
//    public let body: ActionBody
//    
//    /// The interval at which the closure shall be performed by the `Timeline`.
//    public let interval: Seconds
//    
//    // MARK: - Initializers
//    
//    /// Creates a `LoopingAction` with the given `identifiers` for performing the given `body`
//    /// at the given `interval`.
//    public init(identifier: String, interval: Seconds, body: @escaping ActionBody) {
//        self.identifier = identifier
//        self.interval = interval
//        self.body = body
//    }
//    
//    public init(source: LoopingActionSource) {
//        self.identifier = source.identifier
//        self.interval = source.interval
//        self.body = source.body
//        
//    }
//}
