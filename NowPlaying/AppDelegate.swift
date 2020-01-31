//
//  AppDelegate.swift
//  Test
//
//  Created by Nicolas Gonzalez on 1/30/20.
//  Copyright © 2020 AtlasWearables. All rights reserved.
//

import UIKit
import Vaccine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Injection
                .load(then: applicationDidLoad, swizzling: false)
                .add(observer: self, with: #selector(injected(_:)))

        return true
    }

    @objc open func injected(_ notification: Notification) {

        applicationDidLoad()
        // Add your view hierarchy creation here.

    }

    private func applicationDidLoad() {

        let window = UIWindow(frame: UIScreen.main.bounds)

        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!

        window.rootViewController = viewController

        window.makeKeyAndVisible()

        self.window = window

    }

}

