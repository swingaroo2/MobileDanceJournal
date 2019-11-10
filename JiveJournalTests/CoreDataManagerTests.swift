//
//  CoreDataManagerTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/9/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
import CoreData
@testable import JiveJournal

class CoreDataManagerTests: XCTestCase {

    var sut = CoreDataManager(modelName: "testModel")
    
    override func setUp() {
        sut.wipe()
    }

    // MARK: - Fetching existing entities
    func testFetchPracticeSessionsInGroup() {
        addTestDataWithGroupedPracticeSession()
        
        guard let fetchedGroups = sut.groupFRC.fetchedObjects else {
            XCTFail("Fetched group is nil")
            return
        }
        
        let fetchedObjectsNotEmpty = fetchedGroups.count == 1
        XCTAssertTrue(fetchedObjectsNotEmpty)
        
        let group = fetchedGroups[0]
        guard let fetchedPracticeSessions = sut.fetchPracticeSessions(in: group) else {
            XCTFail("Fetched practice sessions are nil")
            return
        }
        
        let fetchedPracticeSessionExists = fetchedPracticeSessions.count == 1
        XCTAssertTrue(fetchedPracticeSessionExists)
    }
    
    func testFetchUngroupedPracticeSessions() {
        addTestDataWithUngroupedPracticeSession()
        
        guard let fetchedPracticeSessions = sut.fetchPracticeSessions(in: nil) else {
            XCTFail("Fetched practice sessions are nil")
            return
        }
        
        let fetchedPracticeSessionExists = fetchedPracticeSessions.count == 1
        XCTAssertTrue(fetchedPracticeSessionExists)
    }
    
    func testFetchVideosForPracticeSession_withFilename() {
        addTestDataWithUngroupedPracticeSession()
        
        guard let fetchedPracticeSessions = sut.fetchPracticeSessions(in: nil) else {
            XCTFail("Fetched practice sessions are nil")
            return
        }
        
        let fetchedVideos = sut.fetchVideos(for: fetchedPracticeSessions[0], with: documentsDirectory.path)
        
        let videoWasFetched = fetchedVideos.count == 1
        XCTAssertTrue(videoWasFetched)
    }
    
    func testFetchVideosForPracticeSession_withoutFilename() {
        addTestDataWithUngroupedPracticeSession()
        
        guard let fetchedPracticeSessions = sut.fetchPracticeSessions(in: nil) else {
            XCTFail("Fetched practice sessions are nil")
            return
        }
        
        let fetchedVideos = sut.fetchVideos(for: fetchedPracticeSessions[0])
        
        let videoWasFetched = fetchedVideos.count == 1
        XCTAssertTrue(videoWasFetched)
    }
    
    // MARK: - Saving
    func testSave() {
        let group = Group(context: sut.persistentContainer.viewContext)
        group.name = "\(#function)"
        
        sut.save()
        
        guard let fetchedGroups = sut.groupFRC.fetchedObjects else {
            XCTFail("Fetched groups is nil")
            return
        }
        
        let fetchedGroupExists = fetchedGroups[0]
        XCTAssertNotNil(fetchedGroupExists)
    }
    
    // TODO: Why did my delete test fail? It works fine in the app...
    
    // MARK: - Relationships
    func testAddVideoToPracticeSession() {
        let video = PracticeVideo(context: sut.persistentContainer.viewContext)
        let practiceSession = PracticeSession(context: sut.persistentContainer.viewContext)
        
        let practiceSessionHasNoVideos = practiceSession.videos.count == 0
        XCTAssertTrue(practiceSessionHasNoVideos)
        
        sut.add(video, to: practiceSession)
        let practiceSessionHasOneVideo = practiceSession.videos.count == 1
        XCTAssertTrue(practiceSessionHasOneVideo)
    }
    
    func testAddVideoToPracticeSession_duplicateVideos() {
        let video = PracticeVideo(context: sut.persistentContainer.viewContext)
        let practiceSession = PracticeSession(context: sut.persistentContainer.viewContext)
        
        let practiceSessionHasNoVideos = practiceSession.videos.count == 0
        XCTAssertTrue(practiceSessionHasNoVideos)
        
        sut.add(video, to: practiceSession)
        sut.add(video, to: practiceSession)
        let practiceSessionHasOneVideo = practiceSession.videos.count == 1
        XCTAssertTrue(practiceSessionHasOneVideo)
    }
    
    func testAddNewPracticeSessionToGroup() {
        let practiceSessions = [PracticeSession(context: sut.persistentContainer.viewContext)]
        let group = Group(context: sut.persistentContainer.viewContext)
        
        guard let groupPracticeSessions = group.practiceSessions else {
            XCTFail("Fetched practice sessions are nil")
            return
        }
        
        let groupHasNoPracticeSessions = groupPracticeSessions.count == 0
        XCTAssertTrue(groupHasNoPracticeSessions)
        
        sut.add(practiceSessions, to: group)
        
        
        let groupHasPracticeSessions = groupPracticeSessions.count == 1
        XCTAssertTrue(groupHasPracticeSessions)
    }
    
    // MARK: - Creating and fetching new entities
    func testCreateNewGroup() {
        sut.createAndSaveNewGroup(name: "test group", practiceSessions: [])
        
        guard let fetchedGroups = sut.groupFRC.fetchedObjects else {
            XCTFail("Fetched groups are nil")
            return
        }
        
        let aGroupWasSaved = fetchedGroups.count == 1
        XCTAssertTrue(aGroupWasSaved)
        
        let originalGroupWasSaved = fetchedGroups[0].name == "test group"
        XCTAssertTrue(originalGroupWasSaved)
    }
    
    func testCreateNewPracticeSession() {
        let newPracticeSession = sut.createAndReturnNewPracticeSession()
        XCTAssertNotNil(newPracticeSession)
        
        newPracticeSession.title = "test practice session"
        sut.save()
        
        guard let fetchedPracticeSessions = sut.practiceSessionFRC.fetchedObjects else {
            XCTFail("Fetched practice sessions are nil")
            return
        }
        
        let aPracticeSessionWasSaved = fetchedPracticeSessions.count == 1
        XCTAssertTrue(aPracticeSessionWasSaved)
        
        let originalPracticeSessionWasSaved = newPracticeSession == fetchedPracticeSessions[0]
        XCTAssertTrue(originalPracticeSessionWasSaved)
    }
    
    func testCreateNewPracticeVideo() {
        let newVideo = sut.createAndConfigureNewPracticeVideo(title: "test video", filename: documentsDirectory.path)
        XCTAssertNotNil(newVideo)
        
        guard let fetchedVideos = sut.practiceVideoFRC.fetchedObjects else {
            XCTFail("Fetched practice videos are nil")
            return
        }
        
        let aVideoWasSaved = fetchedVideos.count == 1
        XCTAssertTrue(aVideoWasSaved)
        
        let originalVideoWasSaved = newVideo == fetchedVideos[0]
        XCTAssertTrue(originalVideoWasSaved)
    }
    
}

private extension CoreDataManagerTests {
    func addTestDataWithGroupedPracticeSession() {
        let video = PracticeVideo(context: sut.persistentContainer.viewContext)
        video.filename = documentsDirectory.path
        video.title = "test video"
        
        let practiceSession = PracticeSession(context: sut.persistentContainer.viewContext)
        practiceSession.title = "test practice session"
        practiceSession.videos = NSSet(array: [video])
        
        sut.createAndSaveNewGroup(name: "test group", practiceSessions: [practiceSession])
    }
    
    func addTestDataWithUngroupedPracticeSession() {
        let video = PracticeVideo(context: sut.persistentContainer.viewContext)
        video.filename = documentsDirectory.path
        video.title = "test video"
        
        let practiceSession = PracticeSession(context: sut.persistentContainer.viewContext)
        practiceSession.title = "test practice session"
        practiceSession.videos = NSSet(array: [video])
        
        sut.save()
    }
    
    func addNewPracticeSession(with index: Int) {
        let practiceSession = sut.createAndReturnNewPracticeSession()
        practiceSession.title = "testPracticeSession\(index)"
        practiceSession.notes = "Heckin' chonker #\(index)"
        sut.save()
    }
}
