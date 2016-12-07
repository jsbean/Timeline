//
//  ArrayType.swift
//  DictionaryTools
//
//  Created by James Bean on 10/29/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import Foundation

public protocol ArrayType: Collection {
    associatedtype Element
    init()
    mutating func append(_ element: Element)
    mutating func append<S: Sequence> (contentsOf newElements: S) where
        S.Iterator.Element == Iterator.Element
}

extension Array: ArrayType { }
