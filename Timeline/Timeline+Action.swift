////
////  Timeline+Action.swift
////  Timeline
////
////  Created by James Bean on 6/28/16.
////
////

extension Timeline {
    
    // MARK: - Action

    /// Wrapper for closure to be executed by the `Timeline`.
    public final class Action {
        
        // MARK: - Associated Types
        
        /// Closure to be executed.
        public typealias Body = () -> ()
        
        // MARK: - Nested Types
        
        /// Status of a looping action.
        public enum LoopingStatus {
            
            /// The first occurrence of a looping action.
            case source
            
            /// The second or later occurrence of a looping action.
            case echo
        }
        
        /// Kind of an `Action`.
        public enum Kind {
            
            /// An `Action` to be performed once.
            case atomic
            
            /// An `Action` to be repeated at the given interval.
            case looping(interval: Seconds, status: LoopingStatus)
        }
        
        // MARK: - Instance Properties
        
        /// - returns: An echo of a looping action.
        ///
        /// - warning: Only applicable for looping actions.
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
        
        /// Kind of `Action`.
        public let kind: Kind
        
        /// Identifier.
        public let identifier: String
        
        /// Closure to be performed.
        public let body: Body
        
        // MARK: - Initializers
        
        /// Creates an `Action` with the given `kind`, `identifier` and `body` to be performed.
        public init(kind: Kind, identifier: String = "", body: @escaping Body) {
            self.kind = kind
            self.identifier = identifier
            self.body = body
        }
    }
}
