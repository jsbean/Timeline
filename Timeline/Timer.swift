//
//  Timer.swift
//  Timeline
//
//  Created by James Bean on 5/4/17.
//
//

import Foundation

extension Timeline {

    /// Wraps `DispatchSourceTimer` for OSX 10.12+ / iOS 10+, and `Timer` for others.
    public class Timer {
        
        lazy var timer: AnyObject? = {
            
            if #available(OSX 10.12, iOS 10, *) {
                
                let queue = DispatchQueue(
                    label: "com.bean.timer",
                    qos: .userInteractive,
                    attributes: .concurrent
                )
                
                let timer = DispatchSource.makeTimerSource(queue: queue)
                timer.setEventHandler(handler: self.closure)
                timer.scheduleRepeating(
                    deadline: .now(),
                    interval: DispatchTimeInterval.milliseconds(4)
                )
                
                return timer
                
            } else {
                
                // Create a `Timer` that will call the `advance` method at the given `rate`
                return Foundation.Timer.scheduledTimer(
                    timeInterval: 0.004,
                    target: self,
                    selector: #selector(advance),
                    userInfo: nil,
                    repeats: true
                )
            }
        }()
        
        /// The closure to be performed repeatedly.
        let closure: () -> ()
        
        /// Creates a `Timer` which performs the given `closure` and the given `interval`.
        init(interval: Seconds, performing closure: @escaping () -> ()) {
            self.closure = closure
        }
        
        /// Starts the `Timer`.
        func start() {
            
            if #available(OSX 10.12, iOS 10, *) {
                (timer as! DispatchSourceTimer).resume()
            } else {
                fatalError()
            }
        }
        
        /// Stops the `Timer`.
        func stop() {
            
            if #available(OSX 10.12, iOS 10, *) {
                (timer as! DispatchSourceTimer).cancel()
            } else {
                fatalError()
            }
        }

        /// Wrapper for the `Foundation.Timer` implementation.
        @objc func performClosure() {
            closure()
        }
    }
}
