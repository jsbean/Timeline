//
//  KeyPathTests.swift
//  DictionaryTools
//
//  Created by James Bean on 2/22/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import XCTest
@testable import DictionaryTools

class KeyPathTests: XCTestCase {
    
    func testInitArray() {
        let keyPath = KeyPath(["1", "2", "ok"])
        XCTAssertEqual(keyPath.count, 3)
    }
    
    func testInitString() {
        let keyPath = KeyPath("a.b.2.ok.g")
        XCTAssertEqual(keyPath.count, 5)
    }
}
