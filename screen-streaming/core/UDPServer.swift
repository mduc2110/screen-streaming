//
//  UDPServer.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Network
import Foundation

public final class UDPServer {
    static let shared = UDPServer()
    
    private var listener: NWListener?
    private var connections: [NWConnection] = []
    
    private let MAX_PACKET_SIZE = 1400
    
    private init() {}
    
    func startHostingConnection(completionHandler: @escaping (Data) -> Void) async {
        do {
            // Create a UDP listener on port 5555
            let parameters = NWParameters.udp
            parameters.allowLocalEndpointReuse = true
            listener = try NWListener(using: .udp, on: NWEndpoint.Port(5555))
            
            listener?.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    DLog("Server is ready to accept connections on port 5555")
                case .failed(let error):
                    DLog("Server listener failed with error: \(error)")
                case .cancelled:
                    DLog("Server listener was cancelled")
                default:
                    break
                }
            }
            
            listener?.start(queue: .global())
            
            listener?.newConnectionHandler = { [weak self] connection in
                switch connection.endpoint {
                case .hostPort(let host, _):
                    DLog("Established server with host: \(host), port: 5555")
                default: break
                }
                
                DLog("New connection received from \(connection.endpoint)")
                
                connection.stateUpdateHandler = { [weak self] state in
                    switch state {
                    case .ready:
                        print("Connection ready")
                        self?.receiveLoop(on: connection, completionHandler: completionHandler)
                    case .failed(let error):
                        print("Connection failed with error: \(error)")
                        self?.removeConnection(connection)
                    case .cancelled:
                        print("Connection cancelled")
                        self?.removeConnection(connection)
                    default:
                        break
                    }
                }
                
                connection.start(queue: .global())
                
            }
        } catch {
            DLog("Failed to create UDP server: \(error)")
        }
    }
    
    private func receiveData(with connection: NWConnection) -> AsyncStream<Data> {
        return AsyncStream { continuation in
            Task {
                await receiveLoop(connection, continuation)
            }
        }
    }
    
    func receiveData() -> AsyncStream<Data> {
        return AsyncStream { [weak self] continuation in
            guard let self else { return }
            
            listener?.newConnectionHandler = { [weak self] connection in
                connection.start(queue: .global())
                
                Task {
                    await self?.receiveLoop(connection, continuation)
                }
            }
        }
    }
    
    private func receiveLoop(_ connection: NWConnection, _ continuation: AsyncStream<Data>.Continuation) async {
        while true {
            let data = await receiveData(on: connection)
            if let data = data {
                continuation.yield(data)
            } else {
                continuation.finish()
                break
            }
        }
    }
    
    private func receiveData(on connection: NWConnection) async -> Data? {
        await withCheckedContinuation { continuation in
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65535) { data, _, _, error in
                if let data = data, !data.isEmpty {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func start() {
        listener?.start(queue: .global())
    }
    
    func stop() {
        listener?.cancel()
        
        for connection in connections {
            connection.cancel()
        }
        connections.removeAll()
    }
    
    private func removeConnection(_ connection: NWConnection) {
        if let index = connections.firstIndex(where: { $0 === connection }) {
            connections.remove(at: index)
        }
    }
    
    private func receiveLoop(on conn: NWConnection, completionHandler: @escaping (Data) -> Void) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 65535) { [weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                completionHandler(data)
            }
            
            if let error = error {
                self?.stop()
                DLog("Receive error: \(error)")
            } else {
                // Continue receiving messages
                self?.receiveLoop(on: conn, completionHandler: completionHandler)
            }
        }
    }
    
    func send(data: Data, on connection: NWConnection) {
//        let totalSize = data.count
//        var offset = 0
//        var chunkIndex = 0
//        
//        while offset < totalSize {
//            let end = min(offset + MAX_PACKET_SIZE, totalSize)
//            let chunk = data.subdata(in: offset..<end)
//            
//            // Add a simple header for reassembly (chunk index + total chunks)
//            var chunkHeader = withUnsafeBytes(of: chunkIndex.bigEndian) { Data($0) }
//            chunkHeader.append(chunk) // Append actual data
//            
//            // Send chunk
//            connection.send(content: chunkHeader, completion: .contentProcessed { error in
//                if let error = error {
//                    print("Send error: \(error)")
//                } else {
//                    print("Chunk \(chunkIndex) sent successfully")
//                }
//            })
//            
//            offset = end
//            chunkIndex += 1
//        }
        //UInt16 maximum: 65,535
        //The data.count crash is 67980
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
            
//            var packet = Data()
//            packet.append(contentsOf: withUnsafeBytes(of: i.littleEndian, Array.init)) // Frame ID
//            packet.append(contentsOf: withUnsafeBytes(of: i.littleEndian, Array.init))      // Chunk ID
//            packet.append(contentsOf: withUnsafeBytes(of: totalChunks.littleEndian, Array.init)) // Total Chunks
//            packet.append(chunkData) // Append actual video data
            
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
    
    func broadcast(data: Data) {
        for connection in connections {
            send(data: data, on: connection)
        }
    }
}
