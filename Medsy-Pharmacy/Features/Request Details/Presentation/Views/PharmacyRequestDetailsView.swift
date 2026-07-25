//
//  PharmacyRequestDetailsView.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyRequestDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: PharmacyRequestDetailsViewModel?

    @State private var requestModel: PharmacyRequestDetailsModel?
    @State private var notesForCustomerText: String = ""
    @State private var showFullPrescriptionImage: Bool = false

    init(requestModel: PharmacyRequestDetailsModel? = nil, viewModel: PharmacyRequestDetailsViewModel? = nil) {
        self._requestModel = State(initialValue: requestModel)
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            PharmacyRequestDetailsHeaderView(
                orderId: (viewModel?.requestModel?.id ?? requestModel?.id) ?? "1",
                statusTitle: (viewModel?.requestModel?.statusTitle ?? requestModel?.statusTitle) ?? "",
                onBack: {
                    dismiss()
                }
            )

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
                        PharmacyCustomerInfoCard(
                            orderId: model.wrappedValue.id,
                            minutesAgo: model.wrappedValue.minutesAgo,
                            customer: model.wrappedValue.customer,
                            onContact: {
                                if let url = URL(string: "tel://\(model.wrappedValue.customer.phone.replacingOccurrences(of: " ", with: ""))") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )

                        PharmacyOrderItemsCard(
                            items: model.items,
                            deliveryFee: model.wrappedValue.deliveryFee,
                            total: model.wrappedValue.total
                        )

                        PharmacyPrescriptionCard(
                            imageUrl: model.wrappedValue.prescriptionImageUrl,
                            onEnlarge: {
                                showFullPrescriptionImage = true
                            }
                        )

                        PharmacyCustomerNotesCard(
                            notes: model.wrappedValue.notes
                        )

                        PharmacyNotesForCustomerCard(
                            text: $notesForCustomerText
                        )

                        PharmacyOrderTotalCard(
                            total: model.wrappedValue.total
                        )
                    }
                    .padding(.horizontal, PharmacySpacing.md)
                    .padding(.vertical, PharmacySpacing.sm)
                }
                .background(PharmacyColor.bg)
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "tray")
                        .font(.system(size: 44))
                        .foregroundStyle(PharmacyColor.textSecondary)
                    Text("pharmacy.request.no_data".localized)
                        .font(PharmacyColor.sans(14, .semibold))
                        .foregroundStyle(PharmacyColor.textSecondary)
                    Spacer()
                }
            }

            if viewModel?.showBottomBar == true {
                PharmacyRequestDetailsBottomBar(
                    isSubmitting: viewModel?.isSubmitting ?? false,
                    buttonTitle: viewModel?.bottomButtonTitle ?? "",
                    isButtonDisabled: viewModel?.isBottomButtonDisabled ?? false,
                    showSecondaryButtons: viewModel?.showSecondaryButtons ?? false,
                    onSendOffer: {
                        Task {
                            await viewModel?.sendOffer()
                        }
                    },
                    onReject: {
                        dismiss()
                    },
                    onContact: {
                        if let model = viewModel?.requestModel ?? requestModel,
                           let url = URL(string: "tel://\(model.customer.phone.replacingOccurrences(of: " ", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            }
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("تنبيه", isPresented: Binding(get: {
            viewModel?.showSuccessAlert ?? false
        }, set: { newValue in
            viewModel?.showSuccessAlert = newValue
        })) {
            Button("حسناً", role: .cancel) { }
        } message: {
            Text(viewModel?.alertMessage ?? "")
        }
        .sheet(isPresented: $showFullPrescriptionImage) {
            NavigationStack {
                VStack {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        if let imageUrlStr = viewModel?.requestModel?.prescriptionImageUrl ?? requestModel?.prescriptionImageUrl,
                           let url = URL(string: imageUrlStr) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            VStack {
                                Image(systemName: "doc.text.image.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(.white.opacity(0.8))
                                Text("pharmacy.request.preview_prescription".localized)
                                    .font(PharmacyColor.sans(16, .bold))
                                    .foregroundStyle(.white)
                                    .padding(.top, 16)
                            }
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
        .task {
            if let viewModel {
                await viewModel.loadDetails()
                if let model = viewModel.requestModel {
                    self.requestModel = model
                }
            }
        }
    }
}
