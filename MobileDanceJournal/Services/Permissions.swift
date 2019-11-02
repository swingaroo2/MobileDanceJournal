//
//  Permissions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 10/26/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

class PermissionsController: NSObject {
    func hasCameraPermission() -> Bool {
        Log.trace()
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            Log.trace("Camera access authorized.")
            return true
        case .denied:
            Log.warn("Camera access denied. Change permission in Settings > Privacy > Camera.")
            return false
        case .notDetermined:
            var isAuthorized = false
            
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    Log.trace("Camera access granted.")
                    isAuthorized = true
                } else {
                    Log.warn("Camera access denied. Change permission in Settings > Privacy > Camera.")
                    isAuthorized = false
                }
            }
            
            return isAuthorized
        case .restricted:
            Log.warn("Camera access restricted. Change permission in Settings > Privacy > Camera.")
            return false
        @unknown default:
            Log.critical("Encountered unknown Photos authorization case")
            return false
        }
    }
    
    func hasPhotosPermission() -> Bool {
        Log.trace()
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            Log.trace("Photos access authorized.")
            return true
        case .denied:
            Log.warn("Photos access denied. Change permission in Settings > Privacy > Camera.")
            return false
        case .notDetermined:
            var isAuthorized = false
            
            PHPhotoLibrary.requestAuthorization({ newStatus in
                Log.trace("Photos authorization status: \(newStatus)")
                if newStatus == PHAuthorizationStatus.authorized {
                    Log.trace("Photos authorization granted")
                    isAuthorized = true
                }
            })
            
            return isAuthorized
        case .restricted:
            Log.warn("Photos access restricted. Change permission in Settings > Privacy > Camera.")
            return false
        @unknown default:
            Log.critical("Encountered unknown Photos authorization case")
            return false
        }
    }
}
