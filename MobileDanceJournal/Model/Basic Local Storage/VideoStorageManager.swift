//
//  VideoStorageManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/18/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

protocol VideoStorageManager {
    static func saveVideo(from origianlPath: URL) -> NSError?
    static func delete(_ video: PracticeVideo, from practiceSession: PracticeSession,_ coreDataManager: CoreDataManager) -> NSError?
}
