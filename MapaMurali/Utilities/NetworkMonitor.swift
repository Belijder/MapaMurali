//
//  NetworkMonitor.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 15/02/2023.
//

import Foundation
import Network
import RxSwift

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    var lastTimeWhenNoConnentivityAlertWasShown: Date?
    
    public private(set) var connectionPublisher = PublishSubject<Bool>()
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown
    public private(set) var unsatisiedReason: NWPath.UnsatisfiedReason?
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    
    // MARK: - Initialization
    private init() {
        self.monitor = NWPathMonitor()
    }
    
    
    // MARK: - Logic
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.isConnected = path.status != .unsatisfied
            self.connectionPublisher.onNext(self.isConnected)
            self.unsatisiedReason = path.unsatisfiedReason
            self.getConnectionType(path)
        }
    }
    
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}
