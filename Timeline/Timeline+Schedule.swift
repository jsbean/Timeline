//
//  Timeline+Schedule.swift
//  Timeline
//
//  Created by James Bean on 5/4/17.
//
//

import Foundation

extension Timeline {
    
    // MARK: - Schedule
    
    /// Adds the given `action` at the given `offset` in `Seconds`.
    public func add(
        action body: @escaping Action.Body,
        identifier: String,
        at offset: Seconds
    )
    {
        let action = Action(kind: .atomic, identifier: identifier, body: body)
        add(action, at: offset)
    }
    
    /// Adds the given `action`, to be performed every `interval`, offset by the given
    /// `offset`.
    public func loop(
        action body:  @escaping Action.Body,
        identifier: String,
        every interval: Seconds,
        offsetBy offset: Seconds = 0
    )
    {
        let action = Action(
            kind: .looping(interval: interval, status: .source),
            identifier: identifier,
            body: body
        )
        
        add(action, at: offset)
    }
    
    /// Adds the given `action` at the given `offset`.
    public func add(_ action: Action, at offset: Seconds) {
        schedule.safelyAppend(action, toArrayWith: offset)
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
                !identifiers.contains(action.identifier)
            }
            
            // If no actions are left in an array, remove value at given offset
            schedule[offset] = !filtered.isEmpty ? filtered : nil
        }
    }
}
