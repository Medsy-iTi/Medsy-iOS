//
//  NetworkConnectivityMonitor.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import Foundation
import Network
import Observation

enum NetworkConnectivityStatus: Equatable {
    case unknown
    case connected
    case disconnected
}

@MainActor
protocol NetworkConnectivityProviding: AnyObject {
    var status: NetworkConnectivityStatus { get }
}

@MainActor
@Observable
final class NetworkConnectivityMonitor: NetworkConnectivityProviding {
    private(set) var status: NetworkConnectivityStatus = .unknown

    @ObservationIgnored private let monitor: NWPathMonitor
    @ObservationIgnored private let queue: DispatchQueue

    init(
        monitor: NWPathMonitor = NWPathMonitor(),
        queue: DispatchQueue = DispatchQueue(label: "com.medsy.network-connectivity")
    ) {
        self.monitor = monitor
        self.queue = queue
        monitor.pathUpdateHandler = { [weak self] path in
            let status: NetworkConnectivityStatus = path.status == .satisfied
                ? .connected
                : .disconnected
            Task { @MainActor [weak self] in
                self?.status = status
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
