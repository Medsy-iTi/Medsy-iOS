//
//  PharmacyRequestDetailsView.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyRequestDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    var viewModel: PharmacyRequestDetailsViewModel?

    @State private var requestModel: PharmacyRequestDetailsModel?
    @State private var notesForCustomerText: String = ""
    @State private var showFullPrescriptionImage: Bool = false

    init(requestModel: PharmacyRequestDetailsModel? = nil, viewModel: PharmacyRequestDetailsViewModel? = nil) {
        self._requestModel = State(initialValue: requestModel)
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            PharmacyRequestDetailsHeaderView(
                orderId: requestModel?.id ?? "1",
                statusTitle: requestModel?.statusTitle ?? "",
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
            } else if let model = Binding($requestModel) {
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

            PharmacyRequestDetailsBottomBar(
                onAccept: {
                    dismiss()
                },
                onReject: {
                    dismiss()
                },
                onContact: {
                    if let model = requestModel,
                       let url = URL(string: "tel://\(model.customer.phone.replacingOccurrences(of: " ", with: ""))") {
                        UIApplication.shared.open(url)
                    }
                }
            )
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showFullPrescriptionImage) {
            NavigationStack {
                VStack {
                    ZStack {
                        Color.black.ignoresSafeArea()
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
            if requestModel == nil, let viewModel {
                await viewModel.loadDetails()
                if let model = viewModel.requestModel {
                    self.requestModel = model
                }
            }
        }
    }
}

#Preview("English") {
    PharmacyRequestDetailsView(
        requestModel: PharmacyRequestDetailsModel(
            id: "1",
            minutesAgo: 0,
            statusTitle: "PENDING",
            customer: PharmacyCustomerInfo(name: "Customer #11", phone: "01012345678", address: "string"),
            items: [
                PharmacyOrderItem(id: "1", name: "Product #1", spec: "1", quantity: 1, price: 0.0, imageName: nil),
                PharmacyOrderItem(id: "2", name: "Product #2", spec: "1", quantity: 1, price: 0.0, imageName: nil)
            ],
            deliveryFee: 0.0,
            notes: ""
        )
    )
    .environment(LanguageManager.shared)
    .pharmacyLocalizedEnvironment()
}
