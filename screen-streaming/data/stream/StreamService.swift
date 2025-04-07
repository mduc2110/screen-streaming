//
//  StreamService.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation

protocol HostService {
    func startHostingConnection() async
    func stopHostingConnection()
    
    func subscribe(_ receiver: StreamServiceReceiver)
    func unsubscribe(_ receiver: StreamServiceReceiver)
}

class HostServiceReal: HostService {
    private let udpServer: UDPServer
    
    private var receivers: [StreamServiceReceiver] = []
    
    init(
        _ udpServer: UDPServer
    ) {
        self.udpServer = udpServer
    }
    
    func startHostingConnection() async {
        await udpServer.startHostingConnection { [weak self] data in
            self?.receivers.forEach { $0.onReceive(data: data) }
        }
    }
    
    func stopHostingConnection() {
        
    }
    
    func subscribe(_ receiver: StreamServiceReceiver) {
        if receivers.contains(where: { $0 === receiver }) { return }
        receivers.append(receiver)
    }
    
    func unsubscribe(_ receiver: StreamServiceReceiver) {
        receivers.removeAll { $0 === receiver }
    }
    
//    func startReceive(with host: String) {
//        udpClient.establishConnection(with: host)
//        udpClient.receive { [weak self] data in
//            self?.receivers.forEach { $0.onReceive(data: data) }
//        }
//    }
//
//    func stopReceiving() {
//        udpClient.stop()
//    }
//
//    func sendMessage(msg: String) {
//        udpClient.sendMessage(msg: msg)
//    }
//
//    func sendData(data: Data) {
//        udpClient.send(data: data)
//    }
}
