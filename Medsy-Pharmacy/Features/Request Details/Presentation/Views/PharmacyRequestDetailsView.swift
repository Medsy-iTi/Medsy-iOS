//  PharmacyRequestDetailsView.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 19/07/2026.
//

import SwiftUI

struct PharmacyRequestDetailsView: View {
    @Environment(\.dismiss) private var dismiss

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

    var body: some View {
        VStack(spacing: 0) {
            PharmacyRequestDetailsHeaderView(
                orderId: requestModel.id,
                statusTitle: requestModel.statusTitle,
                onBack: {
                    dismiss()
                }
            )

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

                    PharmacyCustomerNotesCard(
                        notes: requestModel.notes
                    )
                }
                .padding(.horizontal, PharmacySpacing.md)
                .padding(.vertical, PharmacySpacing.sm)
            }
            .background(PharmacyColor.bg)

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
    }
}

#Preview("Arabic") {
    PharmacyRequestDetailsView()
        .environment(LanguageManager.shared)
        .pharmacyLocalizedEnvironment()
}
