//
//  Timeline.Clock.swift
//  Timeline
//
//  Created by James Bean on 5/4/17.
//
//

import Foundation

extension Timeline {
    
    // MARK: - Clock
    
    /// Measures time.
    public class Clock {
        
        /// - returns: Current offset in `Seconds`.
        private static var now: Seconds {
            return Date().timeIntervalSince1970
        }
        
        private var startTime: Seconds = Clock.now
        
        /// - returns: Time elapsed since `start()`.
        public var elapsed: Seconds {
            return Clock.now - startTime
        }
        
        /// Stores the current time for measurement.
        public func start() {
            startTime = Clock.now
        }
    }
}
