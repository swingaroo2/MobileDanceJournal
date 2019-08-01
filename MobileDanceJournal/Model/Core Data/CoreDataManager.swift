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
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var practiceSessionFRC: NSFetchedResultsController<PracticeSession> = {
        let fetchRequest: NSFetchRequest<PracticeSession> = PracticeSession.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: PracticeSessionConstants.date, ascending: false)]
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
    
    private func executeSave() {
        let context: NSManagedObjectContext = persistentContainer.viewContext
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

// MARK: - Fetch/Save/Delete
extension CoreDataManager {
    func fetchVideos(for practiceSession: PracticeSession, with filename: String? = nil) -> [PracticeVideo] {
        var predicate = NSPredicate(format: "practiceSession = %@", practiceSession)
        
        if let filename = filename {
            predicate = NSPredicate(format: "practiceSession = %@ AND filename = %@", practiceSession, filename)
        }
        
        practiceVideoFRC.fetchRequest.predicate = predicate
        
        do {
            try practiceVideoFRC.performFetch()
            return practiceVideoFRC.fetchedObjects ?? []
        } catch {
            fatalError("Failed to fetch [PracticeVideo]: \(error)")
        }
    }
    
    func save() {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        if context.hasChanges {
            context.perform { [weak self] in
                guard let self = self else { return }
                if context.hasChanges {
                    self.executeSave()
                }
            }
        }
    }
    
    func delete(_ managedObject: NSManagedObject) {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        context.delete(managedObject)
        if context.hasChanges {
            self.executeSave()
        }
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
        let context: NSManagedObjectContext = persistentContainer.viewContext
        video.practiceSession = practiceSession
        practiceSession.addToVideos(video)
        
        if context.hasChanges {
            self.executeSave()
        }
    }
    
    func delete(_ video: PracticeVideo, from practiceSession: PracticeSession) {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        context.delete(video)
        practiceSession.removeFromVideos(video)
        
        if context.hasChanges {
            self.executeSave()
        }
    }
    
    func move(_ video: PracticeVideo, from oldPracticeSession: PracticeSession, to newPracticeSession: PracticeSession) {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        video.practiceSession = newPracticeSession
        oldPracticeSession.removeFromVideos(video)
        newPracticeSession.addToVideos(video)
        
        if context.hasChanges {
            self.executeSave()
        }
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
}
