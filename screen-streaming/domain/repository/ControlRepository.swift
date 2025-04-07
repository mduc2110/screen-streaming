//
//  ControlRepository.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

protocol ControlRepository {
    func establishServer() async
    
    func stopServer()
    
    func connectToServer(with host: String)
    
    func stopConnect()
}
