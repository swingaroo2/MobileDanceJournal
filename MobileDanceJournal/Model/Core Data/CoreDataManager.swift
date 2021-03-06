//
//  CoreDataManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class CoreDataManager : NSObject {
    
    private let modelName: String
    
    weak var practiceVideoDelegate: NSFetchedResultsControllerDelegate? {
        willSet {
            self.practiceVideoFRC.delegate = newValue
        }
    }
    
    weak var practiceGroupsDelegate: NSFetchedResultsControllerDelegate? {
        willSet {
            self.groupFRC.delegate = newValue
        }
    }
    
    init(modelName: String) {
        Log.trace("Initializing CoreData model: \(modelName)")
        self.modelName = modelName
    }
    
    // MARK: FRCs
    lazy var groupFRC: NSFetchedResultsController<Group> = {
        Log.trace()
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: GroupConstants.dateCreated, ascending: false),
                                        NSSortDescriptor(key: GroupConstants.name, ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: persistentContainer.viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    lazy var practiceSessionFRC: NSFetchedResultsController<PracticeSession> = {
        Log.trace()
        let fetchRequest: NSFetchRequest<PracticeSession> = PracticeSession.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: PracticeSessionConstants.date, ascending: false),
                                        NSSortDescriptor(key: PracticeSessionConstants.title, ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: persistentContainer.viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    lazy var practiceVideoFRC: NSFetchedResultsController<PracticeVideo> = {
        Log.trace()
        let fetchRequest: NSFetchRequest<PracticeVideo> = PracticeVideo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: PracticeVideoConstants.uploadDate, ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: persistentContainer.viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    // MARK: Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        Log.trace()
        let container = NSPersistentContainer(name: ModelConstants.modelName)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                Log.critical("Unresolved error \(error), \(error.userInfo)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        return container
    }()
}

// MARK: - Fetch/Save/Delete
extension CoreDataManager {
    
    // MARK: Custom Fetching
    func fetchPracticeSessions(in group: Group?, excluding: PracticeSession? = nil) -> [PracticeSession]? {
        Log.trace()
        practiceSessionFRC.fetchRequest.predicate = (group != nil) ? NSPredicate(format: Predicates.hasGroup, group!) : NSPredicate(format: Predicates.hasNoGroup)
        
        try? practiceSessionFRC.performFetch()
        let fetchedPracticeSessions = practiceSessionFRC.fetchedObjects
        
        // Ensure excluding is non-nil
        guard let excludedPracticeSession = excluding, var fetchedObjects = fetchedPracticeSessions else {
            return fetchedPracticeSessions
        }
        
        // Ensure excluding exists in the array of fetched objects
        guard let excludeIndex = fetchedObjects.firstIndex(of: excludedPracticeSession) else {
            return fetchedPracticeSessions
        }
        
        Log.trace("Excluding Practice Session from fetch: \(excludedPracticeSession.title)")
        
        let _ = fetchedObjects.remove(at: excludeIndex)
        
        return fetchedObjects
    }
    
    func fetchVideos(for practiceSession: PracticeSession, with filename: String? = nil) -> [PracticeVideo] {
        Log.trace("Fetching videos from Practice Session \(practiceSession.title) with filename: \(filename ?? "nil")")
        let predicate = (filename == nil) ? NSPredicate(format: Predicates.hasPracticeSession, practiceSession) : NSPredicate(format: Predicates.hasPracticeSessionWithFilename, practiceSession, filename!)
        
        practiceVideoFRC.fetchRequest.predicate = predicate
        
        do {
            try practiceVideoFRC.performFetch()
            return practiceVideoFRC.fetchedObjects!
        } catch {
            Log.critical("Failed to fetch [PracticeVideo]: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: Save
    func save() {
        Log.trace()
        if persistentContainer.viewContext.hasChanges {
            self.executeSave()
        } else {
            Log.trace("No changes in viewContext")
        }
    }
    
    private func executeSave() {
        Log.trace()
        do {
            try persistentContainer.viewContext.save()
        } catch {
            let error = error as NSError
            Log.critical("Failed to save. Error: \(error), \(error.userInfo)")
        }
    }
    
    // MARK: Delete
    func delete(_ managedObject: NSManagedObject) {
        Log.trace()
        persistentContainer.viewContext.delete(managedObject)
        save()
    }
    
    /**
     For unit test purposes only!
     */
    func deleteAllRecords(entityName: String) {
        guard UserDefaults.standard.bool(forKey: LaunchArguments.isTest) else {
            Log.critical("DO NOT USE THIS FUNCTION OUTSIDE THE TEST ENVIRONMENTS")
            fatalError()
        }
        
        Log.trace()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                persistentContainer.viewContext.delete(objectData)
                save()
            }
        } catch let error {
            Log.critical("Failed to delete all data in \(entityName) error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Handling Relationships
extension CoreDataManager {
    
    // MARK: Add
    func add(_ video: PracticeVideo, to practiceSession: PracticeSession) {
        Log.trace()
        video.practiceSession = practiceSession
        practiceSession.addToVideos(video)
        save()
    }
    
    func add(_ newPracticeSessions: [PracticeSession], to group: Group) {
        Log.trace()
        let practiceSessionSet = NSSet(array: newPracticeSessions)
        group.addToPracticeSessions(practiceSessionSet)
        save()
    }
    
    // MARK: Delete
    func delete(_ video: PracticeVideo) {
        Log.trace()
        persistentContainer.viewContext.delete(video)
        video.practiceSession.removeFromVideos(video)
        save()
    }
    
    func delete(_ practiceSession: PracticeSession, from group: Group) {
        Log.trace()
        persistentContainer.viewContext.delete(practiceSession)
        group.removeFromPracticeSessions(practiceSession)
        save()
    }
    
    // MARK: Move
    func move(_ video: PracticeVideo, to practiceSession: PracticeSession) {
        Log.trace("Moving video \(video.title) to Practice Session \(practiceSession.title)")
        practiceSession.addToVideos(video)
        save()
    }
    
    func move(_ practiceSessions: [PracticeSession], to newGroup: Group?) {
        Log.trace()
        guard !practiceSessions.isEmpty else {
            Log.warn("Attempted to move empty array of practice sessions")
            return
        }
        let _ = practiceSessions.map { $0.group = newGroup }
        save()
    }
    
}

// MARK: - Create
extension CoreDataManager {
    func createAndReturnNewPracticeSession() -> PracticeSession {
        Log.trace()
        let newPracticeSession = PracticeSession(context: persistentContainer.viewContext)
        let dateText = Date.getStringFromDate(Date(), .longFormat)
        newPracticeSession.date = Date.getDateFromString(dateText) ?? Date()
        save()
        return newPracticeSession
    }
    
    func createAndConfigureNewPracticeVideo(title: String, filename: String) -> PracticeVideo {
        Log.trace()
        let newVideo = PracticeVideo(context: persistentContainer.viewContext)
        let dateText = Date.getStringFromDate(Date(), .longFormat)
        newVideo.uploadDate = Date.getDateFromString(dateText) ?? Date()
        newVideo.filename = filename
        newVideo.title = title
        return newVideo
    }
    
    func createAndSaveNewGroup(name: String, practiceSessions: [PracticeSession]?) {
        Log.trace()
        let newGroup = Group(context: persistentContainer.viewContext)
        newGroup.name = name
        newGroup.dateCreated = Date()
        
        if let practiceSessionsToAdd = practiceSessions {
            add(practiceSessionsToAdd, to: newGroup)
        } else {
            save()
        }
    }
    
    /**
     Called after updating a group in the new group flow
     */
    func update(group: Group, name: String, practiceSessions: [PracticeSession]?) {
        Log.trace()
        if name != group.name {
            group.name = name
        }
        
        if let practiceSessionsToAdd = practiceSessions {
            if !practiceSessionsToAdd.isEmpty {
                add(practiceSessionsToAdd, to: group)
            }
        }
        
        save()
    }
}
