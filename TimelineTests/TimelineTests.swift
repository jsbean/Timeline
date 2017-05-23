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
    
    // TODO: Use `Timeline.Clock`
    
    // Current time in nanoseconds (convert to Double then divide by 1_000_000_000)
    var now: UInt64 {
        return DispatchTime.now().uptimeNanoseconds
    }
    
    var nowSeconds: Seconds {
        return Double(now) / 1_000_000_000
    }

    func testTimeStampToFrame() {
        
        let body: Timeline.Action.Body = { print("something") }
        let timeStamp: Seconds = 0.5
        
        let timeline = Timeline(rate: 1/60)
        timeline.add(action: body, at: timeStamp)
        
        XCTAssertEqual(timeline.schedule.count, 1)
    }
    
    func testStateAtInitStopped() {
        let timeline = Timeline()
        guard case .stopped = timeline.status else {
            XCTFail()
            return
        }
    }
    
    func testRemoveAll() {
        
        let timeline = Timeline()
        
        for offset in 0..<5 {
            timeline.add(action: { }, at: Seconds(offset))
        }
        
        XCTAssertEqual(timeline.schedule.count, 5)
        timeline.removeAll()
        XCTAssertEqual(timeline.schedule.count, 0)
    }
    
    func testFrameCalculationPlaybackRateOfOne() {
        
        let rate: Seconds = 1/120
        let scheduledDate: Seconds = 2
        let expectedFrames: Frames = 240
        
        let result = frames(
            scheduledDate: scheduledDate,
            lastPausedDate: 0,
            rate: rate,
            playbackRate: 1
        )
        
        XCTAssertEqual(expectedFrames, result)
    }
    
    func testFrameCalculationPlaybackRateChanged() {
        
        let rate: Seconds = 1/120
        
        // event scheduled at 2 seconds
        let scheduledDate: Seconds = 2
        
        // playback rate changed at 1 seconds
        let playbackRateChangedOffset: Seconds = 1
        
        // new playback rate: twice as fast
        let newPlaybackRate = 2.0
        
        let expectedFrames: Frames = 180
        
        let result = frames(
            scheduledDate: scheduledDate,
            lastPausedDate: playbackRateChangedOffset,
            rate: rate,
            playbackRate: newPlaybackRate
        )
        
        XCTAssertEqual(expectedFrames, result)
        
    }
    
    // MARK: - Playback
    
    func testStateAfterStartPlaying() {
        let timeline = Timeline()
        timeline.start()
        guard case .playing = timeline.status else {
            XCTFail()
            return
        }
        timeline.stop()
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
            timeline.add(action: increment, at: Seconds(offset))
        }
        
        // Assert that we have counted to five
        let assertion = {
            XCTAssertEqual(count, 5)
            unfulfilledExpectation.fulfill()
            timeline.stop()
        }
        
        timeline.add(action: assertion, at: 5)
        
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
        
        timeline.loop(action: increment, every: 1, offsetBy: 0)
        
        timeline.add(
            action: {
                XCTAssertEqual(count, 5)
                
                timeline.stop()
                unfulfilledExpectation.fulfill()
            },
            at: 4.1
        )
        
        timeline.start()
        waitForExpectations(timeout: 4.2)
    }
    
    func testPlaybackRateHalf() {
        
        let unfulfilledExpectation = expectation(description: "Playback rate: 0.5")
        
        let clock = Timeline.Clock()
        let timeline = Timeline { unfulfilledExpectation.fulfill() }

        for offset in 0..<5 {
            
            // actual time
            let playbackTime = Seconds(offset) * 2
            
            let assertion = {
                XCTAssertEqualWithAccuracy(clock.elapsed, playbackTime, accuracy: 0.01)
            }
            
            timeline.add(action: assertion, at: Seconds(offset))
        }
        
        timeline.playbackRate = 0.5
        timeline.start()
        clock.start()
        
        waitForExpectations(timeout: 10) { _ in
            timeline.stop()
        }
    }
    
    func testPlaybackRateTwice() {
        
        let unfulfilledExpectation = expectation(description: "Playback rate: 2")
        
        let clock = Timeline.Clock()
        let timeline = Timeline { unfulfilledExpectation.fulfill() }
        
        for offset in 0..<5 {
            
            // actual time
            let playbackTime = Seconds(offset) / 2
            
            let assertion = {
                XCTAssertEqualWithAccuracy(clock.elapsed, playbackTime, accuracy: 0.01)
            }
            
            timeline.add(action: assertion, at: Seconds(offset))
        }
        
        timeline.playbackRate = 2
        timeline.start()
        clock.start()
        
        waitForExpectations(timeout: 10) { _ in
            timeline.stop()
        }
    }
    
    func testPlaybackRateChangesMidway() {
        
        let unfulfilledExpectation = expectation(description: "Playback rate: 2")
        
        let clock = Timeline.Clock()
        let timeline = Timeline { unfulfilledExpectation.fulfill() }
        
        // change playback rate to two at one second in
        
        let oneSecond = {
            XCTAssertEqualWithAccuracy(clock.elapsed, 1, accuracy: 0.01)
            timeline.playbackRate = 2.0
        }
        
        let twoSeconds = {
            XCTAssertEqualWithAccuracy(clock.elapsed, 1.5, accuracy: 0.01)
        }
        
        timeline.add(action: oneSecond, at: 1)
        timeline.add(action: twoSeconds, at: 2)
        
        clock.start()
        timeline.start()
        
        
        waitForExpectations(timeout: 10) { _ in
            timeline.stop()
        }
    }
    
    func testPauseResume() {
        
        let unfulfilledExpectation = expectation(description: "Pause / resume")
        
        let clock = Timeline.Clock()
        
        let referenceTimeline = Timeline { unfulfilledExpectation.fulfill() }
        let realLifeTimeline = Timeline()
        
        // store events in the reference timeline at one and two seconds
        let oneSecondReference = {
            XCTAssertEqualWithAccuracy(clock.elapsed, 1, accuracy: 0.01)
        }
        
        // should happen at 3 seconds (real-life time)
        let twoSecondsReference = {
            XCTAssertEqualWithAccuracy(clock.elapsed, 3, accuracy: 0.01)
        }
        
        referenceTimeline.add(action: oneSecondReference, at: 1)
        referenceTimeline.add(action: twoSecondsReference, at: 2)
        
        // pause the reference timeline at one second
        let oneSecondRealLife = {
            print("one second IN REAL LIFE: pausing reference timeline")
            referenceTimeline.pause()
        }
        
        let twoSecondsRealLife = {
            print("two seconds in REAL LIFE: resuming reference timeline")
            referenceTimeline.resume()
        }
        
        realLifeTimeline.add(action: oneSecondRealLife, at: 1)
        realLifeTimeline.add(action: twoSecondsRealLife, at: 2)
        
        clock.start()
        referenceTimeline.start()
        realLifeTimeline.start()

        waitForExpectations(timeout: 10) { _ in
            referenceTimeline.stop()
            realLifeTimeline.stop()
        }
    }
    
    func assertAccuracyWithRepeatedPulse(interval: Seconds, for duration: Seconds) {
     
        guard duration > 0 else {
            return
        }
        
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
            
            let action = {
                
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
                    print("global error: \(globalError)")
                    
                    last = current
                }
            }
            
            timeline.add(action: action, at: offset)
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
            
            timeline.stop()
        }
        
        timeline.add(action: assertion, at: range.last!)
        
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

//    func testAccuracyWithPulseEverySecondForAMinute() {
//        assertAccuracyWithPulseEverySecond(for: 60)
//    }
//    
//    func testAccuracyWithPulseEveryThirdOfASecondForAMinute() {
//        assertAccuracyWithRepeatedPulse(interval: 1/3, for: 60)
//    }
//    
//    func testAccuracyWithPulseEveryTenthOfASecondForAMinute() {
//        assertAccuracyWithRepeatedPulse(interval: 1/10, for: 60)
//    }
//    
//    func testAccuracyWithPulseAbritraryIntervalForAMinute() {
//        assertAccuracyWithRepeatedPulse(interval: 0.123456, for: 60)
//    }
//    
//    func testAccuracyOfLongIntervalForAMinute() {
//        assertAccuracyWithRepeatedPulse(interval: 12.3456, for: 60)
//    }
//    
//    func testAccuracyWithPuleEverySecondFor30Minutes() {
//        assertAccuracyWithPulseEverySecond(for: 60)
//    }
}
