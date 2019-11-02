//
//  URLBuilder.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/16/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

class URLBuilder {
    class func isTempStorage(_ path: URL) -> Bool {
        Log.trace()
        let tmpDirectory = FileManager.default.temporaryDirectory
        let tmpSearchURL = tmpDirectory.appendingPathComponent(path.lastPathComponent)
        let isTempStorage = FileManager.default.fileExists(atPath: tmpSearchURL.path)
        return isTempStorage
    }
    
    class func getDocumentsFilePathURL(for filename: String) -> URL {
        Log.trace()
        let documentsDirectory = FileManager.default.documentsDirectory
        let savePath = documentsDirectory.appendingPathComponent(filename)
        let saveFileURL = URL(fileURLWithPath: savePath.path)
        return saveFileURL
    }
}
