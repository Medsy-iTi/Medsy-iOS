// PharmacyRequestDetailsView.swift

import SwiftUI

struct PharmacyRequestDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: PharmacyRequestDetailsViewModel?

    @State private var requestModel: PharmacyRequestDetailsModel?

    @State private var showFullPrescriptionImage: Bool = false
    @State private var itemToReplace: PharmacyOrderItem? = nil

    init(requestModel: PharmacyRequestDetailsModel? = nil, viewModel: PharmacyRequestDetailsViewModel? = nil) {
        self._requestModel = State(initialValue: requestModel)
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let viewModel, viewModel.state == .loading {
                VStack(spacing: 12) {
                    Spacer()
                    ProgressView()
                    Text("pharmacy.request.loading".localized)
                        .font(PharmacyColor.sans(14, .medium))
                        .foregroundStyle(PharmacyColor.textSecondary)
                    Spacer()
                }
            } else if let activeModel = viewModel?.requestModel ?? requestModel {
                let model = Binding(
                    get: { viewModel?.requestModel ?? activeModel },
                    set: {
                        viewModel?.requestModel = $0
                        requestModel = $0
                    }
                )
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.md) {
                        PharmacyContactInfoCard(
                            headerStyle: .orderInfo(orderId: model.wrappedValue.id, date: model.wrappedValue.createdAt),
                            name: model.wrappedValue.customer.name,
                            phone: model.wrappedValue.customer.phone,
                            onContact: {
                                let cleanPhone = model.wrappedValue.customer.phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                                if let url = URL(string: "tel://\(cleanPhone)") {
                                    UIApplication.shared.open(url)
                                }
                            },
                            address: model.wrappedValue.customer.address,
                            onLocationTap: {
                                if let lat = model.wrappedValue.deliveryLatitude, let lon = model.wrappedValue.deliveryLongitude, lat != 0, lon != 0 {
                                    if let url = URL(string: "maps://?q=\(lat),\(lon)"), UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    } else if let url = URL(string: "https://maps.apple.com/?q=\(lat),\(lon)") {
                                        UIApplication.shared.open(url)
                                    }
                                } else if let encoded = model.wrappedValue.customer.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: "https://maps.apple.com/?q=\(encoded)") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )

                        PharmacyOrderItemsCard(
                            items: model.items,
                            deliveryFee: model.wrappedValue.deliveryFee,
                            total: model.wrappedValue.total,
                            isOfferSubmitted: viewModel?.isOfferSubmitted ?? false,
                            onSelectAlternative: { item in
                                itemToReplace = item
                            }
                        )

                        if model.wrappedValue.prescriptionImageUrl != nil {
                            PharmacyPrescriptionCard(
                                uiImage: viewModel?.prescriptionUIImage,
                                onEnlarge: {
                                    showFullPrescriptionImage = true
                                }
                            )
                        }

                        PharmacyCustomerNotesCard(
                            notes: model.wrappedValue.notes
                        )

                        PharmacyOrderTotalCard(
                            total: model.wrappedValue.total,
                            paymentMethod: model.wrappedValue.paymentMethod
                        )
                    }
                    .padding(.horizontal, PharmacySpacing.md)
                    .padding(.vertical, PharmacySpacing.sm)
                }
                .background(PharmacyColor.bg)
            } else {
                VStack(spacing: 12) {
                    Spacer()

                    VStack(spacing: PharmacySpacing.sm) {
                        PharmacyIconTile(systemImage: "tray", size: 64, iconSize: 26)
                        Text("pharmacy.request.no_data".localized)
                            .font(PharmacyColor.sans(14, .semibold))
                            .foregroundStyle(PharmacyColor.textSecondary)
                    }
                    .pharmacyCard(elevation: .subtle)

                    Spacer()
                }
                .padding(PharmacySpacing.md)
            }

            if viewModel?.showBottomBar == true {
                PharmacyRequestDetailsBottomBar(
                    isSubmitting: viewModel?.isSubmitting ?? false,
                    buttonTitle: viewModel?.bottomButtonTitle ?? "",
                    isButtonDisabled: viewModel?.isBottomButtonDisabled ?? false,
                    onSendOffer: {
                        Task {
                            await viewModel?.sendOffer()
                        }
                    }
                )
            }
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .navigationTitle("pharmacy.request.details.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert("pharmacy.request.alert.title".localized, isPresented: Binding(get: {
            viewModel?.showSuccessAlert ?? false
        }, set: { newValue in
            viewModel?.showSuccessAlert = newValue
        })) {
            Button("common.ok".localized, role: .cancel) { }
        } message: {
            Text(viewModel?.alertMessage ?? "")
        }
        .sheet(isPresented: $showFullPrescriptionImage) {
            NavigationStack {
                VStack {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        PharmacyAuthenticatedAsyncImage(uiImage: viewModel?.prescriptionUIImage) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("common.close".localized) {
                            showFullPrescriptionImage = false
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
        }
        .sheet(item: $itemToReplace) { item in
            PharmacyProductSearchView { selectedProduct in
                viewModel?.replaceItem(item, with: selectedProduct)
            }
        }
        .task {
            if let viewModel {
                await viewModel.loadDetails()
                if let model = viewModel.requestModel {
                    self.requestModel = model
                }
                await viewModel.loadPrescriptionImage()
            }
        }
    }
}
