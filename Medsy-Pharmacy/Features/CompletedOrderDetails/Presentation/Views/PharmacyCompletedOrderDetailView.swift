//
//  PharmacyCompletedOrderDetailView.swift
//  Medsy
//

import SwiftUI
import UIKit

// MARK: - Private helper (safe dialer)
@MainActor
private func dial(_ rawNumber: String) {
    let allowedSet = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "+"))
    let cleaned = rawNumber.components(separatedBy: allowedSet.inverted).joined()
    guard !cleaned.isEmpty else { return }
    #if targetEnvironment(simulator)
    print("[Pharmacy] Dial \(cleaned) (simulator – cannot open tel:)")
    #else
    if let url = URL(string: "telprompt://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    } else if let url = URL(string: "tel:\(cleaned)"), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
    #endif
}

struct PharmacyCompletedOrderDetailView: View {
    let state: CompletedOrderDetailViewState
    let isMarkingReady: Bool
    let isMarkingOutForDelivery: Bool
    let isMarkingDelivered: Bool
    let markReadyError: String?
    let markOutForDeliveryError: String?
    let markDeliveredError: String?
    let onRetry: () -> Void
    let onBack: (() -> Void)?
    let onMarkReady: (() -> Void)?
    let onMarkOutForDelivery: (() -> Void)?
    let onMarkDelivered: (() -> Void)?

    @State private var fullPrescriptionURL: URL? = nil

    // Aggregate error for the alert (shows the first active error)
    private var activeError: String? {
        markReadyError ?? markOutForDeliveryError ?? markDeliveredError
    }

    var body: some View {
        VStack(spacing: 0) {
            PharmacyDivider()
            detailContent
        }
        .background(PharmacyColor.bg)
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .pharmacyLocalizedEnvironment()
        .alert(
            "pharmacy.error.title".localized,
            isPresented: Binding(
                get: { activeError != nil },
                set: { if !$0 { } }
            ),
            presenting: activeError
        ) { _ in
            Button("pharmacy.ok".localized, role: .cancel) {}
        } message: { msg in
            Text(msg)
        }
        .fullScreenCover(item: $fullPrescriptionURL) { url in
            PrescriptionFullScreenView(url: url)
        }
    }

    private var navTitle: String {
        if case .loaded(let order) = state {
            return "completed_order.order_number".localized(String(order.orderNumber))
        }
        return "completed_order.title".localized
    }

    @ViewBuilder
    private var detailContent: some View {
        switch state {
        case .loading:
            PharmacyCompletedOrderDetailLoadingSkeleton()
        case .loaded(let order):
            loadedView(order: order)
        case .error(let message):
            PharmacyErrorView(message: message, onRetry: onRetry)
        case .notFound:
            PharmacyOrderNotFoundView(onBack: onBack)
        }
    }

    private func loadedView(order: CompletedOrderDetailPresentationModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PharmacySpacing.md) {

                // 3-step status tracker
                PharmacyOrderStatusTrackerView(status: order.status, hasDelivery: order.hasDelivery)

                // Action buttons — mutually exclusive based on current status
                if canMarkReady(status: order.status), let onMarkReady {
                    PharmacyOrderActionButton(
                        labelKey: "pharmacy.status.mark_ready",
                        loadingLabelKey: "pharmacy.status.marking_ready",
                        systemImage: "checkmark.circle.fill",
                        isLoading: isMarkingReady,
                        action: onMarkReady
                    )
                } else if canMarkOutForDelivery(status: order.status), let onMarkOutForDelivery {
                    PharmacyOrderActionButton(
                        labelKey: "pharmacy.status.mark_out_for_delivery",
                        loadingLabelKey: "pharmacy.status.marking_out_for_delivery",
                        systemImage: "shippingbox.fill",
                        isLoading: isMarkingOutForDelivery,
                        action: onMarkOutForDelivery
                    )
                } else if canMarkDelivered(status: order.status), let onMarkDelivered {
                    let isPickup = (order.status == .readyForPickup)
                    PharmacyOrderActionButton(
                        labelKey: isPickup
                            ? "pharmacy.status.mark_collected"
                            : "pharmacy.status.mark_delivered",
                        loadingLabelKey: isPickup
                            ? "pharmacy.status.marking_collected"
                            : "pharmacy.status.marking_delivered",
                        systemImage: isPickup ? "bag.fill.badge.plus" : "checkmark.seal.fill",
                        isLoading: isMarkingDelivered,
                        action: onMarkDelivered
                    )
                }

                PharmacyContactInfoCard(
                    headerStyle: .orderInfo(orderId: String(order.orderNumber), date: order.createdAt),
                    name: order.customerName,
                    phone: order.customerPhone,
                    onContact: {
                        dial(order.customerPhone)
                    },
                    address: order.deliveryAddress,
                    onLocationTap: order.hasDelivery ? {
                        if let lat = order.deliveryLatitude, let lon = order.deliveryLongitude {
                            let urlString = "maps://?q=\(lat),\(lon)"
                            if let url = URL(string: urlString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    } : nil
                )
                
                PharmacyOrderItemsCard(
                    items: .constant(order.items.map { completedItem in
                        PharmacyOrderItem(
                            id: String(completedItem.id),
                            productId: completedItem.productId,
                            name: completedItem.productName,
                            spec: "",
                            quantity: completedItem.quantity,
                            price: completedItem.unitPrice,
                            imageName: nil,
                            imageUrl: completedItem.imageUrl,
                            isAvailable: true,
                            selectedOfferProductId: 0,
                            alternativeMedicine: nil,
                            form: nil,
                            strength: nil,
                            packSize: nil
                        )
                    }),
                    deliveryFee: order.deliveryFee,
                    total: order.total,
                    isOfferSubmitted: true,
                    isEditable: false,
                    onSelectAlternative: nil
                )

                
                if let imageUrlString = order.prescriptionImage, let url = URL(string: imageUrlString) {
                    PharmacyPrescriptionCard(uiImage: nil, imageUrl: url) {
                        fullPrescriptionURL = url
                    }
                }
                
                if !order.customerNotes.isEmpty {
                    PharmacyCustomerNotesCard(notes: order.customerNotes)
                }

                if !order.pharmacistName.isEmpty {
                    PharmacyContactInfoCard(
                        headerStyle: .title("completed_order.pharmacist".localized),
                        name: order.pharmacistName,
                        phone: order.pharmacistPhone,
                        onContact: {
                            dial(order.pharmacistPhone)
                        }
                    )
                }

                if !order.pharmacistNotes.isEmpty {
                    PharmacyNotesForCustomerCard(text: .constant(order.pharmacistNotes))
                        .disabled(true)
                }

                PharmacyMoneyDetailsCard(
                    subTotal: order.subTotal,
                    deliveryFee: order.deliveryFee,
                    total: order.total,
                    hasDelivery: order.hasDelivery
                )
            }
            .padding(PharmacySpacing.md)
        }
        .background(PharmacyColor.bg)
    }

    // MARK: - Status action helpers

    /// Preparing / pending orders can be marked as ready
    private func canMarkReady(status: PharmacyOrderAPIStatus) -> Bool {
        switch status {
        case .pending, .accepted, .preparing: return true
        default: return false
        }
    }

    /// Delivery orders that are ready can be sent out for delivery
    private func canMarkOutForDelivery(status: PharmacyOrderAPIStatus) -> Bool {
        status == .readyForDelivery
    }

    /// Orders that are out for delivery (or ready for pickup) can be marked delivered/collected
    private func canMarkDelivered(status: PharmacyOrderAPIStatus) -> Bool {
        status == .outForDelivery || status == .readyForPickup
    }
}

// MARK: - Full-Screen Prescription Viewer

private struct PrescriptionFullScreenView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = max(1.0, lastScale * value)
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    if scale < 1.0 {
                                        withAnimation(.spring()) {
                                            scale = 1.0
                                            offset = .zero
                                        }
                                        lastScale = 1.0
                                        lastOffset = .zero
                                    }
                                }
                                .simultaneously(with:
                                    DragGesture()
                                        .onChanged { value in
                                            if scale > 1.0 {
                                                offset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                            }
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        }
                                )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastScale = 1.0
                                    lastOffset = .zero
                                } else {
                                    scale = 2.5
                                    lastScale = 2.5
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failure:
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 44))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("pharmacy.prescription.load_error".localized)
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                default:
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Circle().fill(.white.opacity(0.2)))
            }
            .padding(.top, 56)
            .padding(.trailing, 20)
        }
    }
}

// MARK: - URL Identifiable

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

// MARK: - PharmacyOrderActionButton
// Generic reusable action button for all order status transitions

private struct PharmacyOrderActionButton: View {
    let labelKey: String
    let loadingLabelKey: String
    let systemImage: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(isLoading ? loadingLabelKey.localized : labelKey.localized)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .fill(isLoading ? PharmacyColor.primary.opacity(0.6) : PharmacyColor.primary)
            )
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - PharmacyOrderStatusTrackerView (3-step)

private struct PharmacyOrderStatusTrackerView: View {
    let status: PharmacyOrderAPIStatus
    let hasDelivery: Bool

    @State private var pulse = false

    private var steps: [String] {
        if hasDelivery {
            return [
                "pharmacy.status.preparing".localized,
                "pharmacy.status.on_the_way".localized,
                "pharmacy.status.delivered".localized
            ]
        } else {
            return [
                "pharmacy.status.preparing".localized,
                "pharmacy.status.ready".localized,
                "pharmacy.status.collected".localized
            ]
        }
    }

    /// 0 = Preparing, 1 = On the way, 2 = Delivered, -1 = hide tracker
    private var activeStep: Int {
        switch status {
        case .pending, .accepted, .preparing:
            return 0
        case .readyForPickup, .readyForDelivery, .outForDelivery:
            return 1
        case .delivered, .completed:
            return 2
        case .cancelled, .expired, .searching, .unknown:
            return -1
        }
    }

    var body: some View {
        if activeStep >= 0 {
            HStack(spacing: 0) {
                ForEach(0..<steps.count, id: \.self) { index in
                    stepView(index: index)
                    if index < steps.count - 1 {
                        connectorLine(filled: index < activeStep)
                    }
                }
            }
            .padding(PharmacySpacing.md)
            .background(PharmacyColor.card)
            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            )
            .onAppear { startPulse() }
            .onChange(of: activeStep) { _, _ in startPulse() }
        }
    }

    private func startPulse() {
        pulse = false
        withAnimation(
            .easeInOut(duration: 0.9)
            .repeatForever(autoreverses: true)
        ) {
            pulse = true
        }
    }

    private func stepView(index: Int) -> some View {
        let isActive = index == activeStep
        let isDone   = index < activeStep

        return VStack(spacing: 6) {
            ZStack {
                // Animated pulse ring on the current active step
                if isActive {
                    Circle()
                        .fill(PharmacyColor.primary.opacity(pulse ? 0.25 : 0.0))
                        .frame(width: 44, height: 44)
                        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
                }

                Circle()
                    .strokeBorder(
                        (isActive || isDone) ? PharmacyColor.primary : PharmacyColor.border,
                        lineWidth: 2
                    )
                    .frame(width: 32, height: 32)
                    .background(
                        Circle().fill((isActive || isDone) ? PharmacyColor.primary : PharmacyColor.card)
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.65), value: activeStep)

                if isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                } else if isActive {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.65), value: activeStep)

            Text(steps[index])
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(
                    (isActive || isDone) ? PharmacyColor.primary : PharmacyColor.textSecondary
                )
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .animation(.easeInOut(duration: 0.3), value: activeStep)
        }
        .frame(maxWidth: .infinity)
    }

    private func connectorLine(filled: Bool) -> some View {
        Rectangle()
            .fill(filled ? PharmacyColor.primary : PharmacyColor.border)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 22)
            .animation(.easeInOut(duration: 0.4), value: filled)
    }
}
