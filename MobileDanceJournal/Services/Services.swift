//
//  Services.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 10/12/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

class Services: NSObject {
    static var activity: ShareController!
    static var permissions: PermissionsController!
    static var uploads: UploadsController!
    
    class func start() {
        activity = ShareController()
        permissions = PermissionsController()
        uploads = UploadsController()
    }
    
}
