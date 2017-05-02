//
//  TimelineTests.swift
//  Timeline
//
//  Created by James Bean on 6/23/16.
//
//

import XCTest
import Collections
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
        timeline.add(action: body, identifier: "", at: timeStamp)
        
        XCTAssertEqual(timeline.schedule.count, 1)
        //XCTAssertNotNil(timeline[Frames(30)])
    }
    
    func testStateAtInitStopped() {
        let timeline = Timeline()
        guard case .stopped = timeline.state else {
            XCTFail()
            return
        }
    }
    
    func testAddWithIdentifier() {
        let timeline = Timeline()
        timeline.add(action: { }, identifier: "id", at: 0)
        // assert something
    }
    
    func testRemoveAll() {
        
        let timeline = Timeline()
        
        for offset in 0..<5 {
            timeline.add(action: { }, identifier: "id", at: Seconds(offset))
        }
        
        XCTAssertEqual(timeline.schedule.count, 5)
        timeline.removeAll()
        XCTAssertEqual(timeline.schedule.count, 0)
    }
    
    func testRemoveAllWithIdentifiers() {
        
        let timeline = Timeline()
        
        for offset in 0..<5 {
            timeline.add(action: { }, identifier: "removed", at: Seconds(offset))
        }
        
        for offset in 5..<8 {
            timeline.add(action: { }, identifier: "kept", at: Seconds(offset))
        }
        
        XCTAssertEqual(timeline.schedule.count, 8)
        timeline.removeAll(identifiers: ["removed"])
        XCTAssertEqual(timeline.schedule.count, 3)
    }
    
    
    func testStateAfterStartPlaying() {
        let timeline = Timeline()
        timeline.start()
        guard case .playing = timeline.state else {
            XCTFail()
            return
        }
    }
    
    func testFiveEventsGetTriggered() {
        
        let unfulfilledExpectation = expectation(description: "Counter")
        
        // Gross little counter for testing
        var count = 0
        let increment = { count += 1 }
        
        // Create Timeline
        let timeline = Timeline()
        
        // Fill up Timeline
        for offset in 0..<5 {
            timeline.add(action: increment, identifier: "", at: Seconds(offset))
        }
        
        // Assert that we have counted to five
        let assertion = {
            XCTAssertEqual(count, 5)
            unfulfilledExpectation.fulfill()
        }
        
        timeline.add(action: assertion, identifier: "", at: 5)
        
        // Get things started
        timeline.start()
        
        // Make sure we don't
        waitForExpectations(timeout: 5.1)
    }
    
    func testFiveEventsGetTriggeredByLooping() {
        
        let unfulfilledExpectation = expectation(description: "Counter looping")
        
        // Gross little counter for testing
        var count = 0
        let increment = { count += 1 }
        
        // Create Timeline
        let timeline = Timeline()
        
        timeline.loop(action: increment, identifier: "increment", every: 1, offsetBy: 0)
        
        let assertion = {
            XCTAssertEqual(count, 5)
            unfulfilledExpectation.fulfill()
            timeline.stop()
        }
        
        timeline.add(action: assertion, identifier: "assertion", at: 4.1)
        
        timeline.start()
        waitForExpectations(timeout: 4.2)
    }

    
    
//    func testCurrentFrameInitZero() {
//        let timeline = Timeline()
//        XCTAssertEqual(timeline.currentFrame, 0)
//    }

//    func testIterationSorted() {
//        
//        let timeline = Timeline()
//        timeline.add(at: 3) { () }
//        timeline.add(at: 2) { () }
//        timeline.add(at: 5) { () }
//        timeline.add(at: 1) { () }
//        timeline.add(at: 4) { () }
//        
//        XCTAssertEqual(
//            timeline.map { $0.0 },
//            [1,2,3,4,5].map { Frames(Seconds($0) / timeline.rate) }
//        )
//    }
//
//    func testClear() {
//        
//        let timeline = Timeline()
//        timeline.add(at: 3) { () }
//        timeline.add(at: 2) { () }
//        timeline.clear()
//        
//        XCTAssertEqual(timeline.count, 0)
//    }
//    
//    func testStart() {
//        
//        let timeline = Timeline()
//        timeline.add(at: 3) { () }
//        timeline.add(at: 2) { () }
//        
//        XCTAssertFalse(timeline.isActive)
//
//        timeline.start()
//        
//        XCTAssert(timeline.isActive)
//    }
//
//    func testStop() {
//        
//        let timeline = Timeline()
//        timeline.add(at: 3) { () }
//        timeline.add(at: 2) { () }
//        timeline.start()
//        timeline.stop()
//        
//        XCTAssertFalse(timeline.isActive)
//        XCTAssertEqual(timeline.currentFrame, 0)
//    }
//    
//    func testSubscriptSeconds() {
//        
//        let timeline = Timeline()
//        timeline.add(at: 3) { () }
//        timeline.add(at: 2) { () }
//        timeline.add(at: 5) { () }
//        timeline.add(at: 1) { () }
//        timeline.add(at: 4) { () }
//        
//        stride(from: Seconds(1), to: 5, by: 1).forEach { timeStamp in
//            XCTAssertNotNil(timeline[timeStamp])
//        }
//    }
//    
//    // TODO: Implement: testAccuracyWithTimePoints([Seconds]) { }
//    
    func assertAccuracyWithRepeatedPulse(interval: Seconds, for duration: Seconds) {
     
        guard duration > 0 else { return }
        
        let unfulfilledExpectation = expectation(description: "Test accuracy of Timer")
        
        let range = stride(from: Seconds(0), to: duration, by: interval).map { $0 }
        
        // Data
        var globalErrors: [Double] = []
        var localErrors: [Double] = []
        
        // Create `Timeline` to test
        let timeline = Timeline(rate: 1/120)
        
        let start: UInt64 = DispatchTime.now().uptimeNanoseconds
        var last: UInt64 = DispatchTime.now().uptimeNanoseconds
        
        for (i, offset) in range.enumerated() {
            
            let action = {
                
                NSBeep()
                
                // For now, don't test an event on first hit, as the offset should be 0
                if offset > 0 {
                    
                    let current = DispatchTime.now().uptimeNanoseconds
                    
                    let actualTotalOffset = Seconds(current - start) / 1_000_000_000
                    let expectedTotalOffset = range[i]
                    
                    let actualLocalOffset = Seconds(current - last) / 1_000_000_000
                    let expectedLocalOffset: Seconds = interval
                    
                    let globalError = abs(actualTotalOffset - expectedTotalOffset)
                    let localError = abs(expectedLocalOffset - actualLocalOffset)

                    globalErrors.append(globalError)
                    localErrors.append(localError)
                    
                    print("local error: \(localError)")
                    
                    last = current
                }
            }
            
            timeline.add(action: action, identifier: "measure", at: offset)
        }
        
        // Finish up 1 second after done
        let assertion = {
            
            let maxGlobalError = globalErrors.max()!
            let averageGlobalError = globalErrors.mean!
            
            let maxLocalError = localErrors.max()!
            let averageLocalError = localErrors.mean!
            
            XCTAssertLessThan(maxGlobalError, 0.015)
            XCTAssertLessThan(averageGlobalError, 0.015)
            
            XCTAssertLessThan(maxLocalError, 0.015)
            XCTAssertLessThan(averageLocalError, 0.015)
            
            print("max global error: \(maxGlobalError); average global error: \(averageGlobalError)")
            
            print("max local error: \(maxLocalError); average local error: \(averageLocalError)")
            
            // Fulfill expecation
            unfulfilledExpectation.fulfill()
        }
        
        timeline.add(action: assertion, identifier: "assertion", at: range.last!)
        
        // Start the timeline
        timeline.start()
        
        // Ensure that test lasts for enough time
        waitForExpectations(timeout: duration + 2) { _ in }
    }
    
    func assertAccuracyWithPulseEverySecond(for duration: Seconds) {
        assertAccuracyWithRepeatedPulse(interval: 1, for: duration)
    }

    // MARK: - Short Tests
    
    func testAccuracyWithFastPulseForOneSecond() {
        assertAccuracyWithRepeatedPulse(interval: 0.1, for: 1)
    }
    
    func testAccuracyWithIrregularFastPulseForOneSecond() {
        assertAccuracyWithRepeatedPulse(interval: 0.1618, for: 1)
    }
    
    // MARK: - Medium Tests
    
    func testAccuracyWithFastPulseForFiveSeconds() {
        assertAccuracyWithRepeatedPulse(interval: 0.1, for: 5)
    }
    
    func testAccuracyWithIrregularFastPulseForFiveSeconds() {
        assertAccuracyWithRepeatedPulse(interval: 0.5, for: 5)
    }
    
    // MARK: - Long Tests

    func testAccuracyWithPulseEverySecondForAMinute() {
        assertAccuracyWithPulseEverySecond(for: 60)
    }
    
    func testAccuracyWithPulseEveryThirdOfASecondForAMinute() {
        assertAccuracyWithRepeatedPulse(interval: 1/3, for: 60)
    }
    
    func testAccuracyWithPulseEveryTenthOfASecondForAMinute() {
        assertAccuracyWithRepeatedPulse(interval: 1/10, for: 60)
    }
    
    func testAccuracyWithPulseAbritraryIntervalForAMinute() {
        assertAccuracyWithRepeatedPulse(interval: 0.123456, for: 60)
    }
    
    func testAccuracyOfLongIntervalForAMinute() {
        assertAccuracyWithRepeatedPulse(interval: 12.3456, for: 60)
    }
    
    func testAccuracyWithPuleEverySecondFor30Minutes() {
        assertAccuracyWithPulseEverySecond(for: 60)
    }
}
