//
//  PacketRepository.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation

protocol PacketRepository {
    func subscribe(completionHandler: @escaping (Data) -> Void)
    func unsubscribe()
    func sendData(data: Data)
    
    func sendMessage(msg: String)//
}
