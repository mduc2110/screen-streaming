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
        streamControlRepository.connectToServer(with: serverAddress)
    }
    
    func startStreaming() {
        Task {
            await streamControlRepository.establishServer()
        }
        
    }
    
    func stopStreaming() {
        streamControlRepository.stopServer()
    }
    
    func sendToServer(data: Data) {
        senderRepository.sendToServer(data: data)
    }
    
    private func getIPAddress() -> String? {
        return INetSupporter.getWiFiIPAddress()
    }
}
