//
//  PacketReceiverRepository.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation

final class PacketReceiverRepository: PacketRepository {
    private let hostService: HostService
    
    private var receiver: StreamServiceReceiver?
    
    private var receivedMessages = [UInt64: [UInt32: Data]]() // Store chunks by packetID
    private var expectedChunks = [UInt64: UInt32]() // Total chunks expected per packet
    
    private let packetStore = PacketStore()
    
    init(hostService: HostService) {
        self.hostService = hostService
    }
    
    func subscribe(completionHandler: @escaping (Data) -> Void) {
        self.receiver = Receiver { [weak self] data in
            Task {
                if let finalData = await self?.processPacketData(data) {
                    completionHandler(finalData)
                }
            }
        }
        hostService.subscribe(receiver!)
    }
    
    func unsubscribe() {
        if let receiver {
            hostService.unsubscribe(receiver)
        }
    }
    
    private func processPacketData(_ data: Data) async -> Data? {
        DLog("🥲 Received bytes with size: \(data.count)")
        guard let packet = UDPPacket.decode(from: data) else { return nil }
//        DLog("🥲 packet info: \(packet) | \(packet.frameId) | \(packet.totalChunks) |  \(packet.payload)")
        await packetStore.storePacket(packet)
        
        if await packetStore.isPacketComplete(packet) {
            if let fullData = await packetStore.retrieveCompletePacket(packet.frameId) {
                print("🥲 Reassembled full data for Packet \(packet.frameId) with size: \(fullData.count)")
                return fullData
            }
        }
        return nil
        
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
