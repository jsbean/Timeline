//
//  Merge.swift
//  DictionaryTools
//
//  Created by James Bean on 2/22/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import Foundation

extension Dictionary {
    
    /**
     Create a new dictionary with the values of self and those of another dictionary.
     
     - note: Values of new dictionary will override those of self
     - parameter dictionary: Dictionary whose values to merge into self
     */
    public func merge(with dictionary: Dictionary<Key,Value>)
        -> Dictionary<Key, Value>
    {
        var result: Dictionary<Key,Value> = self
        for (k,v) in dictionary { result.updateValue(v, forKey: k) }
        return result
    }
}

public func + <K: Hashable, V: Any>(lhs: Dictionary<K, V>, rhs: Dictionary<K, V>)
    -> Dictionary<K, V>
{
    return lhs.merge(with: rhs)
}

public func += <K: Hashable, V: Any>(inout lhs: Dictionary<K, V>, rhs: Dictionary<K, V>) {
    lhs = lhs + rhs
}