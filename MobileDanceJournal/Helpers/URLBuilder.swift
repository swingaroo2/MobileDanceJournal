//
//  URLBuilder.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/16/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

class URLBuilder {
    class func getDocumentsFilePathURL(for filename: String) -> URL {
        Log.trace("Creating file path for \(filename) in Documents directory")
        let documentsDirectory = FileManager.default.documentsDirectory
        let saveURL = documentsDirectory.appendingPathComponent(filename)
        return saveURL
    }
}
