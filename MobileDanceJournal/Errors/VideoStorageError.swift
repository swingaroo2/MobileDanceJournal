//
//  VideoStorageError.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 11/17/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

enum VideoStorageError: Error {
    case videoAlreadyExists(filename: String)
}
