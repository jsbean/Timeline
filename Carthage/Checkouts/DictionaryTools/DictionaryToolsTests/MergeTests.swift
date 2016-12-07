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
        var d1 = ["k1": "v1"]
        let d2 = ["k2": "v2"]
        d1.merge(with: d2)
        XCTAssertEqual(d1, ["k1": "v1", "k2": "v2"])
    }
    
    func testMergeSingleDepthOverlap() {
        var d1 = ["k1": "v1"]
        let d2 = ["k1": "OVERRIDE", "k2": "v2"]
        d1.merge(with: d2)
        XCTAssertEqual(d1, ["k1": "OVERRIDE", "k2": "v2"])
    }
    
    func testArrayTypeValueMerge() {
        var d1 = ["k1": [1,2,3]]
        let d2 = ["k1": [4,5,6]]
        d1.merge(with: d2)
        XCTAssertEqual(d1["k1"]!, [4,5,6])
    }
    
    func testDoubleDepthDeepMergeOverride() {
        
        var d1 = ["k1": [0: 1], "k2": [0: 1]]
        let d2 = ["k2": [0: 2], "k3": [0: 3]]
        d1.merge(with: d2)
        
        XCTAssertEqual(d1["k2"]![0], 2)
    }
    
    func testDoubleDepthDeepMergeAppend() {
        
        var d1 = ["k1": [0: 1], "k2": [0: 1]]
        let d2 = ["k2": [0: 2], "k3": [0: 3]]
        d1.merge(with: d2)
        
        XCTAssertEqual(d1["k3"]![0], 3)
    }
}

