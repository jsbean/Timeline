//
//  Timeline+Timer.swift
//  Timeline
//
//  Created by James Bean on 5/4/17.
//
//

import Foundation

extension Timeline {

    /// Executes a closure at rapid intervals.
    ///
    /// - note: Wraps `DispatchSourceTimer` for OSX 10.12+ / iOS 10+, and `Timer` for earlier
    /// operating sytems.
    ///
    public class Timer {
        
        /// For OSX 10.12+ / iOS 10+, this will be a `DispatchSourceTimer`. For earlier
        /// operating systems, this will be a `Foundation.Timer`.
        var timer: AnyObject?
        
        /// The closure to be performed repeatedly.
        let closure: () -> ()
        
        /// Creates a `Timer` which performs the given `closure` and the given `interval`.
        init(interval: Seconds, performing closure: @escaping () -> ()) {
            self.closure = closure
        }
        
        /// Starts the `Timer`.
        func start() {
            
            if #available(OSX 10.12, iOS 10, *) {
                
                let queue = DispatchQueue(
                    label: "com.bean.timer",
                    qos: .userInteractive,
                    attributes: .concurrent
                )
                
                let timer = DispatchSource.makeTimerSource(queue: queue)
                timer.setEventHandler(handler: self.closure)
                timer.scheduleRepeating(deadline: .now(), interval: .milliseconds(4))
                timer.resume()
                self.timer = timer
                
            } else {
                
                // Create a `Timer` that will call the `advance` method at the given `rate`
                let timer = Foundation.Timer.scheduledTimer(
                    timeInterval: 1/120,
                    target: self,
                    selector: #selector(performClosure),
                    userInfo: nil,
                    repeats: true
                )
                timer.fire()
                self.timer = timer
            }
        }
        
        /// Stops the `Timer`.
        func stop() {

            if #available(OSX 10.12, iOS 10, *) {
                (timer as? DispatchSourceTimer)?.cancel()
            } else {
                (timer as? Foundation.Timer)?.invalidate()
            }
        }

        /// Wrapper for the `Foundation.Timer` implementation.
        @objc func performClosure() {
            closure()
        }
    }
}
