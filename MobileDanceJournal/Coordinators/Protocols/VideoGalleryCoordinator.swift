//
//  VideoGalleryCoordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/22/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

// MARK: Initialization
class VideoGalleryCoordinator: NSObject, Coordinator {
    private let practiceSession: PracticeSession
    private let coreDataManager: CoreDataManager

    var rootVC: SplitViewRootController
    var childCoordinators = [Coordinator]()
    var navigationController = UINavigationController()
    var currentGroup: Group?
    
    init(_ rootViewController: SplitViewRootController,_ coreDataManager: CoreDataManager,_ group: Group?,_ practiceSession: PracticeSession) {
        self.rootVC = rootViewController
        self.coreDataManager = coreDataManager
        self.currentGroup = group
        self.practiceSession = practiceSession
    }
    
    func start() {
        let videoGalleryVC = VideoGalleryVC.instantiate()
        
        let cache = ThumbnailCache()
        let uploadService = VideoUploadService()
        let videoHelper = VideoHelper(with: cache, and: uploadService)
        
        videoGalleryVC.coordinator = self
        videoGalleryVC.coreDataManager = coreDataManager
        videoGalleryVC.practiceSession = practiceSession
        videoGalleryVC.videoHelper = videoHelper
        
        push(videoGalleryVC, rootVCHasTwoNavControllers: rootVC.hasTwoRootNavigationControllers)
    }
}

// MARK: Navigation functions
extension VideoGalleryCoordinator {
    func startEditingVideo(videoHelper: VideoHelper, videoPicker: UIImagePickerController? = nil) {
        let videoUploadVC = VideoUploadVC.instantiate()
        videoUploadVC.coordinator = self
        videoUploadVC.coreDataManager = coreDataManager
        videoUploadVC.videoHelper = videoHelper
        videoUploadVC.modalTransitionStyle = .crossDissolve
        videoUploadVC.modalPresentationStyle = .formSheet
        
        if let presentingVC = videoPicker {
            presentingVC.present(videoUploadVC, animated: true, completion: nil)
        } else if let presentingVC = rootVC.detailVC {
            presentingVC.present(videoUploadVC, animated: true, completion: nil)
        } else {
            print("Failed to find a View Controller to present the VideoUploadVC")
        }
    }
    
    func finishEditing(_ video: PracticeVideo, from uploader: VideoUploadService) {
        guard let uploadVC = getVideoUploadVC() else { return }
        
        guard let videoGalleryVC = rootVC.detailNC?.children.last as? VideoGalleryVC else {
            uploadVC.presentBasicAlert(message: "Failed to display videos for this practice session")
            dismiss(uploadVC, completion: nil)
            return
        }
        
        guard let videoPracticeSession = videoGalleryVC.practiceSession else {
            uploadVC.presentBasicAlert(message: "Unable to assign video to practice session")
            dismiss(uploadVC, completion: nil)
            return
        }
        
        let isEditingNewVideo = uploader.video == nil
        
        if isEditingNewVideo {
            coreDataManager.add(video, to: videoPracticeSession)
        } else {
            coreDataManager.save()
        }
        
        videoGalleryVC.prefetchVideos(for: videoPracticeSession)
        videoGalleryVC.videosTableView.reloadData()
        dismiss(videoGalleryVC, completion: nil)
    }
    
    func play(_ video: PracticeVideo,_ videoHelper: VideoHelper) {
        guard let presentingVC = rootVC.detailVC else { return }
        let videoPath = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        videoHelper.playVideo(at: videoPath, in: presentingVC)
    }
    
    func share(_ url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: [])
        rootVC.detailNC?.visibleViewController?.present(activityVC, animated: true)
    }
    
    func cancelUpload() {
        if rootVC.isCollapsed {
            guard let practiceVideosVC = rootVC.detailNC?.children.last as? VideoGalleryVC else {
                guard let uploadVC = getVideoUploadVC() else { return }
                uploadVC.presentBasicAlert(message: "Failed to display videos for this practice session")
                dismiss(uploadVC, completion: nil)
                return
            }
            dismiss(practiceVideosVC, completion: nil)
        } else {
            guard let uploadVC = getVideoUploadVC() else { return }
            dismiss(uploadVC, completion: nil)
        }
    }
}

// MARK: Helper functions
private extension VideoGalleryCoordinator {
    func getVideoUploadVC() -> VideoUploadVC? {
        if let uploadVC = rootVC.presentedViewController as? VideoUploadVC {
            return uploadVC
        } else if let uploadVC = rootVC.presentedViewController?.presentedViewController as? VideoUploadVC {
            return uploadVC
        }
        
        return nil
    }
    
    func push(_ videoGalleryVC: VideoGalleryVC, rootVCHasTwoNavControllers: Bool) {
        
        if rootVCHasTwoNavControllers {
            guard let detailNC = rootVC.children.last as? UINavigationController else { return }
            detailNC.pushViewController(videoGalleryVC, animated: true)
        } else {
            guard let rootNC = rootVC.children.first else { return }
            guard let detailNC = rootNC.children.last as? UINavigationController else { return }
            detailNC.pushViewController(videoGalleryVC, animated: true)
        }
    }
}
