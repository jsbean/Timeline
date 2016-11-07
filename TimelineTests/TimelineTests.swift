//
//  TimelineTests.swift
//  Timeline
//
//  Created by James Bean on 6/23/16.
//
//

import XCTest
import DictionaryTools
@testable import Timeline

class TimelineTests: XCTestCase {

    func testTimeStampToFrame() {
        
        let body: ActionBody = { print("something") }
        let timeStamp: Seconds = 0.5
        
        let timeline = Timeline(rate: 1/60)
        timeline.add(at: timeStamp, body: body)
        
        XCTAssertEqual(timeline.count, 1)
        XCTAssertNotNil(timeline[Frames(30)])
    }
    
    func testDefaultInitAtOneOverSixty() {
        
        let body: ActionBody = { print("something") }
        let timeStamp: Seconds = 0.5
        
        let timeline = Timeline()
        timeline.add(at: timeStamp, body: body)
        
        XCTAssertEqual(timeline.count, 1)
        XCTAssertNotNil(timeline[Frames(30)])
    }
    
    func testMetronomeInjection() {
        
        let timeline = Timeline()
        stride(from: Seconds(0), to: 10, by: 0.25).forEach { timeline.add(at: $0) { () } }
        
        XCTAssertEqual(timeline.count, 40)
    }
    
    func testCurrentFrameInitZero() {
        let timeline = Timeline()
        XCTAssertEqual(timeline.currentFrame, 0)
    }
    
    func testCurrentOffset() {
        
        let timeline = Timeline()
        timeline.skip(to: 40)
        
        XCTAssertEqual(timeline.currentOffset, 40)
    }
    
    func testNext() {
        
        let timeline = Timeline()
        timeline.add(at: 1) { () }
        
        XCTAssertNotNil(timeline.next())
        XCTAssertEqual(timeline.next()!.0, 60)
        XCTAssertEqual(timeline.offsetOfNext, 1)
    }
    
    func testSkip() {
        
        let timeline = Timeline()
        stride(from: Seconds(0), to: 10, by: 1.0).forEach { timeline.add(at: $0) { () } }
        timeline.skip(to: 4.5)
        
        XCTAssertEqual(timeline.next()!.0, 5 * 60)
        XCTAssertEqual(timeline.secondsUntilNext, 0.5)
    }
    
    func testAdvancePauseAdvance() {
        
        let timeline = Timeline()
        
        (0..<100).forEach { _ in timeline.advance() }
        timeline.pause()
        XCTAssertEqual(timeline.currentFrame, 100)
        
        timeline.skip(to: 1)
        XCTAssertEqual(timeline.currentFrame, 60)
        
        timeline.resume()
        XCTAssertEqual(timeline.currentFrame, 60)
        
        (0..<100).forEach { _ in timeline.advance() }
        XCTAssertEqual(timeline.currentFrame, 160)
    }
    
    func testIterationSorted() {
        
        let timeline = Timeline()
        timeline.add(at: 3) { () }
        timeline.add(at: 2) { () }
        timeline.add(at: 5) { () }
        timeline.add(at: 1) { () }
        timeline.add(at: 4) { () }
        
        XCTAssertEqual(
            timeline.map { $0.0 },
            [1,2,3,4,5].map { Frames(Seconds($0) / timeline.rate) }
        )
    }
    
    func testClear() {
        
        let timeline = Timeline()
        timeline.add(at: 3) { () }
        timeline.add(at: 2) { () }
        timeline.clear()
        
        XCTAssertEqual(timeline.count, 0)
    }
    
    func testStart() {
        
        let timeline = Timeline()
        timeline.add(at: 3) { () }
        timeline.add(at: 2) { () }
        
        XCTAssertFalse(timeline.isActive)

        timeline.start()
        XCTAssertEqual(timeline.currentFrame, 0)
        
        XCTAssert(timeline.isActive)
    }
    
    func testStop() {
        
        let timeline = Timeline()
        timeline.add(at: 3) { () }
        timeline.add(at: 2) { () }
        timeline.start()
        timeline.stop()
        
        XCTAssertFalse(timeline.isActive)
        XCTAssertEqual(timeline.currentFrame, 0)
    }
    
    func testSubscriptSeconds() {
        
        let timeline = Timeline()
        timeline.add(at: 3) { () }
        timeline.add(at: 2) { () }
        timeline.add(at: 5) { () }
        timeline.add(at: 1) { () }
        timeline.add(at: 4) { () }
        
        stride(from: Seconds(1), to: 5, by: 1).forEach { timeStamp in
            XCTAssertNotNil(timeline[timeStamp])
        }
    }
}
