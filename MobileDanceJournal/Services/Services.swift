//
//  Services.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 10/12/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

class Services: NSObject {
    static let activity = ShareController()
    static let permissions = PermissionsController()
    static let uploads = UploadsController()
}
