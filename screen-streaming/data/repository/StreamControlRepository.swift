//
//  StreamControlRepository.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

final class StreamControlRepository: ControlRepository {
    private let hostService: HostService
    private let senderService: SenderService
    
    init (
        _ hostService: HostService,
        _ senderService: SenderService
    ) {
        self.hostService = hostService
        self.senderService = senderService
    }
    
    func establishServer() async {
        await hostService.startHostingConnection()
//        senderService.startHosting()
    }
    
    func stopServer() {
        hostService.stopHostingConnection()
        //TODO: Implement
    }
    
    func connectToServer(with host: String) {
        senderService.connectToHost(host: host)
    }
    
    func stopConnect() {
        senderService.stopConnect()
    }
}
