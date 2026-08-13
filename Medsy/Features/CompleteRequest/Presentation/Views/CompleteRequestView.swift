//
//  CompleteRequestView.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

struct CompleteRequestView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var viewModel: CompleteRequestViewModel
    let onBack: () -> Void
    let onChangeLocation: () -> Void
    let onCompleted: () -> Void

    init(
        viewModel: CompleteRequestViewModel,
        onBack: @escaping () -> Void,
        onChangeLocation: @escaping () -> Void,
        onCompleted: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onChangeLocation = onChangeLocation
        self.onCompleted = onCompleted
    }

    var body: some View {

        VStack(spacing: 0) {
            MedsyNavBar(
                title: "complete_request.title".localized,
                onBack: onBack
            )

            ScrollView {
                VStack(spacing: MedsySpacing.md) {
                    CompleteRequestSummaryView(
                        draft: viewModel.draft,
                        isExpanded: $viewModel.isSummaryExpanded
                    )

                    CompleteRequestDeliveryAddressView(
                        savedAddress: viewModel.savedAddress,
                        location: viewModel.deliveryLocation,
                        isLoading: viewModel.isLoadingAddress,
                        validationMessage: locationValidationMessage,
                        onChangeLocation: onChangeLocation
                    )

                    CompleteRequestPaymentMethodView(
                        selectedMethod: viewModel.paymentMethod,
                        onSelect: viewModel.selectPaymentMethod
                    )
                }
                .padding(.horizontal, MedsySpacing.md)
                .padding(.vertical, MedsySpacing.md)
            }
        }
        .background(AppColor.bg.ignoresSafeArea())
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(
                title: "complete_request.submit".localized,
                isLoading: viewModel.isSubmitting
            ) {
                Task {
                    if await viewModel.submit() {
                        onCompleted()
                    }
                }
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.vertical, MedsySpacing.sm)
            .background(AppColor.bg)
            .overlay(alignment: .top) {
                Divider().background(AppColor.border)
            }
        }
        .task {
            await viewModel.loadSavedAddress()
        }
        .alert(
            "complete_request.submit_error.title".localized,
            isPresented: Binding(
                get: { viewModel.submissionErrorMessage != nil },
                set: { if !$0 { viewModel.dismissSubmissionError() } }
            )
        ) {
            Button("common.ok".localized, role: .cancel) {
                viewModel.dismissSubmissionError()
            }
        } message: {
            Text(viewModel.submissionErrorMessage ?? "")
        }
        .localizedEnvironment()
        .id(languageManager.currentLanguage)
    }

    private var locationValidationMessage: String? {
        viewModel.validationErrors.contains(.locationRequired)
            ? CompleteRequestValidationError.locationRequired.localizedMessage
            : nil
    }
}
