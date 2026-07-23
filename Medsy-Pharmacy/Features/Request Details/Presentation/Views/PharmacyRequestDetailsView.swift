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
    @State private var selectedItemForAlternative: PharmacyOrderItem? = nil
    @State private var alternativeText: String = ""
    @State private var showAlternativeAlert: Bool = false
    @State private var isSideBySideActive: Bool = false
    @State private var showFullPrescriptionImage: Bool = false
    @State private var offerNotesText: String = ""

    init(requestModel: PharmacyRequestDetailsModel? = nil, viewModel: PharmacyRequestDetailsViewModel? = nil) {
        self._requestModel = State(initialValue: requestModel)
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            PharmacyRequestDetailsHeaderView(
                orderId: requestModel?.id ?? "—",
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
                            customer: model.wrappedValue.customer,
                            onContact: {
                                if let url = URL(string: "tel://\(model.wrappedValue.customer.phone.replacingOccurrences(of: " ", with: ""))") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )

                        PharmacyPrescriptionCard(
                            imageUrl: model.wrappedValue.prescriptionImageUrl,
                            onEnlarge: {
                                showFullPrescriptionImage = true
                            },
                            onToggleSideBySide: {
                                withAnimation {
                                    isSideBySideActive.toggle()
                                }
                            },
                            isSideBySideActive: isSideBySideActive
                        )

                        if isSideBySideActive {
                            HStack(alignment: .top, spacing: PharmacySpacing.sm) {
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("pharmacy.request.prescription_image".localized)
                                        .font(PharmacyColor.sans(13, .bold))
                                        .foregroundStyle(PharmacyColor.textPrimary)

                                    ZStack {
                                        RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                                            .fill(PharmacyColor.mutedSurface)
                                            .frame(height: 260)

                                        VStack(spacing: 6) {
                                            Image(systemName: "doc.text.image.fill")
                                                .font(.system(size: 36))
                                                .foregroundStyle(PharmacyColor.primary)
                                            Text("pharmacy.request.prescription_handwritten".localized)
                                                .font(PharmacyColor.sans(12, .semibold))
                                        }
                                    }
                                }

                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("pharmacy.request.ai_extracted_items".localized)
                                        .font(PharmacyColor.sans(13, .bold))
                                        .foregroundStyle(PharmacyColor.textPrimary)

                                    PharmacyOrderItemsCard(
                                        items: model.items,
                                        deliveryFee: model.wrappedValue.deliveryFee,
                                        total: model.wrappedValue.total,
                                        onToggleAlternative: { itemId in
                                            if let index = model.wrappedValue.items.firstIndex(where: { $0.id == itemId }) {
                                                selectedItemForAlternative = model.wrappedValue.items[index]
                                                alternativeText = model.wrappedValue.items[index].alternativeMedicine ?? ""
                                                showAlternativeAlert = true
                                            }
                                        }
                                    )
                                }
                            }
                        } else {
                            PharmacyOrderItemsCard(
                                items: model.items,
                                deliveryFee: model.wrappedValue.deliveryFee,
                                total: model.wrappedValue.total,
                                onToggleAlternative: { itemId in
                                    if let index = model.wrappedValue.items.firstIndex(where: { $0.id == itemId }) {
                                        selectedItemForAlternative = model.wrappedValue.items[index]
                                        alternativeText = model.wrappedValue.items[index].alternativeMedicine ?? ""
                                        showAlternativeAlert = true
                                    }
                                }
                            )
                        }

                        PharmacyCustomerNotesCard(
                            notes: model.wrappedValue.notes
                        )

                        VStack(alignment: .trailing, spacing: 6) {
                            Text("pharmacy.request.offer_notes".localized)
                                .font(PharmacyColor.sans(14, .bold))
                                .foregroundStyle(PharmacyColor.textPrimary)

                            TextField("pharmacy.request.offer_notes_placeholder".localized, text: $offerNotesText, axis: .vertical)
                                .lineLimit(3...5)
                                .font(PharmacyColor.sans(13, .regular))
                                .padding(12)
                                .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                                        .stroke(PharmacyColor.border, lineWidth: 1)
                                )
                        }
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
                }
            )
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("pharmacy.request.alert_add_alternative".localized, isPresented: $showAlternativeAlert) {
            TextField("pharmacy.request.alternative_placeholder".localized, text: $alternativeText)
            Button("pharmacy.request.confirm_alternative".localized) {
                if let selected = selectedItemForAlternative,
                   var current = requestModel,
                   let index = current.items.firstIndex(where: { $0.id == selected.id }) {
                    current.items[index].isAvailable = false
                    current.items[index].alternativeMedicine = alternativeText.isEmpty ? "pharmacy.request.alternative_selected".localized : alternativeText
                    requestModel = current
                }
            }
            Button("pharmacy.request.cancel".localized, role: .cancel) {}
        } message: {
            Text("pharmacy.request.alternative_message".localized)
        }
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

#Preview("Arabic") {
    PharmacyRequestDetailsView()
        .environment(LanguageManager.shared)
        .pharmacyLocalizedEnvironment()
}
