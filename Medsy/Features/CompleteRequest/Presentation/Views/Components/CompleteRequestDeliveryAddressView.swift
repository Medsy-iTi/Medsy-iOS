//
//  CompleteRequestDeliveryAddressView.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

struct CompleteRequestDeliveryAddressView: View {
    let savedAddress: String?
    let savedLocation: CompleteRequestLocation?
    let customLocation: CompleteRequestLocation?
    let selectedOption: CompleteRequestAddressOption
    let isLoading: Bool
    let validationMessage: String?
    let onSelectSavedAddress: () -> Void
    let onSelectCustomAddress: () -> Void
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
            } else {
                addressOptions
            }

            if let validationMessage {
                Text(validationMessage)
                    .font(MedsyFont.caption())
                    .foregroundStyle(AppColor.danger)
            }
        }
    }

    @ViewBuilder
    private var addressOptions: some View {
        if let savedLocation {
            CompleteRequestAddressOptionCard(
                title: "complete_request.address.default".localized,
                subtitle: "complete_request.address.default_badge".localized,
                systemImage: "house.fill",
                isSelected: selectedOption == .saved,
                action: onSelectSavedAddress
            ) {
                VStack(alignment: .leading, spacing: MedsySpacing.sm) {
                    Text(savedLocation.address)
                        .font(MedsyFont.body())
                        .foregroundStyle(AppColor.textPrim)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    CompleteRequestMapPreview(location: savedLocation)
                }
            }
        } else if let savedAddress, !savedAddress.isEmpty {
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
        } else {
            Text("complete_request.address.empty".localized)
                .font(MedsyFont.body())
                .foregroundStyle(AppColor.textSec)
                .padding(MedsySpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColor.pill)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
        }

        CompleteRequestAddressOptionCard(
            title: "complete_request.address.other".localized,
            subtitle: customLocation == nil
                ? "complete_request.address.other.subtitle".localized
                : "complete_request.address.confirmed".localized,
            systemImage: "mappin.and.ellipse",
            isSelected: selectedOption == .custom,
            action: {
                onSelectCustomAddress()
                if customLocation == nil {
                    onChangeLocation()
                }
            }
        ) {
            VStack(alignment: .leading, spacing: MedsySpacing.sm) {
                if let customLocation {
                    Text(customLocation.address)
                        .font(MedsyFont.body())
                        .foregroundStyle(AppColor.textPrim)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    CompleteRequestMapPreview(location: customLocation)
                }

                PrimaryButton(
                    title: customLocation == nil
                        ? "complete_request.address.choose".localized
                        : "complete_request.address.change".localized,
                    systemImage: "map",
                    style: .secondary
                ) {
                    onSelectCustomAddress()
                    onChangeLocation()
                }

                Label(
                    customLocation == nil
                        ? "complete_request.address.location_required".localized
                        : "complete_request.address.confirmed".localized,
                    systemImage: customLocation == nil ? "info.circle" : "checkmark.circle.fill"
                )
                .font(MedsyFont.caption())
                .foregroundStyle(customLocation == nil ? AppColor.textSec : AppColor.green)
            }
        }
    }
}
