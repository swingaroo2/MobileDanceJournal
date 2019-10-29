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
        self.modelName = modelName
    }
    
    lazy var groupFRC: NSFetchedResultsController<Group> = {
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
        let fetchRequest: NSFetchRequest<PracticeVideo> = PracticeVideo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: PracticeVideoConstants.uploadDate, ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: persistentContainer.viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: ModelConstants.modelName)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("[CoreDataManager] Unresolved error \(error), \(error.userInfo)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        return container
    }()
}

// MARK: - Fetch/Save/Delete
extension CoreDataManager {
    func fetchPracticeSessions(in group: Group?) -> [PracticeSession]? {
        
        practiceSessionFRC.fetchRequest.predicate = (group != nil) ? NSPredicate(format: Predicates.hasGroup, group!) : NSPredicate(format: Predicates.hasNoGroup)
        
        try? practiceSessionFRC.performFetch()
        return practiceSessionFRC.fetchedObjects
    }
    
    func fetchVideos(for practiceSession: PracticeSession, with filename: String? = nil) -> [PracticeVideo] {
        let predicate = (filename == nil) ? NSPredicate(format: Predicates.hasPracticeSession, practiceSession) : NSPredicate(format: Predicates.hasPracticeSessionWithFilename, practiceSession, filename!)
        
        practiceVideoFRC.fetchRequest.predicate = predicate
        
        do {
            try practiceVideoFRC.performFetch()
            return practiceVideoFRC.fetchedObjects ?? [PracticeVideo]()
        } catch {
            fatalError("[CoreDataManager] Failed to fetch [PracticeVideo]: \(error)")
        }
    }
    
    func save() {
        if persistentContainer.viewContext.hasChanges {
            print("[CoreDataManager] \(#function)")
            self.executeSave()
        } else {
            print("[CoreDataManager] No changes in viewContext")
        }
    }
    
    private func executeSave() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("[CoreDataManager] Failed to save. Error: \(error), \(error.userInfo)")
        }
    }
    
    func delete(_ managedObject: NSManagedObject) {
        persistentContainer.viewContext.delete(managedObject)
        save()
    }
    
    func deleteAllRecords(entityName: String) {
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
            print("[CoreDataManager] Failed to delete all data in \(entityName) error :", error)
        }
    }
}

// MARK: Handling relationships
extension CoreDataManager {
    func add(_ video: PracticeVideo, to practiceSession: PracticeSession) {
        video.practiceSession = practiceSession
        practiceSession.addToVideos(video)
        save()
    }
    
    func add(_ newPracticeSessions: [PracticeSession], to group: Group) {
        let practiceSessionSet = NSSet(array: newPracticeSessions)
        group.addToPracticeSessions(practiceSessionSet)
        save()
    }
    
    func delete(_ video: PracticeVideo, from practiceSession: PracticeSession) {
        persistentContainer.viewContext.delete(video)
        practiceSession.removeFromVideos(video)
        save()
    }
    
    func delete(_ practiceSession: PracticeSession, from group: Group) {
        persistentContainer.viewContext.delete(practiceSession)
        group.removeFromPracticeSessions(practiceSession)
        save()
    }
    
    func move(_ videos: [PracticeVideo], from oldPracticeSession: PracticeSession, to newPracticeSession: PracticeSession) {
        let videoSet = NSSet(array: videos)
        oldPracticeSession.removeFromVideos(videoSet)
        newPracticeSession.addToVideos(videoSet)
        save()
    }
    
    func move(_ practiceSessions: [PracticeSession], from oldGroup: Group?, to newGroup: Group?) {
        let _ = practiceSessions.map { $0.group = newGroup }
        save()
    }
    
}

// MARK: - Insert and update new managed objects
extension CoreDataManager {
    func createAndReturnNewPracticeSession() -> PracticeSession {
        let newPracticeSession = PracticeSession(context: persistentContainer.viewContext)
        let dateText = Date.getStringFromDate(Date(), .longFormat)
        newPracticeSession.date = Date.getDateFromString(dateText) ?? Date()
        save()
        return newPracticeSession
    }
    
    func createAndConfigureNewPracticeVideo(title: String, filename: String) -> PracticeVideo {
        let newVideo = PracticeVideo(context: persistentContainer.viewContext)
        let dateText = Date.getStringFromDate(Date(), .longFormat)
        newVideo.uploadDate = Date.getDateFromString(dateText) ?? Date()
        newVideo.filename = filename
        newVideo.title = title
        return newVideo
    }
    
    func createAndSaveNewGroup(name: String, practiceSessions: [PracticeSession]?) {
        let newGroup = Group(context: persistentContainer.viewContext)
        newGroup.name = name
        newGroup.dateCreated = Date()
        
        if let practiceSessionsToAdd = practiceSessions {
            add(practiceSessionsToAdd, to: newGroup)
        } else {
            save()
        }
    }
    
    func update(group: Group, name: String, practiceSessions: [PracticeSession]?) {
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
