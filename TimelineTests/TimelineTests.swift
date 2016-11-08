//
//  TimelineTests.swift
//  Timeline
//
//  Created by James Bean on 6/23/16.
//
//

import XCTest
import DictionaryTools
import ArithmeticTools
@testable import Timeline

class TimelineTests: XCTestCase {
    
    // Current time in nanoseconds (convert to Double then divide by 1_000_000_000)
    var now: UInt64 {
        return DispatchTime.now().uptimeNanoseconds
    }
    
    var nowSeconds: Seconds {
        return Double(now) / 1_000_000_000
    }

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
        XCTAssertEqual(timeline.currentFrame, 61)
        
        (0..<100).forEach { _ in timeline.advance() }
        XCTAssertEqual(timeline.currentFrame, 161)
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
        XCTAssertEqual(timeline.currentFrame, 1)
        
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
    
    func assertAccuracyWithRepeatedPulse(interval: Seconds, for duration: Seconds) {
     
        guard duration > 0 else { return }
        
        let unfulfilledExpectation = expectation(description: "Test accuracy of Timer")
        
        let range = stride(from: Seconds(0), to: duration, by: interval).map { $0 }
        
        // Data
        var globalErrors: [Double] = []
        var localErrors: [Double] = []
        
        // Create `Timeline` to test
        let timeline = Timeline()
        
        let start: UInt64 = DispatchTime.now().uptimeNanoseconds
        var last: UInt64 = DispatchTime.now().uptimeNanoseconds
        
        for (i, offset) in range.enumerated() {
            
            timeline.add(at: offset) {
                
                // For now, don't test an event on first hit, as the offset should be 0
                if offset > 0 {
                    
                    let current = DispatchTime.now().uptimeNanoseconds
                    
                    let actualTotalOffset = Seconds(current - start) / 1_000_000_000
                    let expectedTotalOffset = range[i]
                    
                    let actualLocalOffset = Seconds(current - last) / 1_000_000_000
                    let expectedLocalOffset: Seconds = 1
                    
                    let globalError = abs(actualTotalOffset - expectedTotalOffset)
                    let localError = abs(expectedLocalOffset - actualLocalOffset)
                    
                    print("Offset: \(offset)")
                    print("- error from start: \(globalError)")
                    print("- error since last: \(localError)")
                    
                    globalErrors.append(globalError)
                    localErrors.append(localError)
                    
                    last = current
                }
            }
        }
        
        // Finish up 1 second after done
        timeline.add(at: range.last! + 1) {
            
            let maxGlobalError = globalErrors.max()!
            let averageGlobalError = globalErrors.mean!
            
            let maxLocalError = localErrors.max()!
            let averageLocalError = localErrors.mean!
            
            XCTAssertLessThan(maxGlobalError, 0.015)
            XCTAssertLessThan(averageGlobalError, 0.015)
            
            XCTAssertLessThan(maxLocalError, 0.015)
            XCTAssertLessThan(averageLocalError, 0.015)
            
            print("Timing error after: \(duration) seconds:")
            print("- maximum global error: \(maxGlobalError)")
            print("- average global error: \(averageGlobalError)")
            print("- maximum local error: \(maxLocalError)")
            print("- average local error: \(averageLocalError)")
            
            // Fulfill expecation
            unfulfilledExpectation.fulfill()
        }
        
        // Start the timeline
        timeline.start()
        
        // Ensure that test lasts for enough time
        waitForExpectations(timeout: duration + 2) { _ in }
    }
    
    func assertAccuracyWithPulseEverySecond(for duration: Seconds) {
        assertAccuracyWithRepeatedPulse(interval: 1, for: 60)
    }
    
    // TODO: Implement: testAccuracyWithTimePoints([Seconds]) { }
    
    func testAccuracyWithPulseEverySecondForAMinute() {
        assertAccuracyWithPulseEverySecond(for: 60)
    }
}
