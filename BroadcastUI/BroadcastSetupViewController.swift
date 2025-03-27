//
//  BroadcastSetupViewController.swift
//  BroadcastUI
//
//  Created by duc.vu1 on 23/3/25.
//

import ReplayKit

class BroadcastSetupViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("All setup")
    }
    // Call this method when the user has finished interacting with the view controller and a broadcast stream can start
    func userDidFinishSetup() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.freddie.StreamingExample")
        sharedDefaults?.set(true, forKey: "broadcastStarted")
        print("Finished setup")
        // URL of the resource where broadcast can be viewed that will be returned to the application
//        let broadcastURL = URL(string:"http://apple.com/broadcast/streamID")
        
        // Dictionary with setup information that will be provided to broadcast extension when broadcast is started
//        let setupInfo: [String : NSCoding & NSObjectProtocol] = ["broadcastName": "example" as NSCoding & NSObjectProtocol]
        
        // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
//        self.extensionContext?.completeRequest(withBroadcast: broadcastURL!, setupInfo: setupInfo)
    }
    
    func userDidCancelSetup() {
        print("Cancel setup")
        let error = NSError(domain: "YouAppDomain", code: -1, userInfo: nil)
        // Tell ReplayKit that the extension was cancelled by the user
        self.extensionContext?.cancelRequest(withError: error)
    }
}
