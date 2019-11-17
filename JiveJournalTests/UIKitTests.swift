//
//  UIKitTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/16/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
@testable import JiveJournal

class UIKitTests: XCTestCase {

    var practiceSession: PracticeSession!
    let coreDataManager = CoreDataManager(modelName: "uikitTestsModel")

    override func setUp() {
        practiceSession = createTestPracticeSession()
    }
    
    // MARK: - UIWindow Tests
    func testCreateNewWindow() {
        let rootViewController = UIViewController()
        let window = UIWindow.createNewWindow(with: rootViewController)
        XCTAssertNotNil(window)
        XCTAssertNotNil(window.rootViewController)
        XCTAssertTrue(window.rootViewController == rootViewController)
        XCTAssertTrue(window.frame == UIScreen.main.bounds)
        XCTAssertTrue(window.isKeyWindow)
    }
    
    // MARK: - UITextView Tests
    func testConfigure_uiTextView_date() {
        let textView = UITextView()
        textView.configure(with: practiceSession, for: PracticeSessionConstants.date)
        XCTAssertTrue(textView.text == "")
    }
    
    func testConfigure_uiTextView_notes() {
        let textView = UITextView()
        textView.configure(with: practiceSession, for: PracticeSessionConstants.title)
        XCTAssertTrue(textView.text == practiceSession.title)
    }
    
    func testConfigure_uiTextView_title() {
        let textView = UITextView()
        textView.configure(with: practiceSession, for: PracticeSessionConstants.notes)
        XCTAssertTrue(textView.text == practiceSession.notes)
    }
    
    // MARK: - UITextField Tests
    func testConfigure_uiTextField_date() {
        let textField = UITextField()
        textField.configure(with: practiceSession, for: PracticeSessionConstants.date)
        let expectedDateText = Date.getStringFromDate(practiceSession.date, .longFormat)
        XCTAssertTrue(textField.text == expectedDateText)
    }
    
    func testConfigure_uiTextField_notes() {
        let textField = UITextField()
        textField.configure(with: practiceSession, for: PracticeSessionConstants.notes)
        XCTAssertTrue(textField.text == practiceSession.notes)
    }
    
    func testConfigure_uiTextField_title() {
        let textField = UITextField()
        textField.configure(with: practiceSession, for: PracticeSessionConstants.title)
        XCTAssertTrue(textField.text == practiceSession.title)
    }
    
    // MARK: - UILabel Tests
    func testConfigure_uiLabel_date() {
        let label = UILabel()
        label.configure(with: practiceSession, for: PracticeSessionConstants.date)
        let expectedDateText = Date.getStringFromDate(practiceSession.date, .notepadDisplayFormat)
        XCTAssertTrue(label.text == expectedDateText)
    }
    
    func testConfigure_uiLabel_notes() {
        let label = UILabel()
        label.configure(with: practiceSession, for: PracticeSessionConstants.notes)
        XCTAssertTrue(label.text == practiceSession.notes)
    }
    
    func testConfigure_uiLabel_title() {
        let label = UILabel()
        label.configure(with: practiceSession, for: PracticeSessionConstants.title)
        XCTAssertTrue(label.text == practiceSession.title)
    }

    // MARK: - UIImageView Tests
    func testSetThumbnail_url() throws {
        let path = try XCTUnwrap(Bundle.main.path(forResource: "testVideo", ofType: "mov"))
        let url = try XCTUnwrap(URL(string: path))
        let imageView = UIImageView()
        imageView.setThumbnail(url)
        
        Services.uploads.getThumbnail(from: url) { cachedImage in
            DispatchQueue.main.async {
                XCTAssertTrue(imageView.image == cachedImage)
            }
        }
    }
}

private extension UIKitTests {
    func createTestPracticeSession() -> PracticeSession {
        let practiceSession = PracticeSession(context: coreDataManager.persistentContainer.viewContext)
        practiceSession.date = createTestDate(year: 1992, day: 23, month: 2)
        practiceSession.title = "Practice Session"
        practiceSession.notes = "I HAVE NOTED MY NOTES"
        
        return practiceSession
    }
    
    func createTestDate(year: Int, day: Int, month: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components)!
    }
}
