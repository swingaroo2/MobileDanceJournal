//
//  DateTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/14/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
@testable import JiveJournal

class DateTests: XCTestCase {
    
    var testDate: Date!
    
    override func setUp() {
        testDate = createTestDate(year: 1992, day: 23, month: 2)
    }
    
    // MARK: - Date -> String Tests
    func testGetStringFromDate_longFormat() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "'Started' MMMM dd, yyyy 'at' h:mm:ss.SSSS a"
        let expectedString = dateFormatter.string(from: testDate)
        
        let actualString = Date.getStringFromDate(testDate, .longFormat)
        let expectedStringMatchesActualString = expectedString == actualString
        XCTAssertTrue(expectedStringMatchesActualString)
    }
    
    func testGetStringFromDate_notepadDisplayFormat() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "'Started' MMMM dd, yyyy"
        let expectedString = dateFormatter.string(from: testDate)
        
        let actualString = Date.getStringFromDate(testDate, .notepadDisplayFormat)
        let expectedStringMatchesActualString = expectedString == actualString
        XCTAssertTrue(expectedStringMatchesActualString)
    }
    func testGetStringFromDate_practiceLogDisplayFormat() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd/yyyy"
        let expectedString = dateFormatter.string(from: testDate)
        
        let actualString = Date.getStringFromDate(testDate, .practiceLogDisplayFormat)
        let expectedStringMatchesActualString = expectedString == actualString
        XCTAssertTrue(expectedStringMatchesActualString)
    }

    // MARK: - String -> Date Tests
    func testGetDateFromString() {
        let referenceDate = createTestDate(year: 1992, day: 23, month: 2)
        let dateText = Date.getStringFromDate(referenceDate, .longFormat)
        let date = Date.getDateFromString(dateText)
        
        guard let unwrapped = date else {
            XCTFail("Failed to unwrap date")
            return
        }
        
        let convertedDateMatchesReferenceDate = referenceDate == unwrapped
        XCTAssertTrue(convertedDateMatchesReferenceDate)
    }
}

private extension DateTests {
    func createTestDate(year: Int, day: Int, month: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components)!
    }
}
