//
//  PracticeVideo+CoreDataProperties.swift
//  
//
//  Created by Zach Lockett-Streiff on 7/16/19.
//
//

import Foundation
import CoreData


extension PracticeVideo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PracticeVideo> {
        return NSFetchRequest<PracticeVideo>(entityName: "PracticeVideo")
    }

    @NSManaged public var title: String
    @NSManaged public var uploadDate: Date
    @NSManaged public var filename: String
    @NSManaged public var practiceSession: PracticeSession

}
