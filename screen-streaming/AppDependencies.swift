//
//  AppDependencies.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

public func createCoreComponents() {
    Injector.shared.createModule {
        $0.single(UDPClient.self) { UDPClient.shared }
        
        $0.single(UDPServer.self) { UDPServer.shared }
        
        $0.single(StreamService.self) { StreamServiceReal(udpClient: get()) }
        
        $0.single(DatagramSenderService.self) { DatagramSenderServiceReal(udpServer: get()) }
        
        $0.factory(PacketRepository.self) { PacketReceiverRepository(streamService: get()) }
        
        $0.factory(DatagramSenderRepository.self) { DatagramSenderRepositoryReal(get()) }
        
        $0.factory(ControlRepository.self) { StreamControlRepository(get(), get()) }
    }
}

public func createDomainComponents() {
    Injector.shared.createModule {
        $0.factory(PacketRepository.self) { PacketReceiverRepository(streamService: get()) }
        
        $0.factory(DatagramSenderRepository.self) { DatagramSenderRepositoryReal(get()) }
        
        $0.factory(ControlRepository.self) { StreamControlRepository(get(), get()) }
    }
}
