//
//  NetworkMonitor.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 7.04.25.
//

import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private(set) var isConnected: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }
}
