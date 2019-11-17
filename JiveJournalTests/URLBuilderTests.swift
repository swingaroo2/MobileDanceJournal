//
//  URLBuilderTests.swift
//  JiveJournalTests
//
//  Created by Zach Lockett-Streiff on 11/14/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import XCTest
@testable import JiveJournal

class URLBuilderTests: XCTestCase {
    func testGetDocumentsFilePathURL() {
        let str = "test string"
        let filenameString = "output.txt"
        let filename = getDocumentsDirectory().appendingPathComponent(filenameString)
        
        do {
            try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            let documentsFilePathURL = URLBuilder.getDocumentsFilePathURL(for: filenameString)
            let documentsFilePathIsValid = documentsFilePathURL.lastPathComponent == filenameString
            XCTAssertTrue(documentsFilePathIsValid)
        } catch {
            XCTFail("Failed to write string to file")
        }
    }
}

private extension URLBuilderTests {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
