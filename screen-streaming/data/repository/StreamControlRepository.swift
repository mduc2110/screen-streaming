//
//  StreamControlRepository.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

final class StreamControlRepository: ControlRepository {
    private let streamService: StreamService
    private let senderService: DatagramSenderService
    
    init (
        _ streamService: StreamService,
        _ senderService: DatagramSenderService
    ) {
        self.streamService = streamService
        self.senderService = senderService
    }
    
    func startStreamReceiver(with host: String) {
        streamService.startReceive(with: host)
    }
    
    func stopReceiving() {
        streamService.stopReceiving()
    }
    
    func establishServer() {
        senderService.startHosting()
    }
    
    func stopServer() {
        //TODO: Implement
    }
}
