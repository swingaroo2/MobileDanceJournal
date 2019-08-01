//
//  MainCoordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 6/29/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

import UIKit

class MainCoordinator: NSObject, Coordinator {
    var rootVC: RootViewController
    
    init(with rootViewController: RootViewController) {
        self.rootVC = rootViewController
    }
}

extension MainCoordinator {
    func createNewPracticeSession() {
        let newPracticeSession = CoreDataManager.insertAndReturnNewPracticeSession()
        showDetails(for: newPracticeSession)
    }
    
    func showDetails(for practiceSession: PracticeSession) {
        
        let detailVC = rootVC.isDisplayingBothVCs() ? rootVC.detailVC : PracticeNotepadVC.instantiate()
        guard let sessionDetailsVC = detailVC else { return }
        
        sessionDetailsVC.coordinator = self
        sessionDetailsVC.navigationItem.leftBarButtonItem = rootVC.displayModeButtonItem
        sessionDetailsVC.navigationItem.leftItemsSupplementBackButton = true
        sessionDetailsVC.practiceSession = practiceSession
        sessionDetailsVC.loadViewIfNeeded()
        sessionDetailsVC.showContent()
        sessionDetailsVC.updateView(with: practiceSession)
        
        let detailNC = UINavigationController(rootViewController: sessionDetailsVC)
        rootVC.showDetailViewController(detailNC, sender: self)
    }
    // Special deletion case only applies when splitViewController is not collapsed
    func clearDetailVC() {
        guard let detailVC = rootVC.detailVC else { return }
        
        if !rootVC.isCollapsed {
            if let navController = detailVC.navigationController {
                let shouldPopBackToNotepadVC = detailVC != navController.topViewController && navController.children.contains(detailVC)
                if shouldPopBackToNotepadVC {
                    navController.popToViewController(detailVC, animated: false)
                }
            }
        }
        detailVC.practiceSession = nil
        detailVC.loadViewIfNeeded()
        detailVC.hideContent()
    }
    
    func viewVideos(for practiceSession: PracticeSession?) {
        let videosVC = VideoGalleryVC.instantiate()
        
        let cache = ThumbnailCache()
        let uploadService = VideoUploadService()
        let videoHelper = VideoHelper(with: cache, and: uploadService)
        
        videosVC.coordinator = self
        videosVC.practiceSession = practiceSession
        videosVC.videoHelper = videoHelper
        
        if rootVC.isDisplayingBothVCs() {
            guard let detailNC = rootVC.children.last as? UINavigationController else { return }
            detailNC.pushViewController(videosVC, animated: true)
        } else {
            guard let rootNC = rootVC.children.first else { return }
            guard let detailNC = rootNC.children.last as? UINavigationController else { return }
            detailNC.pushViewController(videosVC, animated: true)
        }
    }
    
    func startEditingVideo(galleryVC: VideoGalleryVC, videoPicker: UIImagePickerController? = nil) {
        let videoUploadVC = VideoUploadVC.instantiate()
        videoUploadVC.coordinator = self
        videoUploadVC.videoHelper = galleryVC.videoHelper
        videoUploadVC.modalTransitionStyle = .crossDissolve
        videoUploadVC.modalPresentationStyle = .formSheet
        
        let presentingVC = videoPicker == nil ? galleryVC : videoPicker
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
            CoreDataManager.shared.add(video, to: videoPracticeSession)
        } else {
            CoreDataManager.shared.save()
        }
        
        videoGalleryVC.prefetchVideos(for: videoPracticeSession)
        videoGalleryVC.videosTableView.reloadData()
        dismiss(videoGalleryVC, completion: nil)
    }
    
    func play(video: PracticeVideo, from gallery: VideoGalleryVC) {
        let videoPath = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        gallery.videoHelper?.playVideo(at: videoPath, in: gallery) // TODO: Move to coordinator
    }
    
    func share(video: PracticeVideo, from presentingVC: UIViewController) {
        let videoURL = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: [])
        presentingVC.present(activityVC, animated: true)
    }
    
    // TODO: Why does iPhone not let me re-upload??
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
    
    func dismiss(_ viewController: UIViewController, completion: (() -> Void)?) {
        viewController.dismiss(animated: true, completion: completion)
    }
}

extension MainCoordinator: SplitViewCoordinator {
    
    func start() {
        rootVC.coordinator = self
        rootVC.masterVC?.coordinator = self
        rootVC.detailVC?.coordinator = self
        rootVC.masterNC!.topViewController!.navigationItem.leftBarButtonItem = rootVC.displayModeButtonItem
    }
}
