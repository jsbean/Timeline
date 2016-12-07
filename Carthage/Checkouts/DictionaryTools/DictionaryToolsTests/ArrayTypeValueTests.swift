//
//  ArrayTypeValueTests.swift
//  DictionaryTools
//
//  Created by James Bean on 2/22/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import XCTest
@testable import DictionaryTools

class ArrayTypeValueTests: XCTestCase {

    func testEnsureValueAtKeyNecessary() {
        var dict = ["k": [1,2,3,4]]
        dict.ensureValue(for: "new")
        XCTAssertNotNil(dict["new"])
    }
    
    func testEnsureValueAtKeyUnnecessary() {
        var dict = ["k": [1,2,3,4]]
        dict.ensureValue(for: "k")
        XCTAssertEqual(dict["k"]!, [1,2,3,4])
    }
    
    func testArraysEqual() {
        let array1 = [1,2,3,4]
        let array2 = [1,2,3,4]
        XCTAssertEqual(array1, array2)
    }
    
    func testArraysNotEqual() {
        let array1 = [1,2,3,4]
        let array2 = [4,3,2,1]
        XCTAssertNotEqual(array1, array2)
    }
    
    func testEqual() {
        let dict1 = ["k1": 1]
        let dict2 = ["k1": 1]
        XCTAssert(dict1 == dict2)
    }
}
