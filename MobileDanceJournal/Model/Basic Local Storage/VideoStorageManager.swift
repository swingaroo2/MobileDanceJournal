//
//  VideoStorageManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/15/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

class VideoStorageManager: VideoStorage {
    
    func saveVideo(_ url: URL) throws {
        Log.trace("Saving video: \(url.lastPathComponent)")
        let mutableOriginalURL = url.isFileURL ? url : URL(fileURLWithPath: url.path)
        
        let documentsURL = URLBuilder.getDocumentsFilePathURL(for: url.lastPathComponent)
        
        if !FileManager.default.fileExists(atPath: documentsURL.path) {
            let data = try Data(contentsOf: mutableOriginalURL)
            try? data.write(to: documentsURL)
            Log.trace("Successfully saved video to path: \(documentsURL)")
        } else {
            Log.error(VideoUploadErrors.videoAlreadyExists)
            throw VideoStorageError.videoAlreadyExists(filename: url.lastPathComponent)
        }
    }
    
    func delete(_ video: PracticeVideo) throws {
        Log.trace("Deleting video: \(video.filename)")
        
        let filename = video.filename
        
        if let practiceSession = video.practiceSession {
            Model.coreData.delete(video, from: practiceSession)
        }
        
        let documentsURL = URLBuilder.getDocumentsFilePathURL(for: filename)
        if FileManager.default.fileExists(atPath: documentsURL.path) {
            try FileManager.default.removeItem(at: documentsURL)
            Log.trace("Removed video at path: \(documentsURL.path)")
        }
    }
}
