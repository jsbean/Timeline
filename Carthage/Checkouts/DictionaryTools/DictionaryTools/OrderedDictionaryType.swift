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
    
    /// Backing dictionary.
    var values: [Key: Value] { get set }
}

extension OrderedDictionaryType {
    
    /**
     - returns:  An array containing the transformed elements of this sequence.
     */
    public func map<T>(transform: (Generator.Element) throws -> T) rethrows -> [T] {
        
        let initialCapacity = underestimateCount()
        var result = ContiguousArray<T>()
        result.reserveCapacity(initialCapacity)
        
        var iterator = generate()
        
        // Add elements up to the initial capacity without checking for regrowth.
        for _ in 0..<initialCapacity {
            result.append(try transform(iterator.next()!))
        }
        
        // Add remaining elements, if any.
        while let element = iterator.next() {
            result.append(try transform(element))
        }
        return Array(result)
    }
}

extension OrderedDictionaryType where
    KeyStorage.Index == Int,
    KeyStorage.Generator.Element == Key
{
    
    /**
     Create an iterator for an `OrderedDictionaryType` value.
     */
    public func generate() -> AnyGenerator<(Key, Value)> {
        var index = keyStorage.startIndex
        return AnyGenerator<(Key, Value)> {
            defer { index += 1 }
            guard index < self.keyStorage.endIndex else { return nil }
            let key = self.keyStorage[index]
            guard let value = self.values[key] else { return nil }
            return (key, value)
        }
    }
}
