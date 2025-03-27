//
//  HomeViewModel.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import SwiftUI
import Foundation

class HomeViewModel: ObservableObject {
    @Published var ipAddress: String = "Loading..."
    @Published var serverAddress: String = ""
    
    @ByInject var streamReceiverRepository: PacketRepository
    @ByInject var streamControlRepository: ControlRepository
    @ByInject var senderRepository: DatagramSenderRepository
    
    func loadIpAddress() {
        // Get the device's IP address
        if let address = getIPAddress() {
            DispatchQueue.main.async {
                self.ipAddress = address
            }
        } else {
            DispatchQueue.main.async {
                self.ipAddress = "Not available"
            }
        }
    }
    
    func connectToServer() {
        guard !serverAddress.isEmpty else { return }
        streamControlRepository.startStreamReceiver(with: serverAddress)
//        streamReceiverRepository.subscribe { data in
//            DLog("🥲 \(data)")
//        }
    }
    
    func startStreaming() {
        streamControlRepository.establishServer()
    }
    
    func stopStreaming() {
        streamControlRepository.stopServer()
    }
    
    func broadcastData(data: Data) {
        senderRepository.startBroadcasting(data: data)
    }
    
    func echo() {
        guard !serverAddress.isEmpty else { return }
        streamControlRepository.startStreamReceiver(with: serverAddress)
        streamReceiverRepository.sendMessage(msg: "Oh hellll noooo")
//        streamReceiverRepository.subscribe { data in
//            DLog("🥲 \(data)")
//        }
    }
    
    func sendToServer(data: Data) {
        streamReceiverRepository.sendData(data: data)
    }
    
    
    private func getIPAddress() -> String? {
        return INetSupporter.getWiFiIPAddress()
    }
}
