//
//  UploadsControllerTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/14/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
@testable import JiveJournal

class UploadsControllerTests: XCTestCase {
    
    var sut: UploadsController!
    
    override func setUp() {
        sut = UploadsController()
    }
    
    // MARK: - Setters
    func testSetFilename() {
        let testFilename = "testfilename"
        sut.set(filename: testFilename)
        
        guard let sutURL = sut.url else {
            XCTFail("Failed to unwrap URL")
            return
        }
        
        let urlWasSet = sutURL == URLBuilder.getDocumentsFilePathURL(for: testFilename)
        XCTAssertTrue(urlWasSet)
    }
    
    func testSetURL() {
        let testURL = URL(string: "testfilename")!
        sut.set(url: testURL)
        
        guard let sutURL = sut.url else {
            XCTFail("Failed to unwrap URL")
            return
        }
        
        let urlWasSet = sutURL == testURL
        XCTAssertTrue(urlWasSet)
    }
    
    func testSetPracticeVideo() {
        let testFilename = "testfilename"
        let coreDataManager = CoreDataManager(modelName: "testModel")
        let video = PracticeVideo(context: coreDataManager.persistentContainer.viewContext)
        video.filename = testFilename
        
        sut.set(video: video)
        let url = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        
        guard let sutURL = sut.url else {
            XCTFail("Failed to unwrap URL")
            return
        }
        
        let urlWasSet = sutURL == url
        XCTAssertTrue(urlWasSet)
    }
    
    // MARK: - Thumbnail Retrieval
}
