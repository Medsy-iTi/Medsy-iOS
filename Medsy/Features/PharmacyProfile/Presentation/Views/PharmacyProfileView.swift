import SwiftUI

struct PharmacyProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PharmacyProfileViewModel
    private let onBack: (() -> Void)?

    init(
        viewModel: PharmacyProfileViewModel = DIContainer.shared.resolve(PharmacyProfileViewModel.self),
        onBack: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
    }

    init(pharmacyId: Int, onBack: (() -> Void)? = nil) {
        _viewModel = State(initialValue: PharmacyProfileViewModel(pharmacyId: pharmacyId))
        self.onBack = onBack
    }

    init(pharmacyID: Int, onBack: (() -> Void)? = nil) {
        _viewModel = State(initialValue: PharmacyProfileViewModel(pharmacyId: pharmacyID))
        self.onBack = onBack
    }

    var body: some View {
        VStack(spacing: 0) {
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
                            Text("common.retry".localized)
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
        }
        .background(AppColor.bg)
        .navigationTitle("pharmacyProfile.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard case .idle = viewModel.state else { return }
            viewModel.loadPharmacy()
        }
    }

}
