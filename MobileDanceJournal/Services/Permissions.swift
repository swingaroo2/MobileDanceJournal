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
        switch AVCaptureDevice.authorizationStatus(for: .video) {
         case .authorized:
             print("Camera access authorized.")
             return true
         case .denied:
             print("Camera access denied. Change permission in Settings > Privacy > Camera.")
            return false
         case .notDetermined:
            var isAuthorized = false
            
             AVCaptureDevice.requestAccess(for: .video) { success in
                 if success {
                     print("Camera access granted.")
                     isAuthorized = true
                 } else {
                     print("Camera access denied. Change permission in Settings > Privacy > Camera.")
                    isAuthorized = false
                 }
             }
            
            return isAuthorized
         case .restricted:
             print("Camera access restricted. Change permission in Settings > Privacy > Camera.")
            return false
         @unknown default:
             print("Encountered unknown Photos authorization case")
            return false
         }
    }
    
    func hasPhotosPermission() -> Bool {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Photos access authorized.")
            return true
        case .denied:
            print("Photos access denied. Change permission in Settings > Privacy > Camera.")
            return false
        case .notDetermined:
            var isAuthorized = false
            
            PHPhotoLibrary.requestAuthorization({ newStatus in
                print("Photos authorization status: \(newStatus)")
                if newStatus == PHAuthorizationStatus.authorized {
                    print("Photos authorization granted")
                    isAuthorized = true
                }
            })
            
            return isAuthorized
        case .restricted:
            print("Photos access restricted. Change permission in Settings > Privacy > Camera.")
            return false
        @unknown default:
            print("Encountered unknown Photos authorization case")
            return false
        }
    }
}
