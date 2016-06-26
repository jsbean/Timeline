//
//  OrderedDictionaryType.swift
//  DictionaryTools
//
//  Created by James Bean on 6/26/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

/**
 Interface defining OrderedDictionary value types.
 */
public protocol OrderedDictionaryType: DictionaryType {
    
    // MARK: - Associated Types
    
    /// CollectionType storing the keys.
    associatedtype KeyStorage: CollectionType
    
    // MARK: - Instance Properties
    
    /// Keys of the backing dictionary.
    var keyStorage: KeyStorage { get set }
    
    /// A collection containing just the keys of `self`.
    var keys: LazyMapCollection<[Key : Value], Key> { get }
    
    /// Backing dictionary.
    var values: [Key: Value] { get set }
}

extension OrderedDictionaryType {
    
    /// A collection containing just the keys of `self`.
    public var keys: LazyMapCollection<[Key : Value], Key> {
        return values.keys
    }
    
    /**
     Create an `OrderedDictionaryGenerator`.
     */
    public func generate() -> OrderedDictionaryGenerator<Key, Value> {
        return OrderedDictionaryGenerator<Key, Value>(self)
    }
}

/**
 Generator of `OrderedDictionaryType` values.
 */
public struct OrderedDictionaryGenerator<Key: Hashable, Value>: GeneratorType {
    
    // MARK: - `GeneratorType`
    
    private var generator: DictionaryGenerator<Key, Value>
    
    /**
     Create an `OrderedDictionaryGenerator` with an `OrderedDictionaryType` value.
     */
    public init<D: OrderedDictionaryType where D.Key == Key, D.Value == Value>(
        _ orderedDictionary: D
    )
    {
        self.generator = orderedDictionary.values.generate()
    }
    
    /**
     The next key value pair.
     */
    public mutating func next() -> (Key, Value)? {
        return generator.next()
    }
}
