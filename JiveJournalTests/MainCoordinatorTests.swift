//
//  MainCoordinatorTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/10/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
@testable import JiveJournal

class MainCoordinatorTests: XCTestCase {

    let sut = (UIApplication.shared.delegate as! AppDelegate).coordinator!
    
    override func setUp() {
        print()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitialization() {
        XCTAssertNotNil(sut.rootVC)
        XCTAssertNotNil(sut.childCoordinators)
        XCTAssertTrue(sut.childCoordinators.isEmpty)
        XCTAssertNotNil(sut.navigationController)
    }

}
