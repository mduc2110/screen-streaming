//
//  ContentView.swift
//  StreamingExample
//
//  Created by duc.vu1 on 23/3/25.
//

import SwiftUI
import ReplayKit

func DLog(_ message: String, _ file: String = #file, _ line: Int = #line) {
    #if DEBUG
    print("\((file as NSString).lastPathComponent) [Line \(line)]: \((message ))")
    #endif
}

struct ContentView: View {
    @StateObject private var viewModel = VideoStreamViewModel()
    private let clientSocket = UDPClient.shared
    
    private let recorder = StreamRecoder.shared
    
    var body: some View {
        HomeScreen()
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//            HStack {
//                Button("Ping connection", action: {
//                    clientSocket.ping()
//                    clientSocket.receive { data in
//                        viewModel.updateBytes(data)
//                    }
//                })
//                Button("Tab to record", action: {
//    //                startBroadcast()
//                    recorder.startRecording { bytes in
//                        clientSocket.send(data: bytes)
//    //                    viewModel.updateBytes(bytes)
//                    }
//                    
//                    clientSocket.receive { data in
//                        viewModel.updateBytes(data)
//                    }
//                })
//                Button("Tab to stop", action: {
//                    recorder.stopRecording { vc in
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
//                        }
//                    }
//                })
//            }
//            
//            List {
//                Text("Sample item 1")
//                Text("Sample item 2")
//                Text("Sample item 3")
//                Text("Sample item 4")
//                Text("Sample item 5")
//            }
//            viewModel.videoPlayerView
//                .frame(width: 300, height: 500)
//                .background(Color.gray)
//            
//            Button("Simulate Video Frame") {
//                let fakeVideoData = Data([0x00, 0x00, 0x00, 0x01]) // Replace with actual video bytes
////                                viewModel.updateBytes(fakeVideoData)
//                                viewModel.decodeAndDisplay()
////                let fakeVideoData = Data([0x00, 0x00, 0x00, 0x01]) // Replace with actual byte data
////                viewModel.decodeAndDisplay()
//            }
//        }
//        .padding()
//        .onAppear {
//        }
    }
    
    func startBroadcast() {
        RPBroadcastActivityViewController.load { (broadcastAVC, error) in
            if let error = error {
                DLog("❌ Failed to load broadcast: \(error.localizedDescription)")
            }
            DLog("✅ Broadcast UI loaded!")
            if let broadcastAVC = broadcastAVC {
//                DLog(broadcastAVC)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    UIApplication.shared.windows.first?.rootViewController?.present(broadcastAVC, animated: true)
                }
            }
        }
    }
    
    func stopBroadcast() {
        RPScreenRecorder.shared().stopRecording { preview, error in
            if let error = error {
                DLog("❌ Error stopping recording: \(error.localizedDescription)")
            } else {
                DLog("✅ Recording stopped!")
                if let preview = preview {
                    DispatchQueue.main.async {
                        UIViewController.topMostViewController()?.present(preview, animated: true)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

extension UIViewController {
    static func topMostViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return nil }
        
        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }
}


class YourViewController: UIViewController, RPBroadcastActivityViewControllerDelegate {
    
    func startBroadcast() {
        RPBroadcastActivityViewController.load { broadcastAVC, error in
            if let error = error {
                DLog("Error loading broadcast UI: \(error.localizedDescription)")
                return
            }
            
            guard let broadcastAVC = broadcastAVC else {
                DLog("Broadcast UI is nil")
                return
            }
            
            broadcastAVC.delegate = self
            broadcastAVC.modalPresentationStyle = .fullScreen
            
            DispatchQueue.main.async {
                self.present(broadcastAVC, animated: true)
            }
        }
    }
    
    // MARK: - RPBroadcastActivityViewControllerDelegate
    
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, 
                                      didFinishWith broadcastController: RPBroadcastController?, 
                                      error: Error?) {
        if let error = error {
            DLog("Broadcast Activity Error: \(error.localizedDescription)")
            return
        }
        
        broadcastActivityViewController.dismiss(animated: true) {
            broadcastController?.startBroadcast { error in
                if let error = error {
                    DLog("Unable to start broadcast: \(error.localizedDescription)")
                    return
                }
                DLog("Broadcast started successfully!")
            }
        }
    }
}

struct ListScreen: View {
    var body: some View {
        VStack {
            List {
                ForEach(1...20, id: \.self) { index in
                    Text("Item \(index)")
                        .padding()
                }
            }
            .listStyle(PlainListStyle())
            
            Spacer()
        }
    }
}
