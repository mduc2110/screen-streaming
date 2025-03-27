//
//  StreamingExampleApp.swift
//  StreamingExample
//
//  Created by duc.vu1 on 23/3/25.
//

import SwiftUI

@main
struct StreamingExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let udpClient = UDPClient.shared
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        createCoreComponents()
        
        createDomainComponents()
        
        
//        // Force calling `count`, which does not exist for NSNumber
//        let number: NSNumber = 12345
//        let _ = number.perform(NSSelectorFromString("count"))
        
        return true
    }
}
