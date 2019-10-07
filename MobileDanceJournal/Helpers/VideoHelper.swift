//
//  VideoPickerCoordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 6/26/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices
import AVFoundation
import AVKit

class VideoHelper: NSObject {
    
    var uploadService: VideoUploadService
    let thumbnailCache: ThumbnailCache
    
    override init() {
        self.thumbnailCache = ThumbnailCache()
        self.uploadService = VideoUploadService()
        super.init()
    }
    
    init(with cache: ThumbnailCache, and uploadService: VideoUploadService) {
        self.thumbnailCache = cache
        self.uploadService = uploadService
    }
    
    class func check(permission: Permissions,_ completion: @autoclosure @escaping () -> Void) {
        if permission == .camera {
            VideoHelper.checkCameraPermissions(completion: completion())
        } else if permission == .photos {
            VideoHelper.checkPhotosPermissions(completion: completion())
        }
    }
    
    private class func checkCameraPermissions(completion: @autoclosure @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera access authorized.")
            completion()
        case .denied:
            print("Camera access denied. Change permission in Settings > Privacy > Camera.")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Camera access granted.")
                    completion()
                } else {
                    print("Camera access denied. Change permission in Settings > Privacy > Camera.")
                }
            }
        case .restricted:
            print("Camera access restricted. Change permission in Settings > Privacy > Camera.")
        @unknown default:
            fatalError("Encountered unknown Photos authorization case")
        }
    }
    
    private class func checkPhotosPermissions(completion: @autoclosure @escaping () -> Void) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Photos access authorized.")
            completion()
        case .denied:
            print("Photos access denied. Change permission in Settings > Privacy > Camera.")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ newStatus in
                print("Photos authorization status: \(newStatus)")
                if newStatus == PHAuthorizationStatus.authorized {
                    print("Photos authorization granted")
                    completion()
                }
            })
        case .restricted:
            print("Photos access restricted. Change permission in Settings > Privacy > Camera.")
        @unknown default:
            fatalError("Encountered unknown Photos authorization case")
        }
    }
    
    // TODO: Move to coordinator
    class func initiate(_ service: UIImagePickerController.SourceType, in viewController: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate) {
        
        DispatchQueue.main.async {
            let videoPickerController = UIImagePickerController()
            videoPickerController.delegate = viewController
            videoPickerController.sourceType = service
            videoPickerController.allowsEditing = true
            videoPickerController.mediaTypes = [kUTTypeMovie as String]
            viewController.present(videoPickerController, animated: true, completion: nil)
        }
    }
    
    func playVideo(at path: URL, in viewController: UIViewController) {
        let player = AVPlayer(url: path)
        let playerController = AVPlayerViewController()
        playerController.player = player
        viewController.navigationController?.present(playerController, animated: true) {
            playerController.player?.play()
        }
    }
    
    func getThumbnail(from url: URL, completion: ((UIImage?) -> ())? = nil) {
        let filename = url.lastPathComponent
        
        if let cachedThumbnail = thumbnailCache.value(for: filename) {
            let thumbnail = cachedThumbnail
            completion?(thumbnail)
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let thumbnail = self.uploadService.getThumbnail(from: url)
                DispatchQueue.main.async {
                    if let thumbnail = thumbnail {
                        self.thumbnailCache.add(key: filename, value: thumbnail)
                    }
                    completion?(thumbnail)
                }
            }
            
        }
    }
}
