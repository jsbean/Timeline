//
//  MergeTests.swift
//  DictionaryTools
//
//  Created by James Bean on 2/23/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import XCTest
@testable import DictionaryTools

class MergeTests: XCTestCase {

    func testMergeSingleDepthNoOverlap() {
        let d1 = ["k1": "v1"]
        let d2 = ["k2": "v2"]
        let d3 = d1.merge(with: d2)
        XCTAssertEqual(d3, ["k1": "v1", "k2": "v2"])
    }
    
    func testMergeSingleDepthOverlap() {
        let d1 = ["k1": "v1"]
        let d2 = ["k1": "OVERRIDE", "k2": "v2"]
        let d3 = d1.merge(with: d2)
        XCTAssertEqual(d3, ["k1": "OVERRIDE", "k2": "v2"])
    }
    
    func testPlusOperator() {
        let d1 = ["k1": "v1"]
        let d2 = ["k1": "OVERRIDE", "k2": "v2"]
        let d3 = d1 + d2
        XCTAssertEqual(d3, ["k1": "OVERRIDE", "k2": "v2"])
    }
}
