//
//  AlertHelper.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 6/27/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class AlertHelper {
    // State
}

// MARK: - Action Sheets
extension AlertHelper {
    class func presentAddVideoActionSheet(from viewController: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate, and barButtonItem: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: AlertConstants.addVideo, message: nil, preferredStyle: .actionSheet)
        
        let recordVideoAction = UIAlertAction(title: AlertConstants.recordVideo, style: .default) { (action:UIAlertAction) in
            VideoHelper.check(permission: .camera, VideoHelper.initiate(.camera, in: viewController))
        }
        
        let uploadFromPhotosAction = UIAlertAction(title: AlertConstants.uploadFromPhotos, style: .default) { (action:UIAlertAction) in
            VideoHelper.check(permission: .photos, VideoHelper.initiate(.photoLibrary, in: viewController))
        }
        
        let cancelAction = UIAlertAction(title: Actions.cancel, style: .cancel)
        
        actionSheet.addAction(recordVideoAction)
        actionSheet.addAction(uploadFromPhotosAction)
        actionSheet.addAction(cancelAction)
        
        if let popoverPresentationController: UIPopoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.barButtonItem = barButtonItem
        }
        
        viewController.present(actionSheet, animated: true) { print("Presented Add Video action sheet") }
    }
}
