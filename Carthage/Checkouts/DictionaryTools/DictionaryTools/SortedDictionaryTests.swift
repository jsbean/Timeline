////
////  SortedOrderedDictionaryTests.swift
////  DictionaryTools
////
////  Created by James Bean on 6/27/16.
////  Copyright © 2016 James Bean. All rights reserved.
////
//
//import XCTest
//import ArrayTools
//@testable import DictionaryTools
//
//class SortedOrderedDictionaryTests: XCTestCase {
//
//    func testInsert() {
//        var dict = SortedDictionary<String, Int>()
//        dict.insert("one", key: 1)
//        XCTAssert(dict.count == 1)
//        dict.insert("two", key: 2)
//        XCTAssert(dict.count == 2)
//    }
//    
//    func testRemoveViaSubscript() {
//        var dict = SortedDictionary<String, Int>()
//        dict.insert("one", key: 1)
//        XCTAssert(dict.count == 1)
//        dict.insert("two", key: 2)
//        XCTAssert(dict.count == 2)
//        dict[2] = nil
//        XCTAssert(dict.count == 1)
//    }
//    
//    func testSorted() {
//        var dict = SortedDictionary<String, Int>()
//        dict.insert("two", key: 2)
//        dict.insert("four", key: 4)
//        dict.insert("five", key: 5)
//        dict.insert("one", key: 1)
//        dict.insert("three", key: 3)
//        XCTAssertEqual(dict.keyStorage, [1,2,3,4,5])
//    }
//    
//    func testIterationSorted() {
//        var dict = SortedDictionary<String, Int>()
//        dict.insert("two", key: 2)
//        dict.insert("four", key: 4)
//        dict.insert("five", key: 5)
//        dict.insert("one", key: 1)
//        dict.insert("three", key: 3)
//        XCTAssertEqual(dict.map { $0.0 }, [1,2,3,4,5])
//    }
//}
