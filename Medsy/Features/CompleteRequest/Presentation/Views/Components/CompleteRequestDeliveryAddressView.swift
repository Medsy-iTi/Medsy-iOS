//
//  CompleteRequestDeliveryAddressView.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

struct CompleteRequestDeliveryAddressView: View {
    let savedAddress: String?
    let location: CompleteRequestLocation?
    let isLoading: Bool
    let validationMessage: String?
    let onChangeLocation: () -> Void

    var body: some View {
        CompleteRequestSectionCard(
            title: "complete_request.address.title".localized,
            systemImage: "house"
        ) {
            if isLoading {
                HStack(spacing: MedsySpacing.sm) {
                    ProgressView()
                    Text("complete_request.address.loading".localized)
                        .font(MedsyFont.body())
                        .foregroundStyle(AppColor.textSec)
                }
            } else if let location {
                Text(location.address)
                    .font(MedsyFont.body())
                    .foregroundStyle(AppColor.textPrim)

                CompleteRequestMapPreview(location: location)

                PrimaryButton(
                    title: "complete_request.address.change".localized,
                    systemImage: "map",
                    style: .secondary,
                    action: onChangeLocation
                )

                Label(
                    "complete_request.address.confirmed".localized,
                    systemImage: "checkmark.circle.fill"
                )
                .font(MedsyFont.caption())
                .foregroundStyle(AppColor.green)
            } else if let savedAddress {
                Label(savedAddress, systemImage: "house.fill")
                    .font(MedsyFont.bodyMedium())
                    .foregroundStyle(AppColor.textPrim)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("complete_request.address.saved_unconfirmed".localized)
                    .font(MedsyFont.caption())
                    .foregroundStyle(AppColor.textSec)
                    .padding(MedsySpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColor.pill)
                    .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))

                PrimaryButton(
                    title: "complete_request.address.confirm_on_map".localized,
                    systemImage: "map",
                    style: .secondary,
                    action: onChangeLocation
                )
            } else {
                Text("complete_request.address.empty".localized)
                    .font(MedsyFont.body())
                    .foregroundStyle(AppColor.textSec)
                    .padding(MedsySpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColor.pill)
                    .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))

                PrimaryButton(
                    title: "complete_request.address.choose".localized,
                    systemImage: "map",
                    style: .secondary,
                    action: onChangeLocation
                )
            }

            if let validationMessage {
                Text(validationMessage)
                    .font(MedsyFont.caption())
                    .foregroundStyle(AppColor.danger)
            }
        }
    }
}
