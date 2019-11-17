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
    func testModelsExist() {
        XCTAssertNotNil(Model.coreData)
        XCTAssertNotNil(Model.videoFileStorage)
    }
}
