//
//  NSObjectTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/14/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
@testable import JiveJournal

class NSObjectTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDocumentsDirectory() {
        let directoryPath = documentsDirectory.lastPathComponent
        let directoryPathIsDocumentsDirectory = directoryPath == "Documents"
        XCTAssertTrue(directoryPathIsDocumentsDirectory)
    }

    func testClassName() {
        let classNameIsValid = className == "NSObjectTests"
        XCTAssertTrue(classNameIsValid)
    }
}
