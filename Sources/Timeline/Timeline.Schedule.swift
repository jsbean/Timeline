//
//  Timeline.Schedule.swift
//  Timeline
//
//  Created by James Bean on 5/4/17.
//
//

import Foundation

extension Timeline {
    
    // MARK: - Schedule
    
    /// Adds the given `action` at the given `offset` in `Seconds`.
    public func add(action body: @escaping Action.Body, at offset: Seconds) {
        let action = Action(kind: .atomic, body: body)
        add(action, at: offset)
    }
    
    /// Adds the given `action`, to be performed every `interval`, offset by the given
    /// `offset`.
    public func loop(
        action body:  @escaping Action.Body,
        every interval: Seconds,
        offsetBy offset: Seconds = 0
    )
    {
        let action = Action(
            kind: .looping(interval: interval, status: .source),
            body: body
        )
        
        add(action, at: offset)
    }
    
    /// Adds the given `action` at the given `offset`.
    public func add(_ action: Action, at offset: Seconds) {
        action.identifierPath.append(identifier)
        schedule.safelyAppend(action, toArrayWith: offset)
    }
    
    /// Adds the contents of the given `timeline` to `schedule`.
    public func add(_ timeline: Timeline) {
        timeline.schedule.forEach { offset, actions in
            actions.forEach { action in add(action, at: offset) }
        }
    }
    
    public func add(_ timelines: Timeline...) {
        timelines.forEach(add)
    }
    
    /// Removes all of the `Actions` from the `Timeline` with the given identifiers
    ///
    /// - TODO: Refactor to `Schedule` struct
    public func removeAll(identifiers: [String] = []) {
        
        // If no identifiers are provided, clear schedule entirely
        guard !identifiers.isEmpty else {
            schedule = [:]
            return
        }
        
        // Otherwise, remove the actions with matching the given identifiers
        for (offset, actions) in schedule {
            
            // Remove the actions with identifiers that match those requested for removal
            let filtered = actions.filter { action in
                !Set(identifiers).intersection(action.identifierPath).isEmpty
            }
            
            // If no actions are left in an array, remove value at given offset
            schedule[offset] = !filtered.isEmpty ? filtered : nil
        }
    }
}
