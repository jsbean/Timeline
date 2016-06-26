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
public protocol DictionaryType: CollectionType {
    
    // MARK: - Associated Types
    
    /**
     Key type.
     */
    associatedtype Key: Hashable
    
    /**
     Value type.
     */
    associatedtype Value
    
    // MARK: - Instance Properties
    
    /// A collection containing just the keys of `self`.
    var keys: LazyMapCollection<[Key : Value], Key> { get }
    
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

extension DictionaryType where Generator.Element == (Key, Value) {
    
    // MARK: - Instance Methods
    
    /**
     Merge the contents of the given `dictionary` destructively into this one.
     
     - warning: The value of a given key of the given `dictionary` will override that of this
     one.
     */
    public mutating func merge(with dictionary: Self) {
        for (k,v) in dictionary { self[k] = v }
    }
}

extension DictionaryType where Value: _ArrayType {
    
    /**
     Ensure that an Array-type value exists for the given `key`.
     */
    public mutating func ensureValue(for key: Key) {
        if self[key] == nil { self[key] = [] }
    }
    
    /**
     Safely append the given `value` to the Array-type `value` for the given `key`.
     */
    public mutating func safelyAppend(value: Value.Generator.Element, toArrayWith key: Key)
    {
        ensureValue(for: key)
        self[key]!.append(value)
    }
    
    /**
     Safely append the contents of an array to the Array-type `value` for the given `key`.
     */
    public mutating func safelyAppendContents(of values: Value, toArrayWith key: Key) {
        ensureValue(for: key)
        self[key]!.appendContentsOf(values)
    }
}

extension DictionaryType where Value: _ArrayType, Value.Generator.Element: Equatable {
    
    /**
     Safely append value to the array value for a given key. 
     
     If this value already exists in desired array, the new value will not be added.
     */
    public mutating func safelyAndUniquelyAppend(
        value: Value.Generator.Element,
        toArrayWith key: Key
    )
    {
        ensureValue(for: key)
        if self[key]!.contains(value) { return }
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
        if self[key] == nil { self[key] = Value() }
    }
    
    /**
     Update the `value` for the given `keyPath`.
     
     - TODO: Use subscript (keyPath: KeyPath) { get set }
     */
    public mutating func update(value: Value.Value, keyPath: KeyPath) {
        guard let key = keyPath[0] as? Key, subKey = keyPath[1] as? Value.Key else { return }
        self.ensureValue(for: key)
        self[key]?[subKey] = value
    }
}

extension DictionaryType where
    Value: DictionaryType,
    Generator.Element == (Key, Value),
    Value.Generator.Element == (Value.Key, Value.Value)
{
    
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

extension DictionaryType where
    Value: DictionaryType,
    Generator.Element == (Key, Value),
    Value.Generator.Element == (Value.Key, Value.Value),
    Value.Value: _ArrayType
{
    
    /**
     Ensure that there is an Array-type value for the given `keyPath`.
     */
    public mutating func ensureValue(for keyPath: KeyPath) {
        guard let key = keyPath[0] as? Key, subKey = keyPath[1] as? Value.Key else { return }
        ensureValue(for: key)
        self[key]!.ensureValue(for: subKey)
    }
    
    /**
     Append the given `value` to the array at the given `keyPath`.
     
     > If no such subdictionary or array exists, these structures will be created.
     */
    public mutating func safelyAppend(
        value: Value.Value.Generator.Element,
        toArrayWith keyPath: KeyPath
    )
    {
        guard let key = keyPath[0] as? Key, subKey = keyPath[1] as? Value.Key else { return }
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
        guard let key = keyPath[0] as? Key, subKey = keyPath[1] as? Value.Key else { return }
        ensureValue(for: keyPath)
        self[key]!.safelyAppendContents(of: values, toArrayWith: subKey)
    }
}

extension DictionaryType where
    Value: DictionaryType,
    Generator.Element == (Key, Value),
    Value.Generator.Element == (Value.Key, Value.Value),
    Value.Value: _ArrayType,
    Value.Value.Generator.Element: Equatable
{
    
    /**
     Append given `value` to the array at the given `keyPath`, ensuring that there are no 
     duplicates.
     
     > If no such subdictionary or array exists, these structures will be created.
     */
    public mutating func safelyAndUniquelyAppend(
        value: Value.Value.Generator.Element,
        toArrayWith keyPath: KeyPath
    )
    {
        guard let key = keyPath[0] as? Key, subKey = keyPath[1] as? Value.Key else { return }
        ensureValue(for: keyPath)
        self[key]!.safelyAndUniquelyAppend(value, toArrayWith: subKey)
    }
}

// MARK: - Evalluating the equality of `DictionaryType` values

/**
 - returns: `true` if all values in `[H: T]` types are equivalent. Otherwise, `false`.
*/
public func == <
    D: DictionaryType where
        D.Generator.Element == (D.Key, D.Value),
        D.Value: Equatable
> (
    lhs: D,
    rhs: D
) -> Bool
{
    for key in lhs.keys {
        guard let rhsValue = rhs[key] else { return false }
        if lhs[key]! != rhsValue { return false }
    }
    return true
}

/**
 - returns: `true` if any values in `[H: T]` types are not equivalent. Otherwise, `false`.
 */
public func != <
    D: DictionaryType where
        D.Generator.Element == (D.Key, D.Value),
        D.Value: Equatable
> (
    lhs: D,
    rhs: D
) -> Bool
{
    return !(lhs == rhs)
}

/**
 - returns: `true` if all values in `[H: [T]]` types are equivalent. Otherwise, `false`.
 */
public func == <
    D: DictionaryType where
        D.Generator.Element == (D.Key, D.Value),
        D.Value: _ArrayType,
        D.Value.Generator.Element: Equatable
> (
    lhs: D,
    rhs: D
) -> Bool
{
    for key in lhs.keys {
        guard let rhsArray = rhs[key], lhsArray = lhs[key] else { return false }
        if lhsArray.count != rhsArray.count { return false }
        for i in 0 ..< lhsArray.count {
            if lhsArray[i] != rhsArray[i] { return false }
        }
    }
    return true
}

/**
 - returns: `true` if any values in `[H: [T]]` types are not equivalent. Otherwise, `false`.
 */
public func != <
    D: DictionaryType where
        D.Generator.Element == (D.Key, D.Value),
        D.Value: _ArrayType,
        D.Value.Generator.Element: Equatable
> (
    lhs: D,
    rhs: D
) -> Bool
{
    return !(lhs == rhs)
}

/**
 - returns: `true` if all values in `[H: [HH: T]]` types are equivalent. Otherwise, `false`.
 */
public func == <
    D: DictionaryType where
        D.Generator.Element == (D.Key, D.Value),
        D.Value: DictionaryType,
        D.Value.Generator.Element == (D.Value.Key, D.Value.Value),
        D.Value.Value: Equatable
> (
    lhs: D,
    rhs: D
) -> Bool
{
    for key in lhs.keys {
        guard let rhsDict = rhs[key], lhsDict = lhs[key] else { return false }
        if lhsDict != rhsDict { return false }
    }
    return true
}

/**
 - returns: `true` if aby values in `[H: [HH: T]]` types are not equivalent. Otherwise, `false`.
 */
public func != <
    D: DictionaryType where
        D.Generator.Element == (D.Key, D.Value),
        D.Value: DictionaryType,
        D.Value.Generator.Element == (D.Value.Key, D.Value.Value),
        D.Value.Value: Equatable
> (
    lhs: D,
    rhs: D
) -> Bool {
    return !(lhs == rhs)
}

/**
 - returns: `true` if all values in `[H: [HH: [T]]]` types are equivalent. Otherwise, `false`.
 */
public func == <
    D: DictionaryType where
        D.Generator.Element == (D.Key, D.Value),
        D.Value: DictionaryType,
        D.Value.Generator.Element == (D.Value.Key, D.Value.Value),
        D.Value.Value: _ArrayType,
        D.Value.Value.Generator.Element: Equatable
> (
    lhs: D,
    rhs: D
) -> Bool {
    for key in lhs.keys {
        guard let rhsDict = rhs[key], lhsDict = lhs[key] else { return false }
        if lhsDict != rhsDict { return false }
    }
    return true
}

/**
 - returns: `true` if any values in `[H: [HH: [T]]]` types are not equivalent.
 Otherwise, `false`.
 */
public func != <
    D: DictionaryType where
        D.Generator.Element == (D.Key, D.Value),
        D.Value: DictionaryType,
        D.Value.Generator.Element == (D.Value.Key, D.Value.Value),
        D.Value.Value: _ArrayType,
        D.Value.Value.Generator.Element: Equatable
> (
    lhs: D,
    rhs: D
) -> Bool {
    return !(lhs == rhs)
}


// MARK: - Adding `DictionaryType` values

/**
 - returns: The result of merging the `DictionaryType` value on the right into the
 `DictionaryType` value on the left.
 */
public func + <D: DictionaryType where D.Generator.Element == (D.Key, D.Value)> (
    lhs: D,
    rhs: D
) -> D
{
    var result = lhs
    result.merge(with: rhs)
    return result
}

/**
 - returns: The result of merging the `DictionaryType` value on the right into the
 `DictionaryType` value on the left.
 */
public func + <
    D: DictionaryType where
        D.Value: DictionaryType,
        D.Generator.Element == (D.Key, D.Value),
        D.Value.Generator.Element == (D.Value.Key, D.Value.Value)
> (
    lhs: D,
    rhs: D
) -> D
{
    var result = lhs
    result.merge(with: rhs)
    return result
}
