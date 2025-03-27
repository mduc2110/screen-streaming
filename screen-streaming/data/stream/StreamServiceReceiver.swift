//
//  StreamServiceReceiver.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation

protocol StreamServiceReceiver: AnyObject {
    func onReceive(data: Data)
}
