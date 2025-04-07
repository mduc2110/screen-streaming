//
//  DatagramSenderService.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation

protocol SenderService {
    func connectToHost(host: String)
    func stopConnect()
    func sendToServer(data: Data)
}

class SenderServiceReal: SenderService {
    private let udpClient: UDPClient = UDPClient.shared
    
    func connectToHost(host: String) {
        udpClient.establishConnection(with: host)
    }
    
    func stopConnect() {
        udpClient.stop()
    }
    
    func sendToServer(data: Data) {
        udpClient.send(data: data)
    }
}
