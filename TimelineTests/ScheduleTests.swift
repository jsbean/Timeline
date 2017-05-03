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
            timeline.add(action: { }, identifier: "", at: Seconds(offset))
        }
        
        let expectedSecondsOffsets: SortedArray<Seconds> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        XCTAssertEqual(timeline.schedule.keys, expectedSecondsOffsets)
    }
    
//    func testScheduleToPlaybackScheduleAtRateOfOne() {
//        
//        let rate: Seconds = 1/100
//        let schedule: Schedule = [
//            0: [AtomicAction(identifier: "", body: { })],
//            1: [AtomicAction(identifier: "", body: { })],
//            2: [AtomicAction(identifier: "", body: { })],
//            3: [AtomicAction(identifier: "", body: { })],
//            4: [AtomicAction(identifier: "", body: { })],
//            5: [AtomicAction(identifier: "", body: { })]
//        ]
//       
//        let expectedFramesOffsets: SortedArray<Frames> = [0, 100, 200, 300, 400, 500]
//        let result = makePlaybackSchedule(schedule: schedule, rate: rate).keys
//        XCTAssertEqual(result, expectedFramesOffsets)
//    }
//
//    func testScheduleToPlaybackScheduleRateOfHalf() {
//        
//        let playbackRate: Double = 0.5
//        let rate: Seconds = 1/100
//        
//        let schedule: Schedule = [
//            0: [AtomicAction(identifier: "", body: { })],
//            1: [AtomicAction(identifier: "", body: { })],
//            2: [AtomicAction(identifier: "", body: { })],
//            3: [AtomicAction(identifier: "", body: { })],
//            4: [AtomicAction(identifier: "", body: { })],
//            5: [AtomicAction(identifier: "", body: { })]
//        ]
//        
//        let expectedFrameOffsets: SortedArray<Frames> = [0, 200, 400, 600, 800, 1000]
//        let result = makePlaybackSchedule(schedule: schedule, rate: rate * playbackRate).keys
//        XCTAssertEqual(result, expectedFrameOffsets)
//    }
//    
//    func testScheduleToPlaybackScheduleRateOfTwo() {
//        
//        let playbackRate: Double = 2
//        let rate: Seconds = 1/100
//        
//        let schedule: Schedule = [
//            0: [AtomicAction(identifier: "", body: { })],
//            1: [AtomicAction(identifier: "", body: { })],
//            2: [AtomicAction(identifier: "", body: { })],
//            3: [AtomicAction(identifier: "", body: { })],
//            4: [AtomicAction(identifier: "", body: { })],
//            5: [AtomicAction(identifier: "", body: { })]
//        ]
//        
//        let expectedFrameOffsets: SortedArray<Frames> = [0, 50, 100, 150, 200, 250]
//        let result = makePlaybackSchedule(schedule: schedule, rate: rate * playbackRate).keys
//        XCTAssertEqual(result, expectedFrameOffsets)
//    }
}
