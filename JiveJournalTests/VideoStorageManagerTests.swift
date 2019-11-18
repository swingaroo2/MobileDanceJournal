//
//  VideoStorageManagerTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/17/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
@testable import JiveJournal

class VideoStorageManagerTests: XCTestCase {

    let sut = VideoStorageManager()
    
    override func setUp() {
        Model.coreData = CoreDataManager(modelName: "VideoStorageManagerTests")
        guard let path = Bundle.main.path(forResource: "testVideo", ofType: "mov") else { return }
        guard let url = URL(string: path) else { return }
        let documentsURL = URLBuilder.getDocumentsFilePathURL(for: url.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: documentsURL.path) {
            try? FileManager.default.removeItem(at: documentsURL)
        }
    }
    
    // MARK: - Save tests
    func testSave() throws {
        let path = try XCTUnwrap(Bundle.main.path(forResource: "testVideo", ofType: "mov"))
        let url = try XCTUnwrap(URL(string: path))
        let documentsURL = URLBuilder.getDocumentsFilePathURL(for: url.lastPathComponent)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: documentsURL.path))
        
        do {
            try sut.saveVideo(url)
            XCTAssertTrue(FileManager.default.fileExists(atPath: documentsURL.path))
            try? FileManager.default.removeItem(at: documentsURL)
            XCTAssertFalse(FileManager.default.fileExists(atPath: documentsURL.path))
        } catch VideoStorageError.videoAlreadyExists {
            XCTFail("Video already exists")
        } catch {
            XCTFail("Failed to properly handle exception: \(error.localizedDescription)")
        }
    }
    
    func testSave_videoAlreadyExists() throws {
        let path = try XCTUnwrap(Bundle.main.path(forResource: "testVideo", ofType: "mov"))
        let url = try XCTUnwrap(URL(string: path))
        let documentsURL = URLBuilder.getDocumentsFilePathURL(for: url.lastPathComponent)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: documentsURL.path))
        
        do {
            XCTAssertFalse(FileManager.default.fileExists(atPath: documentsURL.path))
            try sut.saveVideo(url)
            XCTAssertTrue(FileManager.default.fileExists(atPath: documentsURL.path))
            try sut.saveVideo(url)
            XCTFail("VideoStorageError exception was not thrown")
        } catch VideoStorageError.videoAlreadyExists {
            XCTAssert(true)
        } catch {
            XCTFail("Failed to properly handle exception: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete tests
    func testDelete_withoutPracticeSession() throws {
        let path = try XCTUnwrap(Bundle.main.path(forResource: "testVideo", ofType: "mov"))
        let url = try XCTUnwrap(URL(string: path))
        let documentsURL = URLBuilder.getDocumentsFilePathURL(for: url.lastPathComponent)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: documentsURL.path))
        
        do {
            try sut.saveVideo(url)
            XCTAssertTrue(FileManager.default.fileExists(atPath: documentsURL.path))
            let video = createAndSaveTestPracticeVideo(filename: url.lastPathComponent)
            video.practiceSession = nil
            try sut.delete(video)
            XCTAssertFalse(FileManager.default.fileExists(atPath: documentsURL.path))
        } catch VideoStorageError.videoAlreadyExists {
            XCTFail("Video already exists")
        } catch {
            XCTFail("Failed to properly handle exception: \(error.localizedDescription)")
        }
    }
    
    func testDelete_withPracticeSession() throws {
        let path = try XCTUnwrap(Bundle.main.path(forResource: "testVideo", ofType: "mov"))
        let url = try XCTUnwrap(URL(string: path))
        let documentsURL = URLBuilder.getDocumentsFilePathURL(for: url.lastPathComponent)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: documentsURL.path))
        
        do {
            try sut.saveVideo(url)
            XCTAssertTrue(FileManager.default.fileExists(atPath: documentsURL.path))
            let video = createAndSaveTestPracticeVideo(filename: url.lastPathComponent)
            try sut.delete(video)
            XCTAssertFalse(FileManager.default.fileExists(atPath: documentsURL.path))
        } catch VideoStorageError.videoAlreadyExists {
            XCTFail("Video already exists")
        } catch {
            XCTFail("Failed to properly handle exception: \(error.localizedDescription)")
        }
    }
}

private extension VideoStorageManagerTests {
    func createAndSaveTestPracticeVideo(filename: String) -> PracticeVideo {
        let video = PracticeVideo(context: Model.coreData.persistentContainer.viewContext)
        video.filename = filename
        video.uploadDate = Date()
        video.title = "Test Video!"
        video.practiceSession = createAndSaveTestPracticeSession(video)
        Model.coreData.save()
        return video
    }
    
    func createAndSaveTestPracticeSession(_ video: PracticeVideo) -> PracticeSession {
        let practiceSession = PracticeSession(context: Model.coreData.persistentContainer.viewContext)
        practiceSession.date = Date()
        practiceSession.title = "Test Practice Session!"
        practiceSession.notes = "Notes!"
        practiceSession.addToVideos(video)
        return practiceSession
    }
}
