//
//  VideoGalleryCoordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/22/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

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
        
        let splitViewControllerHasTwoRootNavigationControllers = rootVC.children.count == 2
        if splitViewControllerHasTwoRootNavigationControllers {
            guard let detailNC = rootVC.children.last as? UINavigationController else { return }
            detailNC.pushViewController(videoGalleryVC, animated: true)
        } else {
            guard let rootNC = rootVC.children.first else { return }
            guard let detailNC = rootNC.children.last as? UINavigationController else { return }
            detailNC.pushViewController(videoGalleryVC, animated: true)
        }
    }
}

extension VideoGalleryCoordinator {
    func startEditingVideo(presentingVC: UIViewController, videoHelper: VideoHelper, videoPicker: UIImagePickerController? = nil) {
        let videoUploadVC = VideoUploadVC.instantiate()
        //        videoUploadVC.coordinator = self
        videoUploadVC.coreDataManager = coreDataManager
        videoUploadVC.videoHelper = videoHelper
        videoUploadVC.modalTransitionStyle = .crossDissolve
        videoUploadVC.modalPresentationStyle = .formSheet
        
        let presentingVC = videoPicker == nil ? presentingVC : videoPicker
        presentingVC?.present(videoUploadVC, animated: true, completion: nil)
    }
    
    func finishEditing(_ video: PracticeVideo, from uploader: VideoUploadService, in uploadVC: VideoUploadVC) {
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
    
    func play(_ video: PracticeVideo, from presentingVC: UIViewController,_ videoHelper: VideoHelper) {
        let videoPath = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        videoHelper.playVideo(at: videoPath, in: presentingVC)
    }
    
    func share(video: PracticeVideo, from presentingVC: UIViewController) {
        let videoURL = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: [])
        presentingVC.present(activityVC, animated: true)
    }
    
    func cancel(videoUploader: VideoUploadVC) {
        if rootVC.isCollapsed {
            guard let practiceVideosVC = rootVC.detailNC?.children.last as? VideoGalleryVC else {
                videoUploader.presentBasicAlert(message: "Failed to display videos for this practice session")
                dismiss(videoUploader, completion: nil)
                return
            }
            dismiss(practiceVideosVC, completion: nil)
        } else {
            dismiss(videoUploader, completion: nil)
        }
    }
}
