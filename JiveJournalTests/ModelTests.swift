//
//  ModelTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/16/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
@testable import JiveJournal

class ModelTests: XCTestCase {
    
    override func setUp() {
        Model.start()
    }
    
    func testModelsExist() {
        XCTAssertNotNil(Model.coreData)
        XCTAssertNotNil(Model.videoStorage)
    }
}
