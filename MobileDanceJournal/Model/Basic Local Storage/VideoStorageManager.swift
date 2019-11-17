//
//  VideoStorageManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/15/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

class VideoStorageManager: VideoStorage {
    
    func saveVideo(from originalPath: URL) -> NSError? {
        Log.trace()
        do {
            
            var mutableOriginalPath = originalPath
            if !mutableOriginalPath.isFileURL {
                mutableOriginalPath = URL(fileURLWithPath: originalPath.path)
            }
            
            let documentsURL = URLBuilder.getDocumentsFilePathURL(for: mutableOriginalPath.lastPathComponent)
            
            if !FileManager.default.fileExists(atPath: documentsURL.path) {
                let data = try Data(contentsOf: mutableOriginalPath)
                try data.write(to: documentsURL)
                Log.trace("Successfully saved video to path: \(documentsURL)")
            } else {
                let videoExistsError = NSError(domain: "com.swingaroo.videoGallery", code: 0, userInfo: nil)
                videoExistsError.setValue(UserErrors.videoAlreadyExists, forKey: NSLocalizedDescriptionKey)
                Log.error(UserErrors.videoAlreadyExists)
                return videoExistsError
            }
            
        } catch {
            Log.error(error.localizedDescription)
            return error as NSError
        }
        
        return nil
    }
    
    func delete(_ video: PracticeVideo, from practiceSession: PracticeSession) -> NSError? {
        Log.trace()
        let documentsURL = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        Model.coreData.delete(video, from: practiceSession)
        
        if FileManager.default.fileExists(atPath: documentsURL.path) {
            do {
                try FileManager.default.removeItem(at: documentsURL)
                Log.trace("Removed video at path: \(documentsURL.path)")
            } catch {
                Log.error(error.localizedDescription)
                return error as NSError
            }
        }
        
        return nil
    }
}
