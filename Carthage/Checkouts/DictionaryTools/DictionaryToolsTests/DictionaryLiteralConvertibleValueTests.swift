//
//  DictionaryLiteralConvertibleValueTests.swift
//  DictionaryTools
//
//  Created by James Bean on 2/23/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import XCTest
@testable import DictionaryTools

//class DictionaryLiteralConvertibleValueTests: XCTestCase {
//
//    func testEqual() {
//        let dict1 = ["k": ["kk": "v"]]
//        let dict2 = ["k": ["kk": "v"]]
//        XCTAssert(dict1 == dict2)
//        XCTAssert(!(dict1 != dict2))
//    }
//    
//    func testNotEqualKeys() {
//        let dict1 = ["k": ["kk": "v"]]
//        let dict2 = ["l": ["kk": "v"]]
//        XCTAssert(dict1 != dict2)
//        XCTAssert(!(dict1 == dict2))
//    }
//    
//    func testNotEqualSubkeys() {
//        let dict1 = ["k": ["kk": "v"]]
//        let dict2 = ["k": ["ll": "v"]]
//        XCTAssert(dict1 != dict2)
//        XCTAssert(!(dict1 == dict2))
//    }
//    
//    func testNotEqualValues() {
//        let dict1 = ["k": ["kk": "v"]]
//        let dict2 = ["k": ["kk": "v2"]]
//        XCTAssert(dict1 != dict2)
//        XCTAssert(!(dict1 == dict2))
//    }
//    
//    func testDeepMerge() {
//        let dict1 = ["k": ["kk": "v"]]
//        let dict2 = ["l": ["ll": "v"]]
//        XCTAssert(dict1 + dict2 == ["k": ["kk": "v"], "l": ["ll": "v"]])
//    }
//    
//    func testPlusOperator() {
//        let dict1 = ["k": ["kk": "v"]]
//        let dict2 = ["l": ["ll": "v"]]
//        XCTAssertEqual(dict1 + dict2, ["k": ["kk": "v"], "l": ["ll": "v"]])
//    }
//    
//    
//    func testEnsureArrayValue() {
//        var dict = ["k": ["kk": [1,2,3,4]]]
//        let keyPath = KeyPath("l.ll")
//        dict.ensureValue(for: keyPath)
//        XCTAssert(dict == ["k": ["kk": [1,2,3,4]], "l": ["ll": []]])
//    }
//    
//    func testSafelyAppendToArrayWithKeyPath() {
//        var dict = ["k": ["kk": [1,2,3,4]]]
//        dict.safelyAppend(5, toArrayWith: KeyPath("k.kk"))
//        XCTAssert(dict == ["k": ["kk": [1,2,3,4,5]]])
//    }
//}
