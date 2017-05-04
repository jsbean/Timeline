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
        
        let timer: AnyObject
        
        init(interval: Seconds, performing closure: @escaping () -> ()) {
            
            if #available(OSX 10.12, iOS 10, *) {
                
                let queue = DispatchQueue(
                    label: "com.bean.timer",
                    qos: .userInteractive,
                    attributes: .concurrent
                )
                
                let timer = DispatchSource.makeTimerSource(queue: queue)
                timer.setEventHandler(handler: closure)
                timer.scheduleRepeating(
                    deadline: .now(),
                    interval: DispatchTimeInterval.milliseconds(4)
                )
                
                self.timer = timer
                
            } else {
                fatalError()
            }
        }
        
        func start() {
            
            if #available(OSX 10.12, iOS 10, *) {
                (timer as! DispatchSourceTimer).resume()
            } else {
                fatalError()
            }
        }
        
        func stop() {
            
            if #available(OSX 10.12, iOS 10, *) {
                (timer as! DispatchSourceTimer).cancel()
            } else {
                fatalError()
            }
        }
    }
}
