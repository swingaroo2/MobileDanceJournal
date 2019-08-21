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
    
    weak var practiceSessionDelegate: NSFetchedResultsControllerDelegate?
    weak var practiceVideoDelegate: NSFetchedResultsControllerDelegate?
    weak var practiceGroupsDelegate: NSFetchedResultsControllerDelegate?
    private let modelName: String
    
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
        fetchedResultsController.delegate = practiceGroupsDelegate
        
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
        fetchedResultsController.delegate = practiceSessionDelegate
        
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
        fetchedResultsController.delegate = practiceVideoDelegate
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: ModelConstants.modelName)
        
        if let persistentStoreURL = container.persistentStoreDescriptions.first?.url {
            let description = NSPersistentStoreDescription(url: persistentStoreURL)
            description.shouldAddStoreAsynchronously = true
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        return container
    }()
}

// MARK: - Fetch/Save/Delete
extension CoreDataManager {
    func fetchPracticeSessions(in group: Group?) -> [PracticeSession]? {
        practiceSessionFRC.fetchRequest.predicate = (group != nil) ? NSPredicate(format: Predicates.hasGroup, group!) : nil
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
            fatalError("Failed to fetch [PracticeVideo]: \(error)")
        }
    }
    
    func save() {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        if context.hasChanges {
            self.executeSave()
        }
    }
    
    private func executeSave() {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Updated Core Data")
            } catch {
                // TODO: Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func delete(_ managedObject: NSManagedObject) {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        context.delete(managedObject)
        save()
    }
    
    func deleteAllRecords(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let moc = persistentContainer.viewContext
            let results = try moc.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                moc.delete(objectData)
                save()
            }
        } catch let error {
            print("Failed to delete all data in \(entityName) error :", error)
        }
    }
}

// MARK: Handling Relationships
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
        let context: NSManagedObjectContext = persistentContainer.viewContext
        context.delete(video)
        practiceSession.removeFromVideos(video)
        save()
    }
    
    func delete(_ practiceSession: PracticeSession, from group: Group) {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        context.delete(practiceSession)
        group.removeFromPracticeSessions(practiceSession)
        save()
    }
    
    func move(_ video: PracticeVideo, from oldPracticeSession: PracticeSession, to newPracticeSession: PracticeSession) {
        video.practiceSession = newPracticeSession
        oldPracticeSession.removeFromVideos(video)
        save()
    }
    
    func move(_ practiceSessions: [PracticeSession], from oldGroup: Group, to newGroup: Group) {
        let practiceSessionSet = NSSet(array: practiceSessions)
        oldGroup.removeFromPracticeSessions(practiceSessionSet)
        newGroup.addToPracticeSessions(practiceSessionSet)
        save()
    }
    
}

// MARK: - Insert new managed objects
// TODO: Consistent naming conventions
extension CoreDataManager {
    func insertAndReturnNewPracticeSession() -> PracticeSession {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        let newPracticeSession = PracticeSession(context: context)
        let dateText = Date.getStringFromDate(Date(), .longFormat)
        newPracticeSession.date = Date.getDateFromString(dateText) ?? Date()
        return newPracticeSession
    }
    
    func createAndConfigureNewPracticeVideo(title: String, filename: String) -> PracticeVideo {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        let newVideo = PracticeVideo(context: context)
        let dateText = Date.getStringFromDate(Date(), .longFormat)
        newVideo.uploadDate = Date.getDateFromString(dateText) ?? Date()
        newVideo.filename = filename
        newVideo.title = title
        return newVideo
    }
    
    func createAndSaveNewGroup(name: String, practiceSessions: [PracticeSession]?) {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        let newGroup = Group(context: context)
        newGroup.name = name
        newGroup.dateCreated = Date()
        
        if let practiceSessionsToAdd = practiceSessions {
            add(practiceSessionsToAdd, to: newGroup)
        }
        
        save()
    }
}
