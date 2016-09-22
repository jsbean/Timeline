//
//  ActionType.swift
//  Timeline
//
//  Created by James Bean on 6/28/16.
//
//

import Foundation

public protocol ActionType {
    
    var function: () -> () { get }
}

public struct AtomicAction: ActionType {
    
    public let timeStamp: Seconds
    public let function: () -> ()

    public init(timeStamp: Seconds, function: @escaping () -> ()) {
        self.timeStamp = timeStamp
        self.function = function
    }
}

public struct LoopingAction: ActionType {
    
    public let timeInterval: Seconds
    public let function: () -> ()
    
    public init(timeInterval: Seconds, function: @escaping () -> ()) {
        self.timeInterval = timeInterval
        self.function = function
    }
}
