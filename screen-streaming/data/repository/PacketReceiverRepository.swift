//
//  PacketReceiverRepository.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation

final class PacketReceiverRepository: PacketRepository {
    private let streamService: StreamService
    
    private var receiver: StreamServiceReceiver?
    
    private var receivedMessages = [UInt64: [UInt32: Data]]() // Store chunks by packetID
    private var expectedChunks = [UInt64: UInt32]() // Total chunks expected per packet
    
    init(streamService: StreamService) {
        self.streamService = streamService
    }
    
    func subscribe(completionHandler: @escaping (Data) -> Void) {
        self.receiver = Receiver { [weak self] data in
            
            if let finalData = self?.processPacketData(data) {
                completionHandler(finalData)
            }
        }
        streamService.subscribe(receiver!)
    }
    
    func unsubscribe() {
        if let receiver {
            streamService.unsubscribe(receiver)
        }
    }
    
    func sendData(data: Data) {
        streamService.sendData(data: data)
    }
    
    func sendMessage(msg: String) {
        streamService.sendMessage(msg: msg)
    }
    
    private func processPacketData(_ data: Data) -> Data? {
        guard let packet = UDPPacket.decode(from: data) else { return nil }
        if receivedMessages[packet.frameId] == nil {
            receivedMessages[packet.frameId] = [:]
            expectedChunks[packet.frameId] = packet.totalChunks
        }
        
        receivedMessages[packet.frameId]?[packet.chunkIndex] = packet.payload
        print("Received chunk \(packet.chunkIndex)/\(packet.totalChunks) for Packet \(packet.frameId)")
        
        // Check if all chunks are received
        if let totalChunks = expectedChunks[packet.frameId], receivedMessages[packet.frameId]?.count ?? 0 == totalChunks {
            let orderedChunks = (0..<totalChunks).compactMap { receivedMessages[packet.frameId]?[$0] }
            let fullData = orderedChunks.reduce(Data(), +) // Merge all chunks
            
            print("Reassembled full data for Packet \(packet.frameId) with size: \(fullData.count)")
            receivedMessages.removeValue(forKey: packet.frameId) // Cleanup
            expectedChunks.removeValue(forKey: packet.frameId)
            
            return fullData
        } else {
            return nil
        }
        
    }
    
    private class Receiver: StreamServiceReceiver {
        var onUpdate: (Data) -> Void
        
        init(onUpdate: @escaping (Data) -> Void) {
            self.onUpdate = onUpdate
        }
        
        func onReceive(data: Data) {
            onUpdate(data)
        }
    }
}
