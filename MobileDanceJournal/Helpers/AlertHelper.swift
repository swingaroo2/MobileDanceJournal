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
    /**
     Returns a UIAlertController used in the video gallery to lead to one of two video-adding flows
     */
    class func addVideoActionSheet() -> UIAlertController {
        Log.trace()
        let actionSheet = UIAlertController(title: AlertConstants.addVideo, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: Actions.cancel, style: .cancel)
        actionSheet.addAction(cancelAction)
        
        return actionSheet
    }
}
