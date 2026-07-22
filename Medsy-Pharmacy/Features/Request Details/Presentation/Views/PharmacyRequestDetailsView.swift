//  PharmacyRequestDetailsView.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyRequestDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    var viewModel: PharmacyRequestDetailsViewModel?

    @State private var requestModel = PharmacyRequestDetailsModel(
        id: "1258",
        statusTitle: "جديد",
        customer: PharmacyCustomerInfo(
            name: "أحمد محمد",
            phone: "010 1234 5678",
            address: "شارع النيل، المعادي، القاهرة"
        ),
        items: [
            PharmacyOrderItem(id: "1", name: "بانادول اكسترا", spec: "500 مجم - 24 قرص", quantity: 1, price: 68.0, imageName: nil),
            PharmacyOrderItem(id: "2", name: "رينادول سينوس", spec: "20 قرص", quantity: 1, price: 52.0, imageName: nil),
            PharmacyOrderItem(id: "3", name: "فيتامين سي 1000 مجم", spec: "20 قرص فوار", quantity: 1, price: 45.0, imageName: nil)
        ],
        deliveryFee: 15.0,
        notes: "يرجى الاتصال قبل الوصول"
    )

    @State private var selectedItemForAlternative: PharmacyOrderItem? = nil
    @State private var alternativeText: String = ""
    @State private var showAlternativeAlert: Bool = false
    @State private var isSideBySideActive: Bool = false
    @State private var showFullPrescriptionImage: Bool = false
    @State private var offerNotesText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            PharmacyRequestDetailsHeaderView(
                orderId: requestModel.id,
                statusTitle: requestModel.statusTitle,
                onBack: {
                    dismiss()
                }
            )

            if let viewModel, viewModel.state == .loading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.md) {
                        PharmacyCustomerInfoCard(
                            customer: requestModel.customer,
                            onContact: {
                                if let url = URL(string: "tel://\(requestModel.customer.phone.replacingOccurrences(of: " ", with: ""))") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )

                        PharmacyPrescriptionCard(
                            imageUrl: nil,
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
                                            Text("صورة الروشتة بخط اليد")
                                                .font(PharmacyColor.sans(12, .semibold))
                                        }
                                    }
                                }

                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("pharmacy.request.ai_extracted_items".localized)
                                        .font(PharmacyColor.sans(13, .bold))
                                        .foregroundStyle(PharmacyColor.textPrimary)

                                    PharmacyOrderItemsCard(
                                        items: $requestModel.items,
                                        deliveryFee: requestModel.deliveryFee,
                                        total: requestModel.total,
                                        onToggleAlternative: { itemId in
                                            if let index = requestModel.items.firstIndex(where: { $0.id == itemId }) {
                                                selectedItemForAlternative = requestModel.items[index]
                                                alternativeText = requestModel.items[index].alternativeMedicine ?? ""
                                                showAlternativeAlert = true
                                            }
                                        }
                                    )
                                }
                            }
                        } else {
                            PharmacyOrderItemsCard(
                                items: $requestModel.items,
                                deliveryFee: requestModel.deliveryFee,
                                total: requestModel.total,
                                onToggleAlternative: { itemId in
                                    if let index = requestModel.items.firstIndex(where: { $0.id == itemId }) {
                                        selectedItemForAlternative = requestModel.items[index]
                                        alternativeText = requestModel.items[index].alternativeMedicine ?? ""
                                        showAlternativeAlert = true
                                    }
                                }
                            )
                        }

                        PharmacyCustomerNotesCard(
                            notes: requestModel.notes
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
        .alert("إضافة دواء بديل", isPresented: $showAlternativeAlert) {
            TextField("اسم الدواء البديل", text: $alternativeText)
            Button("تأكيد البديـل") {
                if let selected = selectedItemForAlternative,
                   let index = requestModel.items.firstIndex(where: { $0.id == selected.id }) {
                    requestModel.items[index].isAvailable = false
                    requestModel.items[index].alternativeMedicine = alternativeText.isEmpty ? "بديل متوفر" : alternativeText
                }
            }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("أدخل اسم الدواء البديل المقترح للعميل في حالة عدم توفر المنتج الأصلي.")
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
                            Text("معاينة صورة الروشتة بخط اليد")
                                .font(PharmacyColor.sans(16, .bold))
                                .foregroundStyle(.white)
                                .padding(.top, 16)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("إغلاق") {
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

#Preview("Arabic") {
    PharmacyRequestDetailsView()
        .environment(LanguageManager.shared)
        .pharmacyLocalizedEnvironment()
}
