//
//  HomeView.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var favoriteCountViewModel = DIContainer.shared.resolve(FavoriteCountViewModel.self)
    @State private var connectivityMonitor = DIContainer.shared.resolve(NetworkConnectivityProviding.self) as? NetworkConnectivityMonitor
    var refreshSignal: Int = 0
    let onSearchTap: () -> Void
    let onMedicineAnalyze: () -> Void
    let onPrescription: () -> Void
    var onFavoritesTap: (() -> Void)? = nil
    var onCompareOffers: (() -> Void)? = nil
    var onOpenOfferResult: ((OfferResult, Int) -> Void)? = nil
    var onContinueOrder: ((MasterOrderDTO) -> Void)? = nil
    let homeAddress: String
    let onAddressTap: () -> Void

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        @Bindable var vm = viewModel

        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    HomeHeaderView(
                        homeAddress: homeAddress,
                        favoriteCount: favoriteCountViewModel.count,
                        onFavoritesTap: { onFavoritesTap?() },
                        onAddressTap: onAddressTap
                    )

                    if viewModel.isRefreshing {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(AppColor.green)
                                .scaleEffect(0.85)
                            Text("home.refreshing".localized)
                                .font(AppColor.sans(12, .medium))
                                .foregroundStyle(AppColor.green)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(AppColor.green.opacity(0.1))
                                .stroke(AppColor.green.opacity(0.2), lineWidth: 1)
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity
                        ))
                    }

                    HomeSearchBar(onTap: onSearchTap)
                    HomePromoBanner()

                    switch viewModel.selectedStatus {
                    case .home:
                        HomeOrderOptionsView(
                            onMedicineAnalyze: onMedicineAnalyze,
                            onPrescription: onPrescription
                        )
                    case .searching:
                        HomeSearchingStatusView(
                            selectedStatus: $vm.selectedStatus,
                            requestId: viewModel.activeRequestIds.first ?? 0,
                            createdAt: viewModel.activeRequestCreatedAt,
                            onTimerExpired: {
                                viewModel.checkAndStartPolling(forceRestartStream: true)
                            }
                        )
                    case .firstOffer:
                        HomeFirstOfferStatusView(
                            selectedStatus: $vm.selectedStatus,
                            offerTotalPrice: viewModel.offerTotalPrice,
                            offerAvailableMedsCount: viewModel.offerAvailableMedsCount,
                            offerTotalMedsCount: viewModel.offerTotalMedsCount,
                            requestId: viewModel.firstAvailableRequestId ?? 0,
                            createdAt: viewModel.activeRequestCreatedAt,
                            onTimerExpired: {
                                viewModel.checkAndStartPolling(forceRestartStream: true)
                            },
                            onCompareOffers: {
                                if let result = viewModel.firstAvailableOfferResult, let reqId = viewModel.firstAvailableRequestId {
                                    onOpenOfferResult?(result, reqId)
                                } else {
                                    onCompareOffers?()
                                }
                            },
                            onDelete: {
                                if let reqId = viewModel.firstAvailableRequestId {
                                    viewModel.clearCompletedRequest(requestId: reqId)
                                }
                            }
                        )
                    case .multipleOffers:
                        HomeMultipleOffersStatusView(
                            selectedStatus: $vm.selectedStatus,
                            offersAvailableCount: viewModel.availableOffersCount,
                            offerTotalPrice: viewModel.offerTotalPrice,
                            offerAvailableMedsCount: viewModel.offerAvailableMedsCount,
                            offerTotalMedsCount: viewModel.offerTotalMedsCount,
                            requestId: viewModel.firstAvailableRequestId ?? 0,
                            createdAt: viewModel.activeRequestCreatedAt,
                            onTimerExpired: {
                                viewModel.checkAndStartPolling(forceRestartStream: true)
                            },
                            onShowOffer: {
                                if let result = viewModel.firstAvailableOfferResult, let reqId = viewModel.firstAvailableRequestId {
                                    onOpenOfferResult?(result, reqId)
                                }
                            },
                            onCompareOffers: {
                                onCompareOffers?()
                            },
                            onDelete: {
                                if let reqId = viewModel.firstAvailableRequestId {
                                    viewModel.clearCompletedRequest(requestId: reqId)
                                }
                            }
                        )
                    case .expired:
                        HomeExpiredStatusView(selectedStatus: $vm.selectedStatus)
                    case .continueOrder:
                        HomeContinueOrderStatusView(
                            onContinue: {
                                if let order = viewModel.activeContinueMasterOrder {
                                    onContinueOrder?(order)
                                }
                            }
                        )
                    }

                    HomeCategoriesView()
                    HomeQuickDeliveryBanner()
                    Color.clear.frame(height: 20)
                }
                .animation(.easeInOut(duration: 0.25), value: viewModel.isRefreshing)
                .frame(width: geometry.size.width)
            }
            .refreshable {
                async let r1: Void = viewModel.refresh()
                async let r2: Void = favoriteCountViewModel.refresh()
                _ = await (r1, r2)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .clipped()
        }
        .background(AppColor.bg)
        .onAppear {
            viewModel.checkAndStartPolling(forceRestartStream: true)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            print("[HomeView] 🔄 scenePhase changed from \(oldPhase) to \(newPhase) (isCaptured=\(UIScreen.main.isCaptured))")
            viewModel.handleScenePhaseChange(to: newPhase)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
            let isCaptured = UIScreen.main.isCaptured
            print("[HomeView] 🎥 UIScreen.capturedDidChangeNotification: isCaptured=\(isCaptured)")
            viewModel.handleScreenCaptureChange(isCaptured: isCaptured)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.handleAppActive()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            viewModel.handleAppBackground()
        }
        .onChange(of: refreshSignal) { _, _ in
            viewModel.checkAndStartPolling(forceRestartStream: true)
        }
        .onChange(of: connectivityMonitor?.status) { oldStatus, newStatus in
            if newStatus == .connected {
                print("[HomeView] 🌐 Network reconnected! Restarting polling and stream...")
                viewModel.checkAndStartPolling(forceRestartStream: true)
            }
        }
        .task {
            await favoriteCountViewModel.refresh()

            for await _ in NotificationCenter.default.notifications(named: .favoritesDidChange) {
                guard !Task.isCancelled else { return }
                await favoriteCountViewModel.refresh()
            }
        }
    }
}
