//
//  OrderedDictionaryTests.swift
//  DictionaryTools
//
//  Created by James Bean on 2/23/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import XCTest
@testable import DictionaryTools

class OrderedDictionaryTests: XCTestCase {

    func emptyDict() -> OrderedDictionary<String, String> {
        return OrderedDictionary<String, String>()
    }
    
    func testInit() {
        let dict = OrderedDictionary<String, String>()
        XCTAssertEqual(dict.count, 0)
    }
    
    func testSubscriptIntNil() {
        let dict = emptyDict()
        XCTAssertNil(dict[0])
    }
    
    func testSubscriptKeyNil() {
        let dict = emptyDict()
        XCTAssertNil(dict["zero"])
    }
    
    func testSubscriptIntValid() {
        var dict = emptyDict()
        dict.insert("val", forKey: "key", atIndex: 0)
        XCTAssertEqual(dict[0]!, "val")
    }
    
    func testSubscriptKeyValid() {
        var dict = emptyDict()
        dict.insert("val", forKey: "key", atIndex: 0)
        XCTAssertEqual(dict["key"]!, "val")
    }
    
    func testInsert() {
        var dict = OrderedDictionary<String, String>()
        dict.insert("val", forKey: "key", atIndex: 0)
        dict.insert("insertedVal", forKey: "insertedKey", atIndex: 0)
        XCTAssertEqual(dict[0]!, "insertedVal")
        XCTAssertEqual(dict[1]!, "val")
    }
    
    func testAppend() {
        var dict = OrderedDictionary<String, String>()
        dict.append("val", forKey: "key")
        dict.append("anotherVal", forKey: "anotherKey")
        XCTAssertEqual(dict[0]!, "val")
        XCTAssertEqual(dict[1]!, "anotherVal")
    }
    
    func testAppendContentsOfEmptyDict() {
        var dict1 = emptyDict()
        let dict2 = emptyDict()
        dict1.appendContents(of: dict2)
        XCTAssertEqual(dict1.count, 0)
        XCTAssertEqual(dict2.count, 0)
    }
    
    func testAppendContentsOfNonEmptyToEmptyDict() {
        var dict1 = emptyDict()
        var dict2 = emptyDict()
        dict2.insert("val", forKey: "key", atIndex: 0)
        dict1.appendContents(of: dict2)
        XCTAssertEqual(dict1.count, 1)
    }
    
    func testAppendContentsOfEmptyToNonEmptyDict() {
        var dict1 = emptyDict()
        dict1.insert("val", forKey: "key", atIndex: 0)
        let dict2 = emptyDict()
        dict1.appendContents(of: dict2)
        XCTAssertEqual(dict1.count, 1)
    }
}
