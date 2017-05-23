//
//  ScheduleTests.swift
//  Timeline
//
//  Created by James Bean on 5/3/17.
//
//

import XCTest
import Collections
@testable import Timeline

class ScheduleTests: XCTestCase {
    
    func testSchedule() {
        
        let timeline = Timeline(rate: 1/100)
        
        for offset in 0..<10 {
            timeline.add(action: { }, at: Seconds(offset))
        }
        
        let expectedSecondsOffsets: SortedArray<Seconds> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        XCTAssertEqual(timeline.schedule.keys, expectedSecondsOffsets)
    }

    func testIdentifier() {
        
        let timeline = Timeline(identifier: "ABC")
        timeline.add(action: { }, at: 0)
        
        let action = timeline.schedule.first!.1.first!
        let identifier = action.identifierPath.first!
        XCTAssertEqual(identifier, "ABC")
    }
}
