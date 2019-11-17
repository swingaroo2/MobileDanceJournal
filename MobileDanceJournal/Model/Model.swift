//
//  Model.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 11/16/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

class Model: NSObject {
    static let coreData = CoreDataManager(modelName: ModelConstants.modelName)
    static let videoFileStorage = VideoLocalStorageManager()
}
