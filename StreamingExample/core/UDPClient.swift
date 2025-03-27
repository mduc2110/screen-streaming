//
//  UDPClient.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Network
import Foundation

class UDPClient {
    static let shared = UDPClient()
    
    private let listenerRef: NWListener? = nil
    private var connection: NWConnection
    
    private init() {
        connection = NWConnection(host: NWEndpoint.Host("127.0.0.1"), port: 5555, using: .udp)
    }
    
    func establishConnection(with host: String) {
        connection.cancel()
        
        connection = NWConnection(host: NWEndpoint.Host(host), port: 5555, using: .udp)
        
        connection.start(queue: .global())
        
        connection.stateUpdateHandler = { state in
            DLog("sender: state did change, new: \(state)")
        }
    }
    
    func startConnect() {
        connection.start(queue: .global())
        
        connection.stateUpdateHandler = { state in
            DLog("sender: state did change, new: \(state)")
        }
    }
    
    func sendMessage(msg: String) {
        let data = msg.data(using: .utf8)!
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                DLog("Send failed: \(error)")
            } else {
//                DLog("Sent successfully")
            }
        }))
    }
    
    func receive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1400) { data, _, _, error in
            if let data = data, let response = String(data: data, encoding: .utf8) {
                print("📩 Received: \(response)")
            }
            if let error = error {
                print("❌ Receive error: \(error)")
            }
        }
    }
    
    func receive(completeHandler: @escaping (Data) -> Void) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65535) { data, _, isComplete, error in
            if let error = error {
                print("❌ Receive error: \(error)")
                return
            }
            
            if let data = data, !data.isEmpty {
                completeHandler(data)
            }
            
            self.receive(completeHandler: completeHandler)  // Keep receiving
//            if isComplete {
//                print("🔻 Connection closed by server.")
//                self.connection.cancel()
//            } else {
//                self.receive(completeHandler: completeHandler)  // Keep receiving
//            }
        }
    }
    
    func send(data: Data) {
        let totalChunks = UInt32((UInt32(data.count) + UInt32(MAX_CHUNK_SIZE) - 1) / UInt32(MAX_CHUNK_SIZE))
        
        let frameId = DispatchTime.now().uptimeNanoseconds
        
        for i in 0..<totalChunks {
            let chunkStart = UInt32(i) * UInt32(MAX_CHUNK_SIZE)
            let chunkEnd = min(chunkStart + UInt32(MAX_CHUNK_SIZE), UInt32(data.count))
            let chunkData = data.subdata(in: Int(chunkStart)..<Int(chunkEnd))
            
            let packet = UDPPacket(
                frameId: frameId,
                chunkIndex: i,
                totalChunks: totalChunks,
                payload: chunkData
            )
            
            // Send chunk
            connection.send(content: packet.encode(), completion: .contentProcessed { error in
                if let error = error {
                    print("Send error: \(error)")
                } else {
//                    print("Chunk \(chunkStart) sent successfully")
                }
            })
        }
        
    }
    
    func ping() {
        connection.send(content: "Ping".data(using: .utf8)!, completion: .contentProcessed({ error in
            if let error = error {
                DLog("Send failed: \(error)")
            } else {
                DLog("Ping success")
            }
        }))
    }
    
    
    func getWiFiIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                guard let interface = ptr?.pointee else { continue }

                let name = String(cString: interface.ifa_name)
                let addrFamily = interface.ifa_addr.pointee.sa_family

                // Check if the interface is IPv4 and Wi-Fi (en0)
                if addrFamily == UInt8(AF_INET), name == "en0" {
                    var addr = interface.ifa_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
                    address = String(cString: inet_ntoa(addr.sin_addr))
                    break
                }
                ptr = ptr?.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
    
    func getWiFiIPAddressV2() -> String? {
        var address: String?
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                for interface in path.availableInterfaces {
                    if interface.type == .wifi {
                        address = interface.debugDescription
                    }
                }
            }
        }
        monitor.start(queue: queue)
        return address
    }
    
    func stop() {
        connection.cancel()
    }
}

