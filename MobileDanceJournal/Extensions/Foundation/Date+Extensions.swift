//
//  Date+Extension.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 5/4/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

extension Date {
    static func getStringFromDate(_ date: Date,_ dateFormat: DateFormats) -> String {
        Log.trace()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        return dateFormatter.string(from: date)
    }
    
    static func getDateFromString(_ dateString: String) -> Date? {
        Log.trace()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormats.longFormat.rawValue
        return dateFormatter.date(from: dateString)
    }
}
