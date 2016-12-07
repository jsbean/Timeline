//
//  DictionaryTypeTests.swift
//  DictionaryTools
//
//  Created by James Bean on 10/30/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import XCTest
@testable import DictionaryTools

class DictionaryTypeTests: XCTestCase {
    
    func testSafelyAppendToExisting() {
        
        var dict = [0: [0,1,2]]
        dict.safelyAppend(3, toArrayWith: 0)
        
        XCTAssertEqual(dict[0]!, [0,1,2,3])
    }
    
    func testSafelyAppendToNotYetExisting() {
        
        var dict = [0: [0,1,2]]
        dict.safelyAppend(0, toArrayWith: 1)
        
        XCTAssertEqual(dict[1]!, [0])
    }
    
    func testSafelyAppendContentsToExisting() {
        
        var dict = [0: [0,1,2]]
        dict.safelyAppendContents(of: [3,4,5], toArrayWith: 0)
        
        XCTAssertEqual(dict[0]!, [0,1,2,3,4,5])
    }
    
    func testSafelyAppendContentsToNotYetExtant() {
        
        var dict = [0: [0,1,2]]
        dict.safelyAppendContents(of: [0,1,2], toArrayWith: 1)
        
        XCTAssertEqual(dict[1]!, [0,1,2])
    }
    
    func testSafelyAndUniquelyAppendValuePreexisting() {
        
        var dict = [0: [0,1,2]]
        dict.safelyAndUniquelyAppend(1, toArrayWith: 1)
        
        XCTAssertEqual(dict[0]!, [0,1,2])
    }
    
    func testSafelyAndUniquelyAppendValueNotExtant() {
        
        var dict = [0: [0,1,2]]
        dict.safelyAndUniquelyAppend(3, toArrayWith: 0)
        
        XCTAssertEqual(dict[0]!, [0,1,2,3])
    }
    
    func testEnsureArrayTypeValueForKeyPreexisting() {
        
        var dict = [0: [0], 1: [1], 2: [2]]
        dict.ensureValue(for: 0)
        
        XCTAssertEqual(dict[1]!, [1])
    }
    
    func testEnsureArrayTypeValueForKeyNotYetExtant() {
        
        var dict = [0: [0], 1: [1], 2: [2]]
        dict.ensureValue(for: 3)
        
        XCTAssertEqual(dict[3]!, [])
    }
    
    func testEnsureDictionaryTypeValuePreexisting() {
        
        var dict = [0: [0: 0]]
        dict.ensureValue(for: 0)
        
        XCTAssertNotNil(dict[0])
    }
    
    func testEnsureDictionaryTypeValueNotYetExtant() {
        
        var dict = [0: [0: 0]]
        dict.ensureValue(for: 1)
        
        XCTAssertNotNil(dict[1])
    }
    
    func testUpdateValueForKeyPathStringKeys() {
        
        var dict = ["parent": ["child": 0]]
        dict.update(1, keyPath: KeyPath("parent.child"))
        
        XCTAssertEqual(dict["parent"]!["child"], 1)
    }
    
    func testUpdateValueForKeyPathHeterogeneousKeys() {
        
        var dict = ["0": [1: 2.0]]
        dict.update(2.1, keyPath: ["0", 1])
        
        XCTAssertEqual(dict["0"]![1], 2.1)
    }
    
    func testDictionaryInitWithArrays() {
        
        let xs = [0,1,2,3,4]
        let ys = ["a","b","c","d","e"]
        
        let dict = Dictionary(xs,ys)
        
        XCTAssertEqual(dict[0], "a")
        XCTAssertEqual(dict[4], "e")
    }
    
    func testSortedDictionaryInitWithArraysSorted() {
        
        let xs = [0,3,4,1,2]
        let ys = ["a","d","e","b","c"]
        
        let dict = SortedDictionary(xs,ys)
        
        XCTAssertEqual(dict[0], "a")
        XCTAssertEqual(dict[4], "e")
    }
}
