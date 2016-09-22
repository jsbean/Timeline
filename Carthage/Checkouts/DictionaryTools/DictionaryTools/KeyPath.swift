//
//  KeyPath.swift
//  DictionaryTools
//
//  Created by James Bean on 2/22/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

/**
 Utility for retrieving values for arbitrarily deep, `String`-keyed `Dictionaries`
 
 - TODO: Make Generic, with typealias Key: Hashable
 */
open class KeyPath {
    
    // MARK: - Instance Variables
    
    /**
     Keys of `KeyPath`
     
     - note: Investigate making this `private`, or at least `internal`
     */
    fileprivate var keys: [String] = []

    /// Amount of keys in `KeyPath`.
    open var count: Int { return keys.count }
    
    // MARK: - Initializers
    
    /**
     Create a `KeyPath` with an `Array` of keys.
    
     - parameter keys: `Array` of `String` values
     
     - returns: Initialized `KeyPath`
     */
    public init(_ keys: [String]) {
        self.keys = keys
    }
    
    /**
     Create a `KeyPath` with a dot-separated `String` in the form `key.subkey.subsubkey`.
     
     >`"root.child.grandchild" -> KeyPath.keys = ["root", "child", "grandchild"]`
     
     - note: Consider making failable if string is invalid.
     
     - parameter string: Dot-separated `String`
     
     - returns: Initialized `KeyPath`
     */
    public init(_ string: String) {
        self.keys = string.characters.split { $0 == "." }.map(String.init)
    }
    
    // MARK: - Subscript
    
    /**
    Get key at `index`.
    
    - parameter index: Index of desired key.
    
    - returns: Key at given index, if available. Otherwise `nil`.
    */
    open subscript(index: Int) -> String? {
        guard index >= 0 && index < keys.count else { return nil }
        return keys[index]
    }
}

extension KeyPath: Equatable { }

public func == (lhs: KeyPath, rhs: KeyPath) -> Bool {
    return lhs.keys == rhs.keys
}

extension KeyPath: CustomStringConvertible {
    
    public var description: String {
        var result = "Path: "
        for (k, key) in keys.enumerated() {
            if k > 0 { result += " -> " }
            result += key
        }
        return result
    }
}
