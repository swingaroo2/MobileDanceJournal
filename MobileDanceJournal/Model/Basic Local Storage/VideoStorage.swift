//
//  VideoStorage.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/18/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

protocol VideoStorage {
    func saveVideo(_ url: URL) throws
    func delete(_ video: PracticeVideo) throws
}
