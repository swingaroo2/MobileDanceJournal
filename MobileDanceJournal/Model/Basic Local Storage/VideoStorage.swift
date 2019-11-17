//
//  VideoStorage.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/18/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

protocol VideoStorage {
    func saveVideo(from origianlPath: URL) -> NSError?
    func delete(_ video: PracticeVideo, from practiceSession: PracticeSession) -> NSError?
}
