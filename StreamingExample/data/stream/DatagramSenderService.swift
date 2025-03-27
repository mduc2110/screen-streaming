//
//  DatagramSenderService.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation

protocol DatagramSenderService {
    func startHosting()
    func send(data: Data)
}

public final class DatagramSenderServiceReal: DatagramSenderService {
    private let udpServer: UDPServer
    
    public init(udpServer: UDPServer) {
        self.udpServer = udpServer
    }
    
    public func startHosting() {
        udpServer.start()
    }
    
    public func send(data: Data) {
        udpServer.broadcast(data: data)
    }
}
