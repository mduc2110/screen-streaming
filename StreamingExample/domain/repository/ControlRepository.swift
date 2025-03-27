//
//  ControlRepository.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

protocol ControlRepository {
    func startStreamReceiver(with host: String)
    
    func stopReceiving()
    
    func establishServer()
    
    func stopServer()
}
