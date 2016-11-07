//
//  ActionTypeTests.swift
//  Timeline
//
//  Created by James Bean on 11/6/16.
//
//

import XCTest
import Timeline

class ActionTypeTests: XCTestCase {
    
    func testAtomicActionInit() {
        
        let timeStamp: Seconds = 0.5
        let body: ActionBody = { () }
        
        let _ = AtomicAction(timeStamp: timeStamp, body: body)
    }
    
    func testLoopingActionInit() {
        
        let timeInterval: Seconds = 0.5
        let body: ActionBody = { () }
        
        let _ = LoopingAction(timeInterval: timeInterval, body: body)
    }
}
