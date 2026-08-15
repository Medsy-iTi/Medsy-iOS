//
//  PharmacyHomeViewModel.swift
//  Medsy-Pharmacy
//

import Foundation
import Observation

@MainActor
@Observable
final class PharmacyHomeViewModel {
    enum ProfileState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    enum DashboardState: Equatable {
        case idle
        case loading
        case loaded
        case restricted
        case failed(String)
    }

    enum AISummaryState: Equatable {
        case idle
        case loading
        case loaded(AIDashboardSummary)
        case restricted
        case failed(String)
    }

    private(set) var profileState: ProfileState = .idle
    private(set) var dashboardState: DashboardState = .idle
    private(set) var aiSummaryState: AISummaryState = .idle
    private(set) var dashboard: PharmacyDashboard?
    private(set) var selectedPeriod: PharmacyDashboardPeriod = .lastMonth

    private let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
    private let fetchDashboardUseCase: FetchPharmacyDashboardUseCaseProtocol
    private let fetchAIDashboardSummaryUseCase: FetchAIDashboardSummaryUseCaseProtocol
    private let sendHeartbeatUseCase: SendHeartbeatUseCaseProtocol
    private let sessionSettings: PharmacySessionSettings

    private var isPharmacyAdmin: Bool?
    private var dashboardRequestID = 0

    init(
        getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
        fetchDashboardUseCase: FetchPharmacyDashboardUseCaseProtocol,
        fetchAIDashboardSummaryUseCase: FetchAIDashboardSummaryUseCaseProtocol,
        sendHeartbeatUseCase: SendHeartbeatUseCaseProtocol,
        sessionSettings: PharmacySessionSettings
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.fetchDashboardUseCase = fetchDashboardUseCase
        self.fetchAIDashboardSummaryUseCase = fetchAIDashboardSummaryUseCase
        self.sendHeartbeatUseCase = sendHeartbeatUseCase
        self.sessionSettings = sessionSettings
    }

    var metrics: [PharmacyHomeMetric] {
        guard let dashboard else { return [] }
        return [
            PharmacyHomeMetric(
                titleKey: "pharmacy.home.total_revenue",
                value: .revenue(dashboard.totalRevenue),
                icon: "banknote.fill",
                tint: PharmacyColor.warning
            ),
            PharmacyHomeMetric(
                titleKey: "pharmacy.home.total_orders",
                value: .count(dashboard.totalOrders),
                icon: "bag.fill",
                tint: PharmacyColor.primary
            ),
            PharmacyHomeMetric(
                titleKey: "pharmacy.home.requests_received",
                value: .count(dashboard.requestsReceived),
                icon: "tray.full.fill",
                tint: PharmacyColor.secondary
            ),
            PharmacyHomeMetric(
                titleKey: "pharmacy.home.offers_created",
                value: .count(dashboard.offersCreated),
                icon: "doc.badge.plus",
                tint: PharmacyColor.success
            )
        ]
    }

    var topSellingProducts: [PharmacyHomeTopProduct] {
        dashboard?.topSellingProducts.map(PharmacyHomeTopProduct.init) ?? []
    }

    var recentOrders: [PharmacyHomeRecentOrder] {
        dashboard?.recentOrders.map(PharmacyHomeRecentOrder.init) ?? []
    }

    func loadIfNeeded() async {
        guard profileState == .idle, dashboardState == .idle else { return }
        await refresh()
    }

    func refresh() async {
        let adminStatus = await loadProfile()
        await syncPresenceStatus()
        guard adminStatus != false else {
            invalidateDashboardRequests()
            dashboard = nil
            dashboardState = .restricted
            aiSummaryState = .restricted
            return
        }
        await loadDashboard(period: selectedPeriod)
    }

    func retryProfile() async {
        let adminStatus = await loadProfile()
        await syncPresenceStatus()
        guard adminStatus != false else {
            invalidateDashboardRequests()
            dashboard = nil
            dashboardState = .restricted
            aiSummaryState = .restricted
            return
        }
        if dashboard == nil || dashboardState == .restricted {
            await loadDashboard(period: selectedPeriod)
        }
    }

    func retryDashboard() async {
        guard isPharmacyAdmin != false else {
            dashboardState = .restricted
            aiSummaryState = .restricted
            return
        }
        await loadDashboard(period: selectedPeriod)
    }

    func selectPeriod(_ period: PharmacyDashboardPeriod) async {
        guard selectedPeriod != period else { return }
        selectedPeriod = period
        guard isPharmacyAdmin != false else {
            dashboardState = .restricted
            aiSummaryState = .restricted
            return
        }
        await loadDashboard(period: period)
    }

    @discardableResult
    private func loadProfile() async -> Bool? {
        profileState = .loading
        do {
            let profile = try await getProfileUseCase.execute()
            sessionSettings.updatePharmacy(
                id: profile.pharmacyId,
                name: profile.pharmacyName,
                address: profile.pharmacyAddress
            )
            isPharmacyAdmin = profile.isPharmacyAdmin
            profileState = .loaded
            return profile.isPharmacyAdmin
        } catch is CancellationError {
            return isPharmacyAdmin
        } catch {
            profileState = .failed("pharmacy.home.profile_load_error".localized)
            return isPharmacyAdmin
        }
    }

    private func loadDashboard(period: PharmacyDashboardPeriod) async {
        dashboardRequestID += 1
        let requestID = dashboardRequestID
        dashboardState = .loading
        aiSummaryState = .loading

        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                do {
                    let response = try await self.fetchDashboardUseCase.execute(period: period)
                    guard requestID == self.dashboardRequestID, period == self.selectedPeriod else { return }
                    self.dashboard = response
                    self.dashboardState = .loaded
                } catch is CancellationError {
                    return
                } catch {
                    guard requestID == self.dashboardRequestID, period == self.selectedPeriod else { return }
                    self.dashboard = nil
                    self.dashboardState = .failed("pharmacy.home.dashboard_load_error".localized)
                }
            }

            group.addTask { @MainActor in
                do {
                    let summary = try await self.fetchAIDashboardSummaryUseCase.execute(period: period)
                    guard requestID == self.dashboardRequestID, period == self.selectedPeriod else { return }
                    self.aiSummaryState = .loaded(summary)
                } catch is CancellationError {
                    return
                } catch {
                    guard requestID == self.dashboardRequestID, period == self.selectedPeriod else { return }
                    self.aiSummaryState = .failed("pharmacy.home.ai_summary_error".localized)
                }
            }
        }
    }

    private func syncPresenceStatus() async {
        guard let presence = try? await sendHeartbeatUseCase.execute() else { return }
        sessionSettings.updateDutyStatus(presence.onDuty)
    }

    private func invalidateDashboardRequests() {
        dashboardRequestID += 1
    }
}
