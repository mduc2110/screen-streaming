//
//  BroadcastDatagramRepository.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation

final class DatagramSenderRepositoryReal: DatagramSenderRepository {
    private let senderService: DatagramSenderService
    
    init(_ senderService: DatagramSenderService) {
        self.senderService = senderService
    }
    
    func startBroadcasting(data: Data) {
        senderService.send(data: data)
    }
}
