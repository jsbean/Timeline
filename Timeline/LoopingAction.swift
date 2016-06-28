//
//  LoopingAction.swift
//  Timeline
//
//  Created by James Bean on 6/28/16.
//
//

import Foundation

public struct LoopingAction {
    
    public var timeInterval: Seconds
    public var action: Action
    
    public init(timeInterval: Seconds, action: Action) {
        self.timeInterval = timeInterval
        self.action = action
    }
}
