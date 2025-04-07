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
        
        $0.single(HostService.self) { HostServiceReal(get()) }
        
        $0.single(SenderService.self) { SenderServiceReal() }
        
        $0.factory(PacketRepository.self) { PacketReceiverRepository(hostService: get()) }
        
        $0.factory(DatagramSenderRepository.self) { DatagramSenderRepositoryReal(get()) }
        
        $0.factory(ControlRepository.self) { StreamControlRepository(get(), get()) }
    }
}

public func createDomainComponents() {
    Injector.shared.createModule {
        $0.factory(PacketRepository.self) { PacketReceiverRepository(hostService: get()) }
        
        $0.factory(DatagramSenderRepository.self) { DatagramSenderRepositoryReal(get()) }
        
        $0.factory(ControlRepository.self) { StreamControlRepository(get(), get()) }
    }
}
