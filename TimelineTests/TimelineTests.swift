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
        let timeline = Timeline(rate: 1/60)
        let body: ActionBody = { print("something") }
        let timeStamp: Seconds = 0.5
        timeline.add(at: timeStamp, body: body)
        XCTAssert(timeline.registry.count == 1)
        XCTAssert(timeline.registry[UInt(30)] != nil)
    }
    
    func testDefaultInitAtOneOverSixty() {
        let timeline = Timeline()
        let body: ActionBody = { print("something") }
        let timeStamp: Seconds = 0.5
        timeline.add(at: timeStamp, body: body)
        XCTAssert(timeline.registry.count == 1)
        print(timeline.registry)
        XCTAssert(timeline.registry[UInt(30)] != nil)
    }
    
    func testMetronomeInjection() {
        let timeline = Timeline()
        stride(from: Seconds(0), to: 10, by: 0.25).forEach { timeline.add(at: $0) { () } }
        XCTAssert(timeline.registry.count == 40)
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
        stride(from: Seconds(0), to: 10, by: 1.0).forEach {
            timeline.add(at: $0) { () }
        }
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
    
    func testSorted() {
        let timeline = Timeline()
        timeline.add(at: 3) { () }
        timeline.add(at: 2) { () }
        timeline.add(at: 5) { () }
        timeline.add(at: 1) { () }
        timeline.add(at: 4) { () }
        print(timeline)
    }
}
