//
//  ServicesTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/14/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
@testable import JiveJournal

class ServicesTests: XCTestCase {

    let sut = Services()
    
    func testServicesExist() {
        XCTAssertNotNil(Services.activity)
        XCTAssertNotNil(Services.permissions)
        XCTAssertNotNil(Services.uploads)
    }

}
