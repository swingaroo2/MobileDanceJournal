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
    let coreDataManager = CoreDataManager(modelName: "uploadsControllerTestsModel")
    
    override func setUp() {
        sut = UploadsController()
    }
    
    // MARK: - Setters
    func testSetFilename() throws {
        let testFilename = "testfilename"
        sut.set(filename: testFilename)
        
        let sutURL = try XCTUnwrap(sut.url)
        let urlWasSet = sutURL == URLBuilder.getDocumentsFilePathURL(for: testFilename)
        XCTAssertTrue(urlWasSet)
    }
    
    func testSetURL() throws {
        let testURL = URL(string: "testfilename")!
        sut.set(url: testURL)
        
        let sutURL = try XCTUnwrap(sut.url)
        let urlWasSet = sutURL == testURL
        XCTAssertTrue(urlWasSet)
    }
    
    func testSetPracticeVideo() throws {
        let testFilename = "testfilename"
        let video = PracticeVideo(context: coreDataManager.persistentContainer.viewContext)
        video.filename = testFilename
        
        sut.set(video: video)
        let url = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        
        let sutURL = try XCTUnwrap(sut.url)
        let urlWasSet = sutURL == url
        XCTAssertTrue(urlWasSet)
    }
    
    func testSetPracticeVideo_nil() {
        sut.set(video: nil)
        XCTAssertNil(sut.video)
    }
    
    // MARK: - Thumbnail Retrieval
    func testGetThumbnail_fromURL() throws {
        let path = try XCTUnwrap(Bundle.main.path(forResource: "testVideo", ofType: "mov"))
        let url = try XCTUnwrap(URL(string: path))
        sut.set(url: url)
        sut.getThumbnail(from: url) { image in
            DispatchQueue.main.async {
                XCTAssertNotNil(image)
            }
        }
    }
    
    func testGetThumbnail_fromPracticeVideo() throws {
        let path = try XCTUnwrap(Bundle.main.path(forResource: "testVideo", ofType: "mov"))
        let url = try XCTUnwrap(URL(string: path))
        
        let video = PracticeVideo(context: coreDataManager.persistentContainer.viewContext)
        video.filename = url.lastPathComponent
        
        let documentsFilePath = URLBuilder.getDocumentsFilePathURL(for: video.filename).path
        if FileManager.default.fileExists(atPath: documentsFilePath) {
            try? FileManager.default.removeItem(atPath: documentsFilePath)
        }
        
        try? Model.videoStorage.saveVideo(url)
        
        let _ = try XCTUnwrap(sut.getThumbnail(video))
    }
    
    func testGetThumbnail_fromPracticeVideo_nilResult() throws {
        let video = PracticeVideo(context: coreDataManager.persistentContainer.viewContext)
        XCTAssertNil(sut.getThumbnail(video))
    }
}
