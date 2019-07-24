//
//  AppDelegate.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
    var coordinator: MainCoordinator?
    private var container: NSPersistentContainer = CoreDataManager.shared.persistentContainer
}

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let rootVC = RootViewController.instantiate()
        coordinator = MainCoordinator(with: rootVC)
        coordinator?.start()
        window = UIWindow.createNewWindow(with: rootVC)
        return true
    }
}
