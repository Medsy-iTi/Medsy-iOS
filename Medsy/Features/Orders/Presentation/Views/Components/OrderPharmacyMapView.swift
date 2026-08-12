import MapKit
import SwiftUI

struct OrderPharmacyMapView: View {
    let pharmacies: [OrderPharmacyPresentationModel]
    let selectedPharmacyID: Int?
    let deliveryLocation: OrderCoordinatePresentation?
    let routeState: OrderRoutePresentationState
    let onSelectPharmacy: (Int) -> Void
    let onShowPharmacyLocation: (Int) -> Void
    let onOpenDirections: (OrderPharmacyPresentationModel) -> Void

    @State private var cameraPosition: MapCameraPosition

    init(
        pharmacies: [OrderPharmacyPresentationModel],
        selectedPharmacyID: Int?,
        deliveryLocation: OrderCoordinatePresentation?,
        routeState: OrderRoutePresentationState,
        onSelectPharmacy: @escaping (Int) -> Void,
        onShowPharmacyLocation: @escaping (Int) -> Void,
        onOpenDirections: @escaping (OrderPharmacyPresentationModel) -> Void
    ) {
        self.pharmacies = pharmacies
        self.selectedPharmacyID = selectedPharmacyID
        self.deliveryLocation = deliveryLocation
        self.routeState = routeState
        self.onSelectPharmacy = onSelectPharmacy
        self.onShowPharmacyLocation = onShowPharmacyLocation
        self.onOpenDirections = onOpenDirections
        _cameraPosition = State(initialValue: .region(Self.region(
            for: pharmacies.compactMap(\.coordinate) + [deliveryLocation].compactMap { $0 }
        )))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Label("orders.detail.pharmacy_locations".localized, systemImage: "map.fill")
                .font(AppColor.sans(15, .semibold))
                .foregroundStyle(AppColor.textPrim)

            if shouldShowMap {
                mapContent
            } else {
                locationPrompt
            }

            pharmacySelector
            routeStatus
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .medsyCardShadow()
        .onChange(of: selectedPharmacyID) { _, _ in focusSelectedPharmacy() }
        .onChange(of: deliveryLocation) { _, _ in focusSelectedPharmacy() }
    }

    private var shouldShowMap: Bool {
        switch routeState {
        case .idle:
            return deliveryLocation != nil
        default:
            return true
        }
    }

    private var mapContent: some View {
        Map(position: $cameraPosition) {
            if let deliveryLocation {
                Annotation("orders.detail.delivery_location".localized, coordinate: deliveryLocation.coordinate) {
                    ZStack {
                        Circle().fill(.white).frame(width: 22, height: 22)
                        Circle().fill(.blue).frame(width: 14, height: 14)
                    }
                    .shadow(radius: 2)
                }
            }

            ForEach(pharmacies) { pharmacy in
                if let coordinate = pharmacy.coordinate {
                    Annotation(pharmacy.name, coordinate: coordinate.coordinate) {
                        Button { onSelectPharmacy(pharmacy.id) } label: {
                            Image(systemName: "cross.case.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(
                                    pharmacy.id == selectedPharmacyID ? AppColor.green : AppColor.textSec,
                                    in: Circle()
                                )
                                .shadow(radius: 3)
                        }
                        .accessibilityLabel(pharmacy.name)
                    }
                }
            }

            if case .ready(let points) = routeState, points.count > 1 {
                MapPolyline(coordinates: points.map(\.coordinate))
                    .stroke(AppColor.green, style: StrokeStyle(lineWidth: 5, lineCap: .round))
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }

    private var locationPrompt: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Text("orders.detail.location_prompt".localized)
                .font(AppColor.sans(13))
                .foregroundStyle(AppColor.textSec)
                .fixedSize(horizontal: false, vertical: true)

            if let selectedPharmacy {
                PrimaryButton(
                    title: "orders.detail.show_location_path".localized,
                    systemImage: "map",
                    style: .secondary
                ) {
                    onShowPharmacyLocation(selectedPharmacy.id)
                }
            }
        }
        .padding(MedsySpacing.md)
        .background(AppColor.lightGreen.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
    }

    private var pharmacySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MedsySpacing.xs) {
                ForEach(pharmacies) { pharmacy in
                    Button { onSelectPharmacy(pharmacy.id) } label: {
                        HStack(spacing: MedsySpacing.xxs) {
                            Image(systemName: "cross.case.fill")
                            Text(pharmacy.name).lineLimit(1)
                        }
                        .font(AppColor.sans(13, .semibold))
                        .foregroundStyle(pharmacy.id == selectedPharmacyID ? .white : AppColor.green)
                        .padding(.horizontal, MedsySpacing.sm)
                        .padding(.vertical, MedsySpacing.xs)
                        .background(pharmacy.id == selectedPharmacyID ? AppColor.green : AppColor.lightGreen)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var routeStatus: some View {
        switch routeState {
        case .locating:
            statusRow("orders.detail.locating".localized, showsProgress: true)
        case .routing:
            statusRow("orders.detail.loading_route".localized, showsProgress: true)
        case .permissionDenied:
            statusRow("orders.detail.location_permission_denied".localized, showsProgress: false)
            openDirectionsButton
        case .locationUnavailable:
            statusRow("orders.detail.location_unavailable".localized, showsProgress: false)
            routeRecoveryActions
        case .routeUnavailable:
            statusRow("orders.detail.route_unavailable".localized, showsProgress: false)
            routeRecoveryActions
        case .idle:
            EmptyView()
        case .ready:
            openDirectionsButton
        }
    }

    @ViewBuilder
    private var routeRecoveryActions: some View {
        if let selectedPharmacy {
            HStack(spacing: MedsySpacing.md) {
                Button { onSelectPharmacy(selectedPharmacy.id) } label: {
                    Label("common.retry".localized, systemImage: "arrow.clockwise")
                }
                openDirectionsButton
            }
            .font(AppColor.sans(13, .semibold))
            .foregroundStyle(AppColor.green)
        }
    }

    @ViewBuilder
    private var openDirectionsButton: some View {
        if let selectedPharmacy {
            Button { onOpenDirections(selectedPharmacy) } label: {
                Label(
                    "orders.detail.open_directions".localized,
                    systemImage: "arrow.triangle.turn.up.right.diamond.fill"
                )
                .font(AppColor.sans(14, .semibold))
                .foregroundStyle(AppColor.green)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
    }

    private func statusRow(_ title: String, showsProgress: Bool) -> some View {
        HStack(spacing: MedsySpacing.xs) {
            if showsProgress {
                ProgressView().tint(AppColor.green)
            } else {
                Image(systemName: "location.slash.fill").foregroundStyle(AppColor.textSec)
            }
            Text(title)
                .font(AppColor.sans(13))
                .foregroundStyle(AppColor.textSec)
        }
    }

    private var selectedPharmacy: OrderPharmacyPresentationModel? {
        pharmacies.first { $0.id == selectedPharmacyID }
    }

    private func focusSelectedPharmacy() {
        let coordinates = [deliveryLocation, selectedPharmacy?.coordinate].compactMap { $0 }
        guard !coordinates.isEmpty else { return }
        withAnimation { cameraPosition = .region(Self.region(for: coordinates)) }
    }

    private static func region(for coordinates: [OrderCoordinatePresentation]) -> MKCoordinateRegion {
        guard let first = coordinates.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357),
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        }
        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        let minLatitude = latitudes.min() ?? first.latitude
        let maxLatitude = latitudes.max() ?? first.latitude
        let minLongitude = longitudes.min() ?? first.longitude
        let maxLongitude = longitudes.max() ?? first.longitude
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLatitude + maxLatitude) / 2,
                longitude: (minLongitude + maxLongitude) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: max((maxLatitude - minLatitude) * 1.6, 0.015),
                longitudeDelta: max((maxLongitude - minLongitude) * 1.6, 0.015)
            )
        )
    }
}

private extension OrderCoordinatePresentation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
