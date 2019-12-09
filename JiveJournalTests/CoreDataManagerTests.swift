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
    
    var sut = CoreDataManager(modelName: ModelConstants.modelName)
    
    override func setUp() {
        sut.wipe()
    }
    
    // MARK: - Fetching existing entities
    func testFetchPracticeSessionsInGroup() throws {
        addTestDataWithGroupedPracticeSession()
        
        let fetchedGroups = try XCTUnwrap(sut.groupFRC.fetchedObjects)
        
        let fetchedObjectsNotEmpty = fetchedGroups.count == 1
        XCTAssertTrue(fetchedObjectsNotEmpty)
        
        let group = fetchedGroups[0]
        let fetchedPracticeSessions = try XCTUnwrap(sut.fetchPracticeSessions(in: group))
        let fetchedPracticeSessionExists = fetchedPracticeSessions.count == 1
        XCTAssertTrue(fetchedPracticeSessionExists)
    }
    
    func testFetchPracticeSessionsInGroup_withValidExclusion() throws {
        let testPracticeSession = addTestDataWithGroupedPracticeSession()
        
        let fetchedGroups = try XCTUnwrap(sut.groupFRC.fetchedObjects)
        
        let fetchedObjectsNotEmpty = fetchedGroups.count == 1
        XCTAssertTrue(fetchedObjectsNotEmpty)
        
        let group = fetchedGroups[0]
        let fetchedPracticeSessions = try XCTUnwrap(sut.fetchPracticeSessions(in: group, excluding: testPracticeSession))
        let testPracticeSessionIsExcluded = !fetchedPracticeSessions.contains(testPracticeSession)
        XCTAssertTrue(testPracticeSessionIsExcluded)
    }
    
    func testFetchPracticeSessionsInGroup_withInvalidExclusion() throws {
        addTestDataWithGroupedPracticeSession()
        let invalidPracticeSession = addNewPracticeSession(index: 1, shouldSave: false)
        
        let fetchedGroups = try XCTUnwrap(sut.groupFRC.fetchedObjects)
        
        let fetchedObjectsNotEmpty = fetchedGroups.count == 1
        XCTAssertTrue(fetchedObjectsNotEmpty)
        
        let group = fetchedGroups[0]
        let fetchedPracticeSessions = try XCTUnwrap(sut.fetchPracticeSessions(in: group, excluding: invalidPracticeSession))
        let invalidPracticeSessionIsNotExcluded = !fetchedPracticeSessions.contains(invalidPracticeSession) && fetchedPracticeSessions.count == 1
        XCTAssertTrue(invalidPracticeSessionIsNotExcluded)
    }
    
    func testFetchUngroupedPracticeSessions() throws {
        addTestDataWithUngroupedPracticeSession()
        
        let fetchedPracticeSessions = try XCTUnwrap(sut.fetchPracticeSessions(in: nil))
        
        let fetchedPracticeSessionExists = fetchedPracticeSessions.count == 1
        XCTAssertTrue(fetchedPracticeSessionExists)
    }
    
    func testFetchUngroupedPracticeSessionsInGroup_withValidExclusion() throws {
        addTestDataWithUngroupedPracticeSession("test1")
        let testPracticeSession = addTestDataWithUngroupedPracticeSession("test2")
        let fetchedPracticeSessions = try XCTUnwrap(sut.fetchPracticeSessions(in: nil, excluding: testPracticeSession))
        let testPracticeSessionIsExcluded = !fetchedPracticeSessions.contains(testPracticeSession) && fetchedPracticeSessions.count == 1
        XCTAssertTrue(testPracticeSessionIsExcluded)
    }
    
    func testFetchUngroupedPracticeSessionsInGroup_withInvalidExclusion() throws {
        addTestDataWithUngroupedPracticeSession()
        let invalidPracticeSession = addNewPracticeSession(index: 1, shouldSave: false)
        let fetchedPracticeSessions = try XCTUnwrap(sut.fetchPracticeSessions(in: nil, excluding: invalidPracticeSession))
        let invalidPracticeSessionIsNotExcluded = !fetchedPracticeSessions.contains(invalidPracticeSession) && fetchedPracticeSessions.count == 1
        XCTAssertTrue(invalidPracticeSessionIsNotExcluded)
    }
    
    func testFetchVideosForPracticeSession_withFilename() throws {
        addTestDataWithUngroupedPracticeSession()
        
        let fetchedPracticeSessions = try XCTUnwrap(sut.fetchPracticeSessions(in: nil))
        let fetchedVideos = sut.fetchVideos(for: fetchedPracticeSessions[0], with: documentsDirectory.path)
        
        let videoWasFetched = fetchedVideos.count == 1
        XCTAssertTrue(videoWasFetched)
    }
    
    func testFetchVideosForPracticeSession_withoutFilename() throws {
        addTestDataWithUngroupedPracticeSession()
        
        let fetchedPracticeSessions = try XCTUnwrap(sut.fetchPracticeSessions(in: nil))
        let fetchedVideos = sut.fetchVideos(for: fetchedPracticeSessions[0])
        
        let videoWasFetched = fetchedVideos.count == 1
        XCTAssertTrue(videoWasFetched)
    }
    
    // MARK: - Saving
    func testSave() throws {
        let group = Group(context: sut.persistentContainer.viewContext)
        group.name = "\(#function)"
        group.dateCreated = Date()
        sut.save()
        
        let fetchedGroups = try XCTUnwrap(sut.groupFRC.fetchedObjects)
        let fetchedGroupExists = fetchedGroups[0]
        XCTAssertNotNil(fetchedGroupExists)
    }

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
    
    func testAddNewPracticeSessionToGroup() throws {
        let practiceSessions = [PracticeSession(context: sut.persistentContainer.viewContext)]
        let group = Group(context: sut.persistentContainer.viewContext)
        
        let groupPracticeSessions = try XCTUnwrap(group.practiceSessions)
        let groupHasNoPracticeSessions = groupPracticeSessions.count == 0
        XCTAssertTrue(groupHasNoPracticeSessions)
        
        sut.add(practiceSessions, to: group)
        
        let groupHasPracticeSessions = groupPracticeSessions.count == 1
        XCTAssertTrue(groupHasPracticeSessions)
    }
    
    func testAddPracticeSessionToGroup_duplicatePracticeSessions() throws {
        let practiceSessions = [PracticeSession(context: sut.persistentContainer.viewContext)]
        let group = Group(context: sut.persistentContainer.viewContext)
        
        let groupPracticeSessions = try XCTUnwrap(group.practiceSessions)
        
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
        
        sut.delete(video)
        XCTAssertTrue(practiceSessionHasNoVideos)
    }
    
    func testDeletePracticeSessionFromGroup() throws {
        let practiceSessions = [PracticeSession(context: sut.persistentContainer.viewContext)]
        let group = Group(context: sut.persistentContainer.viewContext)
        
        let groupPracticeSessions = try XCTUnwrap(group.practiceSessions)
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
        
        sut.move(video, to: newPracticeSession)
        XCTAssertTrue(oldPracticeSessionIsEmpty)
        
        let newPracticeSessionHasVideo = newPracticeSession.videos.count == 1
        XCTAssertTrue(newPracticeSessionHasVideo)
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
        
        sut.move([practiceSession], to: newGroup)
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
        
        sut.move([practiceSession, practiceSession2], to: newGroup)
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
        
        sut.move([], to: newGroup)
        XCTAssertTrue(oldGroupHasNoPracticeSessions)
        XCTAssertTrue(newGroupHasNoPracticeSessions)
    }
    
    // MARK: - Creating and fetching new entities
    func testCreateNewPracticeSession() throws {
        let newPracticeSession = sut.createAndReturnNewPracticeSession()
        XCTAssertNotNil(newPracticeSession)
        
        newPracticeSession.title = "test practice session"
        sut.save()
        
        let fetchedPracticeSessions = try XCTUnwrap(sut.practiceSessionFRC.fetchedObjects)
        let aPracticeSessionWasSaved = fetchedPracticeSessions.count == 1
        XCTAssertTrue(aPracticeSessionWasSaved)
        
        let originalPracticeSessionWasSaved = newPracticeSession == fetchedPracticeSessions[0]
        XCTAssertTrue(originalPracticeSessionWasSaved)
    }
    
    func testCreateNewPracticeVideo() throws {
        let newVideo = sut.createAndConfigureNewPracticeVideo(title: "test video", filename: documentsDirectory.path)
        XCTAssertNotNil(newVideo)
        
        let fetchedVideos = try XCTUnwrap(sut.practiceVideoFRC.fetchedObjects)
        
        let aVideoWasSaved = fetchedVideos.count == 1
        XCTAssertTrue(aVideoWasSaved)
        
        let originalVideoWasSaved = newVideo == fetchedVideos[0]
        XCTAssertTrue(originalVideoWasSaved)
    }
    
    func testCreateNewGroup() throws {
        sut.createAndSaveNewGroup(name: "test group", practiceSessions: [])
        
        let fetchedGroups = try XCTUnwrap(sut.groupFRC.fetchedObjects)
        let aGroupWasSaved = fetchedGroups.count == 1
        XCTAssertTrue(aGroupWasSaved)
        
        let originalGroupWasSaved = fetchedGroups[0].name == "test group"
        XCTAssertTrue(originalGroupWasSaved)
    }
    
    func testCreateNewGroup_nil() throws {
        sut.createAndSaveNewGroup(name: "test group", practiceSessions: nil)
        
        let fetchedGroups = try XCTUnwrap(sut.groupFRC.fetchedObjects)
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
    @discardableResult
    func addTestDataWithGroupedPracticeSession(_ title: String = "test practice session") -> PracticeSession {
        let video = PracticeVideo(context: sut.persistentContainer.viewContext)
        video.filename = documentsDirectory.path
        video.title = "test video"
        
        let practiceSession = PracticeSession(context: sut.persistentContainer.viewContext)
        practiceSession.title = title
        practiceSession.videos = NSSet(array: [video])
        
        sut.createAndSaveNewGroup(name: "test group", practiceSessions: [practiceSession])
        return practiceSession
    }
    
    @discardableResult
    func addTestDataWithUngroupedPracticeSession(_ title: String = "test practice session") -> PracticeSession {
        let video = PracticeVideo(context: sut.persistentContainer.viewContext)
        video.filename = documentsDirectory.path
        video.title = "test video"
        
        let practiceSession = PracticeSession(context: sut.persistentContainer.viewContext)
        practiceSession.title = "test practice session"
        practiceSession.videos = NSSet(array: [video])
        
        sut.save()
        return practiceSession
    }
    
    @discardableResult
    func addNewPracticeSession(index: Int, shouldSave: Bool = true) -> PracticeSession {
        let practiceSession = sut.createAndReturnNewPracticeSession()
        practiceSession.title = "testPracticeSession\(index)"
        practiceSession.notes = "Heckin' chonker #\(index)"
        
        if shouldSave {
            sut.save()
        }
        return practiceSession
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
