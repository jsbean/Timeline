//
//  TimelineTests.swift
//  Timeline
//
//  Created by James Bean on 6/23/16.
//
//

import XCTest
@testable import Timeline

class TimelineTests: XCTestCase {

    func testTimeStampToFrame() {
        let timeline = Timeline(rate: 60)
        let action: () -> () = { print("something") }
        let timeStamp: Seconds = 0.5
        timeline.add(at: timeStamp, action: action)
        XCTAssert(timeline.registry.count == 1)
        XCTAssert(timeline.registry[30] != nil)
    }
}
