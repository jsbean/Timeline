//
//  DictionaryLiteralConvertibleValue.swift
//  DictionaryTools
//
//  Created by James Bean on 2/22/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import Foundation

public extension Dictionary where
    Key: Hashable,
    Value: DictionaryLiteralConvertible,
    Value.Key: Hashable,
    Value.Value: Any
{
    
    // MARK: - [Hashable: [Hashable: Any]]
    
    private typealias SubDictionary = Dictionary<Value.Key, Value.Value>
    private typealias Internal = Value.Key
    private typealias Leaf = Value.Value
    
    mutating func ensureValue(for key: Key) {
        if self[key] == nil { self[key] = [:] }
    }
    
    mutating func updateValue(value: Value.Value, forKeyPath keyPath: KeyPath) {
        guard let key = keyPath[0] as? Key, subKey = keyPath[1] as? Value.Key else { return }
        self.ensureValue(for: key)
        var dictCopy = self[key]! as! SubDictionary
        dictCopy.updateValue(value, forKey: subKey)
        self.updateValue(dictCopy as! Value, forKey: key)
    }

    mutating func mergeWith(dictionary: Dictionary<Key, Value>)
        -> Dictionary<Key, Value>
    {
        var target: Dictionary<Key,Value> = self
        for (key, subDict) in dictionary {
            target.ensureValue(for: key)
            var dictCopy = target[key]! as! SubDictionary
            for (subKey, value) in subDict as! SubDictionary {
                dictCopy.updateValue(value, forKey: subKey)
            }
            target.updateValue(dictCopy as! Value, forKey: key)
        }
        return target
    }
}

public func + <K: Hashable, KK: Hashable, V: Equatable>(lhs: [K: [KK : V]], rhs: [K: [KK : V]])
    -> [K: [KK: V]]
{
    return lhs.merge(with: rhs)
}

public func += <K: Hashable, KK: Hashable, V: Equatable>(
    inout lhs: [K: [KK : V]], rhs: [K: [KK : V]]
)
{
    lhs = lhs + rhs
}

/**
 - returns: `true` if each value in both Dictionaries are equivalent. Otherwise `false`.
 */
public func == <K: Hashable, KK: Hashable, V: Equatable>(
    lhs: [K: [KK : V]], rhs: [K: [KK : V]]
) -> Bool
{
    for key in lhs.keys {
        if rhs[key] == nil { return false }
        for subkey in lhs[key]!.keys {
            if rhs[key]![subkey] == nil { return false }
            if rhs[key]![subkey] != lhs[key]![subkey] { return false }
        }
    }
    return true
}


public func != <K: Hashable, KK: Hashable, V: Equatable>(
    lhs: [K: [KK : V]], rhs: [K: [KK : V]]
) -> Bool
{
    return !(lhs == rhs)
}

public extension Dictionary where
    Key: Hashable,
    Value: DictionaryLiteralConvertible,
    Value.Key: Hashable,
    Value.Value: _ArrayType
{
    
    // MARK: - [Hashable: [Hashable: [Any]]]    
    
    public mutating func ensureValueFor(keyPath: KeyPath) {
        guard let key = keyPath[0] as? Key, subKey = keyPath[1] as? Value.Key else { return }
        guard (self[key] as? [Value.Key: Value.Value])?[subKey] == nil else { return }
        self.ensureValue(for: key)
        var dictCopy = self[key]! as! Dictionary<Value.Key, Value.Value>
        dictCopy[subKey] = []
        self[key] = dictCopy as? Value
    }
    
    public mutating func safelyAppend(value: Value.Value.Generator.Element,
        toArrayWithKeyPath keyPath: KeyPath
    )
    {
        guard let key = keyPath[0] as? Key, subKey = keyPath[1] as? Value.Key else { return }
        self.ensureValueFor(keyPath)
        var dictCopy = self[key] as! Dictionary<Value.Key, Value.Value>
        dictCopy.ensureValue(for: subKey)
        dictCopy[subKey]!.append(value)
        self.updateValue(dictCopy as! Value, forKey: key)
    }
}