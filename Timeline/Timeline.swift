//
//  Timer.swift
//  Timer
//
//  Created by James Bean on 5/15/16.
//
//

import QuartzCore
import DictionaryTools

// TODO: inject Duration framework
public typealias Seconds = Double

public typealias Action = () -> ()

public final class Timeline {
    
    private var registry: [UInt: [Action]] = [:]
    private var frameSize: UInt = 60
    private var startTime: Seconds = 0
    
    private lazy var displayLink: CADisplayLink = {
        CADisplayLink(target: self, selector: #selector(advance))
    }()
    
    public init() { }
    
    public func add(at timeStamp: Seconds, action: Action) {
        let quantizedTimeStamp = UInt(round(Double(frameSize) * timeStamp))
        registry.safelyAppend(action, toArrayWithKey: quantizedTimeStamp)
    }
    
    public func clear() {
        registry = [:]
    }
    
    public func start() {
        for el in registry {
            print(el)
        }
        startTime = CACurrentMediaTime()
        displayLink.frameInterval = 1
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    public func pause() {
        displayLink.paused = true
        startTime = CACurrentMediaTime()
    }
    
    public func stop() {
        displayLink.invalidate()
    }
    
    @objc private func advance() {
        let framesElapsed = UInt(round((CACurrentMediaTime() - startTime) * Double(frameSize)))
        if let actions = registry[framesElapsed] {
            actions.forEach { $0() }
        }
    }
}
