//
//  StreamService.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation

protocol StreamService {
    func startReceive(with host: String)
    func stopReceiving()
    func sendMessage(msg: String)
    func sendData(data: Data)
    
    func subscribe(_ receiver: StreamServiceReceiver)
    func unsubscribe(_ receiver: StreamServiceReceiver)
}

final class StreamServiceReal: StreamService {
    private let udpClient: UDPClient
    
    private var receivers: [StreamServiceReceiver] = []
    
    init(udpClient: UDPClient) {
        self.udpClient = udpClient
    }
    
    func subscribe(_ receiver: StreamServiceReceiver) {
        if receivers.contains(where: { $0 === receiver }) { return }
        receivers.append(receiver)
    }
    
    func unsubscribe(_ receiver: StreamServiceReceiver) {
        receivers.removeAll { $0 === receiver }
    }
    
    func startReceive(with host: String) {
        udpClient.establishConnection(with: host)
        udpClient.receive { [weak self] data in
            self?.receivers.forEach { $0.onReceive(data: data) }
        }
    }
    
    func stopReceiving() {
        udpClient.stop()
    }
    
    func sendMessage(msg: String) {
        udpClient.sendMessage(msg: msg)
    }
    
    func sendData(data: Data) {
        udpClient.send(data: data)
    }
}
