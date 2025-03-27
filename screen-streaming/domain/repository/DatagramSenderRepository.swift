//
//  DatagramSenderRepository.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation

protocol DatagramSenderRepository {
    func startBroadcasting(data: Data)
}
