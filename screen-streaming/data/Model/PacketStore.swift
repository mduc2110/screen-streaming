//
//  PacketStore.swift
//  screen-streaming
//
//  Created by duc.vu1 on 28/3/25.
//

import Foundation

actor PacketStore {
    private var receivedMessages = [UInt64: [UInt32: Data]]()
    private var expectedChunks = [UInt64: UInt32]()
    
    func storePacket(_ packet: UDPPacket) {
        if receivedMessages[packet.frameId] == nil {
            receivedMessages[packet.frameId] = [:]
            expectedChunks[packet.frameId] = packet.totalChunks
        }
        
        receivedMessages[packet.frameId]?[packet.chunkIndex] = packet.payload
    }
    
    func isPacketComplete(_ packet: UDPPacket) -> Bool {
        guard let totalChunks = expectedChunks[packet.frameId] else { return false }
        return receivedMessages[packet.frameId]?.count ?? 0 == totalChunks
    }
    
    func retrieveCompletePacket(_ frameId: UInt64) -> Data? {
        guard let totalChunks = expectedChunks[frameId] else { return nil }
        
        let orderedChunks = (0..<totalChunks).compactMap { receivedMessages[frameId]?[$0] }
        let fullData = orderedChunks.reduce(Data(), +)
        
        // Cleanup after assembly
        receivedMessages.removeValue(forKey: frameId)
        expectedChunks.removeValue(forKey: frameId)
        
        return fullData
    }
}
