//
//  BroadcastDatagramRepository.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation

final class DatagramSenderRepositoryReal: DatagramSenderRepository {
    private let senderService: SenderService
    
    init(_ senderService: SenderService) {
        self.senderService = senderService
    }
    
    func sendToServer(data: Data) {
        senderService.sendToServer(data: data)
    }
}
