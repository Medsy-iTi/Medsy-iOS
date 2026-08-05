//
//  CompleteRequestReceiveMethodView.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

struct CompleteRequestReceiveMethodView: View {
    let selectedMethod: CompleteRequestReceiveMethod
    let onSelect: (CompleteRequestReceiveMethod) -> Void

    var body: some View {
        CompleteRequestSectionCard(
            title: "complete_request.receive.title".localized,
            systemImage: "shippingbox"
        ) {
            Text("complete_request.receive.subtitle".localized)
                .font(MedsyFont.caption())
                .foregroundStyle(AppColor.textSec)

            HStack(alignment: .top, spacing: MedsySpacing.sm) {
                CompleteRequestOptionCard(
                    title: "complete_request.receive.delivery".localized,
                    subtitle: "complete_request.receive.delivery.subtitle".localized,
                    systemImage: "truck.box",
                    isSelected: selectedMethod == .delivery,
                    action: { onSelect(.delivery) }
                )

                CompleteRequestOptionCard(
                    title: "complete_request.receive.pickup".localized,
                    subtitle: "complete_request.receive.pickup.subtitle".localized,
                    systemImage: "storefront",
                    isSelected: selectedMethod == .pickup,
                    action: { onSelect(.pickup) }
                )
            }
        }
    }
}
