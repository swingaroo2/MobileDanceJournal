//
//  Group+CoreDataProperties.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//
//

import Foundation
import CoreData


extension Group {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group")
    }

    @NSManaged public var name: String
    @NSManaged public var dateCreated: Date
    @NSManaged public var practiceSessions: NSSet?

}

// MARK: Generated accessors for practiceSessions
extension Group {

    @objc(addPracticeSessionsObject:)
    @NSManaged public func addToPracticeSessions(_ value: PracticeSession)

    @objc(removePracticeSessionsObject:)
    @NSManaged public func removeFromPracticeSessions(_ value: PracticeSession)

    @objc(addPracticeSessions:)
    @NSManaged public func addToPracticeSessions(_ values: NSSet)

    @objc(removePracticeSessions:)
    @NSManaged public func removeFromPracticeSessions(_ values: NSSet)

}
