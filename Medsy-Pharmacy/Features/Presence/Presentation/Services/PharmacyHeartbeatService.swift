//  PharmacyHeartbeatService.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class PharmacyHeartbeatService {
    private let sendHeartbeatUseCase: SendHeartbeatUseCaseProtocol
    private var heartbeatTask: Task<Void, Never>?

    private(set) var lastHeartbeatAt: String?

    init(sendHeartbeatUseCase: SendHeartbeatUseCaseProtocol) {
        self.sendHeartbeatUseCase = sendHeartbeatUseCase
    }

    func startHeartbeat() {
        guard heartbeatTask == nil else { return }
        heartbeatTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                guard !Task.isCancelled else { break }
                await self?.ping()
            }
        }
        print("[PharmacyHeartbeatService] ❤️ Heartbeat started (every 60s)")
    }

    func stopHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = nil
        print("[PharmacyHeartbeatService] 🛑 Heartbeat stopped")
    }

    private func ping() async {
        do {
            let entity = try await sendHeartbeatUseCase.execute()
            lastHeartbeatAt = entity.lastHeartbeatAt
            print("[PharmacyHeartbeatService] ✅ Heartbeat sent — lastHeartbeatAt: \(entity.lastHeartbeatAt)")
        } catch {
            print("[PharmacyHeartbeatService] ❌ Heartbeat failed: \(error)")
        }
    }
}
