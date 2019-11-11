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
    let coreDataManager = (UIApplication.shared.delegate as! AppDelegate).coreDataManager!
    
    func testInitialization() {
        XCTAssertNotNil(sut.rootVC)
        XCTAssertNotNil(sut.childCoordinators)
        XCTAssertTrue(sut.childCoordinators.isEmpty)
        XCTAssertNotNil(sut.navigationController)
    }
    
    func testShowPracticeLog_withGroup() {
        let group = Group(context: coreDataManager.persistentContainer.viewContext)
        sut.showPracticeLog(group: group)
        XCTAssertTrue(sut.childCoordinators[0] is PracticeLogCoordinator)
    }
    
    func testShowPracticeLog_withoutGroup() {
        sut.showPracticeLog(group: nil)
        XCTAssertTrue(sut.childCoordinators[0] is PracticeLogCoordinator)
    }
    
    func testStartEditing_withGroup() {}
    func testStartEditing_withoutGroup() {}

}
