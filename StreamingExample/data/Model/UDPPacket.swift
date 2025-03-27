//
//  UDPPacket.swift
//  StreamingExample
//
//  Created by duc.vu1 on 25/3/25.
//

import Foundation

let MAX_CHUNK_SIZE = min(UInt16(1384), UInt16.max)

struct UDPPacket {
    let frameId: UInt64       // 8 bytes (Unique identifier for each frame)
    let chunkIndex: UInt32       // 2 bytes (Index of the chunk in the frame)
    let totalChunks: UInt32   // 2 bytes (Total number of chunks for this frame)
    let payload: Data            // Up to ~1,390 bytes (video payload)
    
    // Convert struct to Data for sending
    func encode() -> Data {
        var data = Data()
        data.append(contentsOf: withUnsafeBytes(of: frameId.bigEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: chunkIndex.bigEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: totalChunks.bigEndian) { Array($0) })
        data.append(payload)
        return data
    }
    
    // Convert received Data back to UDPPacket
    static func decode(from data: Data) -> UDPPacket? {
        guard data.count > 12 else { return nil } // Ensure it has at least header size
        
        let frameId = data.prefix(8).withUnsafeBytes { $0.load(as: UInt64.self) }.bigEndian
        let chunkIndex = data[8..<12].withUnsafeBytes { $0.load(as: UInt32.self) }.bigEndian
        let totalChunks = data[12..<16].withUnsafeBytes { $0.load(as: UInt32.self) }.bigEndian
        let payload = data.dropFirst(16)
        
        return UDPPacket(
            frameId: frameId,
            chunkIndex: chunkIndex,
            totalChunks: totalChunks,
            payload: payload
        )
    }
}
