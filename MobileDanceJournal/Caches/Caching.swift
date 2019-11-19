//
//  Caching.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/22/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

/**
    A convenience protocol for adding and accessing values in an NSCache
 */
protocol Caching where Self: NSCache<AnyObject, AnyObject> {
    func add<T,V>(key: T, value: V)
    func value<T,V>(for key: T) -> V?
}
