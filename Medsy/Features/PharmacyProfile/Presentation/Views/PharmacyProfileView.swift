//  PharmacyProfileView.swift
//  Medsy
//
//  Created by Antoneos Philip on 20/07/2026.

import SwiftUI

struct PharmacyProfileView: View {
    @State private var viewModel: PharmacyProfileViewModel

    init(viewModel: PharmacyProfileViewModel = PharmacyProfileViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.bg
                    .ignoresSafeArea()

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()
                        .tint(AppColor.green)
                        .scaleEffect(1.2)

                case .loaded(let pharmacy):
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: MedsySpacing.lg) {
                            PharmacyHeaderView(name: pharmacy.name)

                            PharmacyQuickActionsView(
                                onCall: { viewModel.callPharmacy(phoneNumber: pharmacy.phoneNumber) },
                                onDirections: { viewModel.openDirections(latitude: pharmacy.latitude, longitude: pharmacy.longitude, name: pharmacy.name) },
                                onShare: { viewModel.sharePharmacy(name: pharmacy.name, address: pharmacy.address) }
                            )

                            PharmacyLocationCardView(
                                address: pharmacy.address,
                                latitude: pharmacy.latitude,
                                longitude: pharmacy.longitude,
                                onOpenDirections: { viewModel.openDirections(latitude: pharmacy.latitude, longitude: pharmacy.longitude, name: pharmacy.name) }
                            )

                            PharmacyContactCardView(
                                phoneNumber: pharmacy.phoneNumber,
                                onCall: { viewModel.callPharmacy(phoneNumber: pharmacy.phoneNumber) }
                            )
                        }
                        .padding(.horizontal, MedsySpacing.md)
                        .padding(.vertical, MedsySpacing.md)
                        .padding(.bottom, 40)
                    }

                case .error(let message):
                    VStack(spacing: MedsySpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(AppColor.errorRed)

                        Text(message)
                            .font(MedsyFont.body(15))
                            .foregroundStyle(AppColor.textSec)

                        Button(action: { viewModel.loadPharmacy() }) {
                            Text("Retry")
                                .font(MedsyFont.button(14))
                                .foregroundStyle(.white)
                                .padding(.horizontal, MedsySpacing.lg)
                                .padding(.vertical, MedsySpacing.xs)
                                .background(AppColor.green)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .navigationTitle("pharmacyProfile.title".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
