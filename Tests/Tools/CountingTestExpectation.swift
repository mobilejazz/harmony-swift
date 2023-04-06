//
//  CountingTestExpectation.swift
//  HarmonyTests
//
//  Created by Joan Martin on 16/6/22.
//

import XCTest

class CountingTestExpectation: XCTestExpectation {
    
    /// The number of times the expectation was fulfilled.
    private(set) var count: Int = 0
    
    override func fulfill() {
        count += 1
        super.fulfill()
    }
}
