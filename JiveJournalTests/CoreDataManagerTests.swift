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
    
    func testAddPracticeSessionToGroup_duplicatePracticeSessions() {
        let practiceSessions = [PracticeSession(context: sut.persistentContainer.viewContext)]
        let group = Group(context: sut.persistentContainer.viewContext)
        
        guard let groupPracticeSessions = group.practiceSessions else {
            XCTFail("Fetched practice sessions are nil")
            return
        }
        
        let groupHasNoPracticeSessions = groupPracticeSessions.count == 0
        XCTAssertTrue(groupHasNoPracticeSessions)
        
        sut.add(practiceSessions, to: group)
        sut.add(practiceSessions, to: group)
        
        let groupHasPracticeSessions = groupPracticeSessions.count == 1
        XCTAssertTrue(groupHasPracticeSessions)
    }
    
    func testDeletePracticeVideoFromPracticeSession() {
        let video = PracticeVideo(context: sut.persistentContainer.viewContext)
        let practiceSession = PracticeSession(context: sut.persistentContainer.viewContext)
        
        let practiceSessionHasNoVideos = practiceSession.videos.count == 0
        XCTAssertTrue(practiceSessionHasNoVideos)
        
        sut.add(video, to: practiceSession)
        
        let practiceSessionHasOneVideo = practiceSession.videos.count == 1
        XCTAssertTrue(practiceSessionHasOneVideo)
        
        sut.delete(video, from: practiceSession)
        XCTAssertTrue(practiceSessionHasNoVideos)
    }
    
    func testDeletePracticeSessionFromGroup() {
        let practiceSessions = [PracticeSession(context: sut.persistentContainer.viewContext)]
        let group = Group(context: sut.persistentContainer.viewContext)
        
        guard let groupPracticeSessions = group.practiceSessions else {
            XCTFail("Fetched practice sessions are nil")
            return
        }
        
        var groupHasNoPracticeSessions = groupPracticeSessions.count == 0
        XCTAssertTrue(groupHasNoPracticeSessions)
        
        sut.add(practiceSessions, to: group)
        
        let groupHasPracticeSessions = groupPracticeSessions.count == 1
        XCTAssertTrue(groupHasPracticeSessions)
        
        sut.delete(practiceSessions[0], from: group)
        
        groupHasNoPracticeSessions = groupPracticeSessions.count == 0
        XCTAssertTrue(groupHasNoPracticeSessions)
    }
    
    func testMoveVideoToNewPracticeSession() {
        let oldPracticeSession = PracticeSession(context: sut.persistentContainer.viewContext)
        let newPracticeSession = PracticeSession(context: sut.persistentContainer.viewContext)
        let video = PracticeVideo(context: sut.persistentContainer.viewContext)
        
        let oldPracticeSessionIsEmpty = oldPracticeSession.videos.count == 0
        let newPracticeSessionIsEmpty = newPracticeSession.videos.count == 0
        
        XCTAssertTrue(oldPracticeSessionIsEmpty)
        XCTAssertTrue(newPracticeSessionIsEmpty)
        
        oldPracticeSession.addToVideos(video)
        let oldPracticeSessionHasVideo = oldPracticeSession.videos.count == 1
        XCTAssertTrue(oldPracticeSessionHasVideo)
        
        sut.move([video], from: oldPracticeSession, to: newPracticeSession)
        XCTAssertTrue(oldPracticeSessionIsEmpty)
        
        let newPracticeSessionHasVideo = newPracticeSession.videos.count == 1
        XCTAssertTrue(newPracticeSessionHasVideo)
    }
    
    func testMoveVideosToNewPracticeSession() {
        let oldPracticeSession = PracticeSession(context: sut.persistentContainer.viewContext)
        let newPracticeSession = PracticeSession(context: sut.persistentContainer.viewContext)
        let video = PracticeVideo(context: sut.persistentContainer.viewContext)
        let video2 = PracticeVideo(context: sut.persistentContainer.viewContext)
        
        let oldPracticeSessionIsEmpty = oldPracticeSession.videos.count == 0
        let newPracticeSessionIsEmpty = newPracticeSession.videos.count == 0
        
        XCTAssertTrue(oldPracticeSessionIsEmpty)
        XCTAssertTrue(newPracticeSessionIsEmpty)
        
        oldPracticeSession.addToVideos(video)
        oldPracticeSession.addToVideos(video2)
        let oldPracticeSessionHasVideos = oldPracticeSession.videos.count == 2
        XCTAssertTrue(oldPracticeSessionHasVideos)
        
        sut.move([video, video2], from: oldPracticeSession, to: newPracticeSession)
        XCTAssertTrue(oldPracticeSessionIsEmpty)
        
        let newPracticeSessionHasVideos = newPracticeSession.videos.count == 2
        XCTAssertTrue(newPracticeSessionHasVideos)
    }
    
    func testMoveEmptyArrayOfVideosToNewPracticeSession() {
        let oldPracticeSession = PracticeSession(context: sut.persistentContainer.viewContext)
        let newPracticeSession = PracticeSession(context: sut.persistentContainer.viewContext)
        
        let oldPracticeSessionHasNoVideos = oldPracticeSession.videos.count == 0
        let newPracticeSessionHasNoVideos = newPracticeSession.videos.count == 0
        
        XCTAssertTrue(oldPracticeSessionHasNoVideos)
        XCTAssertTrue(newPracticeSessionHasNoVideos)
        
        sut.move([], from: oldPracticeSession, to: newPracticeSession)
        XCTAssertTrue(oldPracticeSessionHasNoVideos)
    }
    
    func testMovePracticeSessionToNewGroup() {
        let practiceSession = PracticeSession(context: sut.persistentContainer.viewContext)
        let oldGroup = Group(context: sut.persistentContainer.viewContext)
        let newGroup = Group(context: sut.persistentContainer.viewContext)
        
        let oldGroupIsNotNil = oldGroup.practiceSessions != nil
        let newGroupIsNotNil = newGroup.practiceSessions != nil
        XCTAssertTrue(oldGroupIsNotNil)
        XCTAssertTrue(newGroupIsNotNil)
        
        let oldGroupHasNoPracticeSessions = oldGroup.practiceSessions!.count == 0
        let newGroupHasNoPracticeSessions = newGroup.practiceSessions!.count == 0
        XCTAssertTrue(oldGroupHasNoPracticeSessions)
        XCTAssertTrue(newGroupHasNoPracticeSessions)
        
        oldGroup.addToPracticeSessions(practiceSession)
        let oldGroupHasPracticeSession = oldGroup.practiceSessions!.count == 1
        XCTAssertTrue(oldGroupHasPracticeSession)
        
        sut.move([practiceSession], from: oldGroup, to: newGroup)
        let newGroupHasPracticeSession = newGroup.practiceSessions!.count == 1
        XCTAssertTrue(oldGroupHasNoPracticeSessions)
        XCTAssertTrue(newGroupHasPracticeSession)
    }
    
    func testMovePracticeSessionsToNewGroup() {
        let practiceSession = PracticeSession(context: sut.persistentContainer.viewContext)
        let practiceSession2 = PracticeSession(context: sut.persistentContainer.viewContext)
        let oldGroup = Group(context: sut.persistentContainer.viewContext)
        let newGroup = Group(context: sut.persistentContainer.viewContext)
        
        let oldGroupIsNotNil = oldGroup.practiceSessions != nil
        let newGroupIsNotNil = newGroup.practiceSessions != nil
        XCTAssertTrue(oldGroupIsNotNil)
        XCTAssertTrue(newGroupIsNotNil)
        
        let oldGroupHasNoPracticeSessions = oldGroup.practiceSessions!.count == 0
        let newGroupHasNoPracticeSessions = newGroup.practiceSessions!.count == 0
        XCTAssertTrue(oldGroupHasNoPracticeSessions)
        XCTAssertTrue(newGroupHasNoPracticeSessions)
        
        oldGroup.addToPracticeSessions(practiceSession)
        oldGroup.addToPracticeSessions(practiceSession2)
        let oldGroupHasPracticeSession = oldGroup.practiceSessions!.count == 2
        XCTAssertTrue(oldGroupHasPracticeSession)
        
        sut.move([practiceSession, practiceSession2], from: oldGroup, to: newGroup)
        let newGroupHasPracticeSession = newGroup.practiceSessions!.count == 2
        XCTAssertTrue(oldGroupHasNoPracticeSessions)
        XCTAssertTrue(newGroupHasPracticeSession)
    }
    
    func testMoveEmptyArrayOfPracticeSessionsToNewGroup() {
        let oldGroup = Group(context: sut.persistentContainer.viewContext)
        let newGroup = Group(context: sut.persistentContainer.viewContext)
        
        let oldGroupIsNotNil = oldGroup.practiceSessions != nil
        let newGroupIsNotNil = newGroup.practiceSessions != nil
        XCTAssertTrue(oldGroupIsNotNil)
        XCTAssertTrue(newGroupIsNotNil)
        
        let oldGroupHasNoPracticeSessions = oldGroup.practiceSessions!.count == 0
        let newGroupHasNoPracticeSessions = newGroup.practiceSessions!.count == 0
        XCTAssertTrue(oldGroupHasNoPracticeSessions)
        XCTAssertTrue(newGroupHasNoPracticeSessions)
        
        sut.move([], from: oldGroup, to: newGroup)
        XCTAssertTrue(oldGroupHasNoPracticeSessions)
        XCTAssertTrue(newGroupHasNoPracticeSessions)
    }
    
    // MARK: - Creating and fetching new entities
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
    
    func testUpdateGroupWithPracticeSessions_unnamedGroup() {
        let group = Group(context: sut.persistentContainer.viewContext)
        let practiceSessionToAdd = PracticeSession(context: sut.persistentContainer.viewContext)
        
        let groupHasNoName = group.name.isEmpty
        let groupPracticeSessionsIsNotNil = group.practiceSessions != nil
        let groupHasNoPracticeSessions = group.practiceSessions!.count == 0
        XCTAssertTrue(groupHasNoName)
        XCTAssertTrue(groupPracticeSessionsIsNotNil)
        XCTAssertTrue(groupHasNoPracticeSessions)
        
        sut.update(group: group, name: "test group", practiceSessions: [practiceSessionToAdd])
        let groupHasName = group.name == "test group"
        let groupHasPracticeSession = group.practiceSessions!.count == 1
        XCTAssertTrue(groupHasName)
        XCTAssertTrue(groupHasPracticeSession)
    }
    
    func testUpdateGroupWithPracticeSessions_renamedGroup() {
        let group = Group(context: sut.persistentContainer.viewContext)
        group.name = "original name"
        let practiceSessionToAdd = PracticeSession(context: sut.persistentContainer.viewContext)
        
        let groupHasOriginalName = group.name == "original name"
        let groupPracticeSessionsIsNotNil = group.practiceSessions != nil
        let groupHasNoPracticeSessions = group.practiceSessions!.count == 0
        XCTAssertTrue(groupHasOriginalName)
        XCTAssertTrue(groupPracticeSessionsIsNotNil)
        XCTAssertTrue(groupHasNoPracticeSessions)
        
        sut.update(group: group, name: "test group", practiceSessions: [practiceSessionToAdd])
        let groupWasRenamed = group.name == "test group"
        let groupHasPracticeSession = group.practiceSessions!.count == 1
        XCTAssertTrue(groupWasRenamed)
        XCTAssertTrue(groupHasPracticeSession)
    }
    
    func testUpdateGroupWithPracticeSessions_nilPracticeSessions() {
        let group = Group(context: sut.persistentContainer.viewContext)
        
        let groupHasNoName = group.name.isEmpty
        let groupPracticeSessionsIsNotNil = group.practiceSessions != nil
        let groupHasNoPracticeSessions = group.practiceSessions!.count == 0
        XCTAssertTrue(groupHasNoName)
        XCTAssertTrue(groupPracticeSessionsIsNotNil)
        XCTAssertTrue(groupHasNoPracticeSessions)
        
        sut.update(group: group, name: "test group", practiceSessions: nil)
        let groupHasName = group.name == "test group"
        XCTAssertTrue(groupHasName)
        XCTAssertTrue(groupPracticeSessionsIsNotNil)
        XCTAssertTrue(groupHasNoPracticeSessions)
    }
    
    func testUpdateGroupWithPracticeSessions_emptyPracticeSessions() {
        let group = Group(context: sut.persistentContainer.viewContext)
        
        let groupHasNoName = group.name.isEmpty
        let groupPracticeSessionsIsNotNil = group.practiceSessions != nil
        let groupHasNoPracticeSessions = group.practiceSessions!.count == 0
        XCTAssertTrue(groupHasNoName)
        XCTAssertTrue(groupPracticeSessionsIsNotNil)
        XCTAssertTrue(groupHasNoPracticeSessions)
        
        sut.update(group: group, name: "test group", practiceSessions: [])
        let groupHasName = group.name == "test group"
        XCTAssertTrue(groupHasName)
        XCTAssertTrue(groupPracticeSessionsIsNotNil)
        XCTAssertTrue(groupHasNoPracticeSessions)
    }
}

// MARK: - Private helper functions
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

// MARK: - Testing functions
private extension CoreDataManager {
    func wipe() {
        Log.trace()
        deleteAllData(GroupConstants.managedObject)
        deleteAllData(PracticeSessionConstants.managedObject)
        deleteAllData(PracticeVideoConstants.managedObject)
    }
    
    func deleteAllData(_ entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                persistentContainer.viewContext.delete(objectData)
            }
            Log.trace("Successfully wiped data for entity: \(entityName)")
        } catch let error {
            Log.error("Delete all data in \(entityName) error :\(error.localizedDescription)")
        }
    }
}
