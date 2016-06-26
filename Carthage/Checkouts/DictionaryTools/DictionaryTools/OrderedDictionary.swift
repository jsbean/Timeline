//
//  OrderedDictionary.swift
//  DictionaryTools
//
//  Created by James Bean on 2/23/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

/**
 Ordered Dictionary.
 
 - TODO: Conform to `MutableCollectionType`.
 */
public struct OrderedDictionary<K: Hashable, V> {
    
    // MARK: - Instance Variables
    
    /** 
     Keys of `OrderedDictionary`.
     */
    public var keyStorage: [Key] = []
    
    /**
     Values of `OrderedDictionary`.
     */
    public var values: [Key: Value] = [:]
    
    // MARK: - Initializers
    
    /**
     Create an empty `OrderedDictionary`.
     */
    public init() { }
    
    // MARK: - Instance Methods
    
    /**
    Append `value` for `key`.
    */
    public mutating func append(value: Value, key: Key) {
        keyStorage.append(key)
        values[key] = value
    }
    
    /**
     Insert `value` for `key`, at a given `index`.
     */
    public mutating func insert(value: Value, key: Key, index: Int) {
        keyStorage.insert(key, atIndex: index)
        values[key] = value
    }
    
    /**
     Append the contents of another `OrderedDictionary`.
     */
    public mutating func appendContents(of orderedDictionary: OrderedDictionary<Key,Value>) {
        keyStorage.appendContentsOf(orderedDictionary.keyStorage)
        for key in orderedDictionary.keyStorage {
            values.updateValue(orderedDictionary[key]!, forKey: key)
        }
    }
    
    /**
     - returns: Value at the given `index`, if present. Otherwise `nil`.
     */
    public func value(at index: Int) -> Value? {
        if index >= keyStorage.count { return nil }
        return values[keyStorage[index]]
    }
}

extension OrderedDictionary: OrderedDictionaryType {
    
    // MARK: - DictionaryType
    
    public typealias KeyStorage = [Key]
    
    //public typealias Generator = OrderedDictionaryGenerator<Key, Value>
    
    /// Key type.
    public typealias Key = K
    
    /// Value type.
    public typealias Value = V
    
    /**
     - returns: Value for the given `key`, if available. Otherise `nil`.
     */
    public subscript(key: Key) -> Value? {
        
        get { return values[key] }
        
        set(newValue) {
            if newValue == nil {
                values.removeValueForKey(key)
                keyStorage = keyStorage.filter { $0 != key }
                return
            }
            
            let oldValue = values.updateValue(newValue!, forKey: key)
            if oldValue == nil { keyStorage.append(key) }
        }
    }
}

extension OrderedDictionary: CollectionType {
    
    // MARK: - CollectionType
    
    public typealias Index = DictionaryIndex<Key, Value>
    public var startIndex: Index { return values.startIndex }
    public var endIndex: Index { return values.endIndex }
    
    /**
     - returns: Value at the given `index`. Will crash if index out-of-range.
     */
    public subscript (index: Index) -> (Key, Value) {
        return values[index]
    }
}

/**
- returns: `OrderedDictionary` with values of two `OrderedDictionary` values.
*/
public func + <Key: Hashable, Value> (
    lhs: OrderedDictionary<Key, Value>,
    rhs: OrderedDictionary<Key, Value>
) -> OrderedDictionary<Key, Value>
{
    var result = lhs
    rhs.forEach { result.append($0.1, key: $0.0) }
    return result
}

// MARK: - Equatable

/**
 - returns: `true` if all `Values` and `Keys` are equivalent. Otherwise `false`.
 */
public func == <Key, Value: Equatable> (
    lhs: OrderedDictionary<Key,Value>,
    rhs: OrderedDictionary<Key,Value>
) -> Bool
{

    if lhs.keyStorage != rhs.keyStorage { return false }
    
    // for each lhs key, check if rhs has value for key, and if that value is the same
    for key in lhs.keyStorage {
        if rhs.values[key] == nil || rhs.values[key]! != lhs.values[key]! { return false }
    }
    
    // do the same for rhs keys to lhs values
    for key in rhs.keyStorage {
        if lhs.values[key] == nil || lhs.values[key]! != rhs.values[key]! { return false }
    }
    
    return true
}

extension OrderedDictionary: CustomStringConvertible {
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        return values.description
    }
}
