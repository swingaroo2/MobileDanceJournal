//
//  AppDelegateTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/9/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
import Firebase
@testable import JiveJournal

class AppDelegateTests: XCTestCase {

    let sut = UIApplication.shared.delegate as! AppDelegate

    func testAppLaunch() {
        XCTAssertNotNil(FirebaseApp.app())
        XCTAssertNotNil(sut.coordinator)
        XCTAssertNotNil(sut.coreDataManager)
        XCTAssertNotNil(sut.window)
    }

}
