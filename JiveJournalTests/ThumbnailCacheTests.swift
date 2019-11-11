//
//  ThumbnailCacheTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/10/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
@testable import JiveJournal

class ThumbnailCacheTests: XCTestCase {

    let sut = ThumbnailCache()

    func testCacheInteractions() {
        let testImage = UIImage()
        let key = "key"
        XCTAssertNil(sut.value(for: key))
        
        sut.add(key: key, value: testImage)
        XCTAssertNotNil(sut.value(for: key))
    }

}
