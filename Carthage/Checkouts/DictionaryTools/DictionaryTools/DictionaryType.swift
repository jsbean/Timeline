//
//  DictionaryType.swift
//  DictionaryTools
//
//  Created by James Bean on 6/26/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import Foundation

extension Dictionary: DictionaryType {
    
    // MARK: - `DictionaryType`
}

/**
 Interface for Dictionary-like structures.
 */
public protocol DictionaryType: Collection {
    
    // MARK: - Associated Types
    
    /**
     Key type.
     */
    associatedtype Key: Hashable
    
    /**
     Value type.
     */
    associatedtype Value
    
    // MARK: - Initializers
    
    /**
     Create an empty `DictionaryType` value.
     */
    init()
    
    // MARK: - Subscripts
    
    /**
     - returns: `Value` for the given `key`, if present. Otherwise, `nil`.
     */
    subscript (key: Key) -> Value? { get set }
}

extension DictionaryType {
    
    /// Create a `DictionaryType` with two parallel arrays.
    ///
    /// - Note: Usefule for creating a dataset from x- and y-value arrays.
    public init(_ xs: [Key], _ ys: [Value]) {
        self.init()
        zip(xs, ys).forEach { key,value in self[key] = value }
    }
}

extension DictionaryType where Iterator.Element == (key: Key, value: Value) {
    
    // MARK: - Instance Methods

    // TODO: Implement `merged(with:)`
    
    /**
     Merge the contents of the given `dictionary` destructively into this one.
     
     - warning: The value of a given key of the given `dictionary` will override that of this
     one.
     */
    public mutating func merge(with dictionary: Self) {
        for (k,v) in dictionary { self[k] = v }
    }
}

extension DictionaryType where Value: ArrayType {
    
    /**
     Ensure that an Array-type value exists for the given `key`.
     */
    public mutating func ensureValue(for key: Key) {
        if self[key] == nil {
            self[key] = Value()
        }
    }
    
    /**
     Safely append the given `value` to the Array-type `value` for the given `key`.
     */
    public mutating func safelyAppend(_ value: Value.Element, toArrayWith key: Key) {
        ensureValue(for: key)
        self[key]!.append(value)
    }
    
    /**
     Safely append the contents of an array to the Array-type `value` for the given `key`.
     */
    public mutating func safelyAppendContents(of values: Value, toArrayWith key: Key) {
        ensureValue(for: key)
        self[key]!.append(contentsOf: values)
    }
    
    // TODO: Implement `merge` and `merged`
}

extension DictionaryType where Value: ArrayType, Value.Element: Equatable {
    
    /**
     Safely append value to the array value for a given key. 
     
     If this value already exists in desired array, the new value will not be added.
     */
    public mutating func safelyAndUniquelyAppend(_ value: Value.Element, toArrayWith key: Key) {
        
        ensureValue(for: key)
        
        // FIXME: Find a way to not cast to Array!
        if (self[key] as! Array).contains(value) { return }
        
        self[key]!.append(value)
    }
}

extension DictionaryType where
    Value: DictionaryType,
    Value.Key: Hashable
{
    
    /**
     Ensure there is a value for a given `key`.
     */
    public mutating func ensureValue(for key: Key) {
        if self[key] == nil {
            self[key] = Value()
        }
    }
    
    /**
     Update the `value` for the given `keyPath`.
     
     - TODO: Use subscript (keyPath: KeyPath) { get set }
     */
    public mutating func update(_ value: Value.Value, keyPath: KeyPath) {
        
        guard
            let key = keyPath[0] as? Key,
            let subKey = keyPath[1] as? Value.Key
        else { return }
        
        self.ensureValue(for: key)
        self[key]?[subKey] = value
    }
}

/*
extension DictionaryType where
    Value: DictionaryType,
    Iterator.Element == (Key, Value),
    Value.Iterator.Element == (Value.Key, Value.Value)
{
    
    // TODO: Implement `merged(with:)`
    
    /**
     Merge the contents of the given `dictionary` destructively into this one.
     
     - warning: The value of a given key of the given `dictionary` will override that of this
     one.
     */
    public mutating func merge(with dictionary: Self) {
        for (key, subDict) in dictionary {
            ensureValue(for: key)
            for (subKey, value) in subDict {
                self[key]![subKey] = value
            }
        }
    }
}
*/

extension DictionaryType where
    Value: DictionaryType,
    Iterator.Element == (Key, Value),
    Value.Iterator.Element == (Value.Key, Value.Value),
    Value.Value: ArrayType
{
    
    /**
     Ensure that there is an Array-type value for the given `keyPath`.
     */
    public mutating func ensureValue(for keyPath: KeyPath) {
        
        guard
            let key = keyPath[0] as? Key,
            let subKey = keyPath[1] as? Value.Key
        else { return }
        
        ensureValue(for: key)
        self[key]!.ensureValue(for: subKey)
    }

    /**
     Append the given `value` to the array at the given `keyPath`.
     
     > If no such subdictionary or array exists, these structures will be created.
     */
    public mutating func safelyAppend(
        _ value: Value.Value.Element,
        toArrayWith keyPath: KeyPath
    )
    {
        guard
            let key = keyPath[0] as? Key,
            let subKey = keyPath[1] as? Value.Key
        else { return }
        
        ensureValue(for: keyPath)
        self[key]!.safelyAppend(value, toArrayWith: subKey)
    }
    
    /**
     Append the given `values` to the array at the given `keyPath`.
     
     > If no such subdictionary or array exists, these structures will be created.
     */
    public mutating func safelyAppendContents(
        of values: Value.Value,
        toArrayWith keyPath: KeyPath
    )
    {
        guard
            let key = keyPath[0] as? Key,
            let subKey = keyPath[1] as? Value.Key
        else { return }
        
        ensureValue(for: keyPath)
        self[key]!.safelyAppendContents(of: values, toArrayWith: subKey)
    }
}

extension DictionaryType where
    Value: DictionaryType,
    Iterator.Element == (Key, Value),
    Value.Iterator.Element == (Value.Key, Value.Value),
    Value.Value: ArrayType,
    Value.Value.Element: Equatable
{
    
    /**
     Append given `value` to the array at the given `keyPath`, ensuring that there are no 
     duplicates.
     
     > If no such subdictionary or array exists, these structures will be created.
     */
    public mutating func safelyAndUniquelyAppend(
        _ value: Value.Value.Element,
        toArrayWith keyPath: KeyPath
    )
    {
        guard
            let key = keyPath[0] as? Key,
            let subKey = keyPath[1] as? Value.Key
        else { return }
        
        ensureValue(for: keyPath)
        self[key]!.safelyAndUniquelyAppend(value, toArrayWith: subKey)
    }
}

// MARK: - Evaluating the equality of `DictionaryType` values

/**
 - returns: `true` if all values in `[H: T]` types are equivalent. Otherwise, `false`.
*/
public func == <D: DictionaryType> (lhs: D, rhs: D) -> Bool where
    D.Iterator.Element == (D.Key, D.Value),
    D.Value: Equatable
{
    for (key, _) in lhs {
        guard let rhsValue = rhs[key], lhs[key]! == rhsValue else {
            return false
        }
    }
    return true
}

/**
 - returns: `true` if any values in `[H: T]` types are not equivalent. Otherwise, `false`.
 */
public func != <D: DictionaryType> (lhs: D, rhs: D) -> Bool where
    D.Iterator.Element == (D.Key, D.Value),
    D.Value: Equatable
{
    return !(lhs == rhs)
}

/**
 - returns: `true` if all values in `[H: [T]]` types are equivalent. Otherwise, `false`.
 */
public func == <D: DictionaryType> (lhs: D, rhs: D) -> Bool where
    D.Iterator.Element == (D.Key, D.Value),
    D.Value: Collection,
    D.Value.Iterator.Element: Equatable,
    D.Value.Index == Int // FIXME: Find a way to do without this constraint
{
    for (key, lhsArray) in lhs {
        guard let rhsArray = rhs[key] else { return false }
        if lhsArray.count != rhsArray.count { return false }
        for i in 0 ..< lhsArray.endIndex {
            if lhsArray[i] != rhsArray[i] { return false }
        }
    }
    return true
}

/**
 - returns: `true` if any values in `[H: [T]]` types are not equivalent. Otherwise, `false`.
 */
public func != <D: DictionaryType> (lhs: D, rhs: D) -> Bool where
    D.Iterator.Element == (D.Key, D.Value),
    D.Value: Collection,
    D.Value.Iterator.Element: Equatable,
    D.Value.Index == Int // FIXME: Find a way to do without this constraint
{
    return !(lhs == rhs)
}

// FIXME: Currently getting `ambiguous reference` errors with the following:
/*
/**
 - returns: `true` if all values in `[H: [HH: T]]` types are equivalent. Otherwise, `false`.
 */
public func == <D: DictionaryType> (lhs: D, rhs: D) -> Bool where
    D.Iterator.Element == (D.Key, D.Value),
    D.Value: DictionaryType,
    D.Value.Iterator.Element == (D.Value.Key, D.Value.Value),
    D.Value.Value: Equatable
{
    for (key, lhsDict) in lhs {
        guard let rhsDict = rhs[key], lhsDict != rhsDict else {
            return false
        }
    }
    return true
}

/**
 - returns: `true` if any values in `[H: [HH: T]]` types are not equivalent. Otherwise, `false`.
 */
public func != <D: DictionaryType> (lhs: D, rhs: D) -> Bool where
    D.Iterator.Element == (D.Key, D.Value),
    D.Value: DictionaryType,
    D.Value.Iterator.Element == (D.Value.Key, D.Value.Value),
    D.Value.Value: Equatable
{
    return !(lhs == rhs)
}
*/

/*
/**
 - returns: `true` if all values in `[H: [HH: [T]]]` types are equivalent. Otherwise, `false`.
 */
public func == <D: DictionaryType> (lhs: D, rhs: D) -> Bool where
    D.Iterator.Element == (D.Key, D.Value),
    D.Value: DictionaryType,
    D.Value.Iterator.Element == (D.Value.Key, D.Value.Value),
    D.Value.Value: Collection,
    D.Value.Value.Iterator.Element: Equatable,
    D.Value.Value.Index == Int // FIXME: Find a way to do without this constraint
{
    for (key, lhsDict) in lhs {
        guard let rhsDict = rhs[key] else { return false }
        if lhsDict != rhsDict { return false }
    }
    return true
}

/**
 - returns: `true` if any values in `[H: [HH: [T]]]` types are not equivalent.
 Otherwise, `false`.
 */
public func != <D: DictionaryType> (lhs: D, rhs: D) -> Bool where
    D.Iterator.Element == (D.Key, D.Value),
    D.Value: DictionaryType,
    D.Value.Iterator.Element == (D.Value.Key, D.Value.Value),
    D.Value.Value: Collection,
    D.Value.Value.Iterator.Element: Equatable,
    D.Value.Value.Index == Int // FIXME: Find a way to do without this constraint
{
    return !(lhs == rhs)
}
*/
