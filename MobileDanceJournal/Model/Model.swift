//
//  Model.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 11/16/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

class Model: NSObject {
    static var coreData: CoreDataManager!
    static var videoStorage: VideoStorageManager!
    
    static func start() {
        coreData = CoreDataManager(modelName: ModelConstants.modelName)
        let _ = coreData.persistentContainer
        videoStorage = VideoStorageManager()
    }
}
