//
//  PracticeSession+CoreDataProperties.swift
//  
//
//  Created by Zach Lockett-Streiff on 7/12/19.
//
//

import Foundation
import CoreData


extension PracticeSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PracticeSession> {
        return NSFetchRequest<PracticeSession>(entityName: "PracticeSession")
    }

    @NSManaged public var date: Date
    @NSManaged public var notes: String?
    @NSManaged public var title: String
    @NSManaged public var videos: NSSet?

}

// MARK: Generated accessors for videos
extension PracticeSession {

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: PracticeVideo)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: PracticeVideo)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)

}
