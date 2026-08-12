import SwiftUI
import UniformTypeIdentifiers

struct PharmacyAddView: View {
    @Bindable var viewModel: PharmacySetupViewModel
    let onChooseOnMap: () -> Void
    let onCreated: () -> Void
    @State private var showsFileImporter = false

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyAuthHeader(
                title: "pharmacy.setup.add.title".localized,
                subtitle: "pharmacy.setup.add.subtitle".localized,
                systemImage: "building.2.fill"
            )

            VStack(spacing: PharmacySpacing.sm) {
                PharmacyAuthTextField(
                    title: "pharmacy.setup.name".localized,
                    kind: .name,
                    text: $viewModel.pharmacyName
                )

                PharmacyAuthTextField(
                    title: "pharmacy.setup.phone".localized,
                    kind: .phone,
                    text: $viewModel.phoneNumber
                )
            }

            locationSection

            PharmacyLicenseSelectionView(
                fileName: viewModel.license?.fileName,
                isLoading: viewModel.state == .loadingLicense
            ) {
                showsFileImporter = true
            }

            PharmacyAuthValidationMessage(message: viewModel.validationMessage)

            PharmacyPrimaryButton(
                title: "pharmacy.setup.add.action".localized,
                isLoading: viewModel.state == .submitting,
                isDisabled: !viewModel.canSubmit
            ) {
                Task {
                    if await viewModel.submit() {
                        onCreated()
                    }
                }
            }
        }
        .navigationTitle("pharmacy.setup.add.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isBusy)
        .fileImporter(
            isPresented: $showsFileImporter,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            guard case let .success(urls) = result, let url = urls.first else { return }
            Task { await viewModel.selectLicense(at: url) }
        }
        .alert(
            "common.error".localized,
            isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.dismissError() } }
            )
        ) {
            Button("common.ok".localized) { viewModel.dismissError() }
        } message: {
            if let message = viewModel.alertMessage { Text(message) }
        }
    }

    private var locationSection: some View {
        VStack(spacing: PharmacySpacing.sm) {
            HStack(spacing: PharmacySpacing.sm) {
                Button {
                    Task { await viewModel.useCurrentLocation() }
                } label: {
                    Label(
                        "pharmacy.setup.location.current".localized,
                        systemImage: "location.fill"
                    )
                    .font(PharmacyColor.sans(13, .semibold))
                    .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(PharmacyColor.primary)
                .disabled(viewModel.isBusy)

                Button(action: onChooseOnMap) {
                    Label(
                        "pharmacy.setup.location.map".localized,
                        systemImage: "map.fill"
                    )
                    .font(PharmacyColor.sans(13, .semibold))
                    .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.bordered)
                .tint(PharmacyColor.primary)
                .disabled(viewModel.isBusy)
            }

            if viewModel.state == .resolvingLocation {
                HStack(spacing: PharmacySpacing.sm) {
                    ProgressView().tint(PharmacyColor.primary)
                    Text("pharmacy.setup.location.resolving".localized)
                        .font(PharmacyColor.sans(13))
                        .foregroundStyle(PharmacyColor.textSecondary)
                    Spacer()
                }
            }

            PharmacySetupReadOnlyField(
                title: "pharmacy.setup.location.city".localized,
                value: viewModel.location?.city ?? "",
                systemImage: "building.2"
            )

            PharmacySetupReadOnlyField(
                title: "pharmacy.setup.location.province".localized,
                value: viewModel.location?.province ?? "",
                systemImage: "map"
            )
        }
    }
}

#Preview {
    NavigationStack {
        PharmacyAddView(
            viewModel: PharmacySetupViewModel(
                locationProvider: PreviewPharmacyLocationProvider(),
                createAction: { _ in
                    CreatedPharmacy(id: 1, name: "Medsy", latitude: 30, longitude: 31, address: "Cairo", phoneNumber: nil)
                }
            ),
            onChooseOnMap: {},
            onCreated: {}
        )
    }
    .environment(LanguageManager.shared)
}

@MainActor
private final class PreviewPharmacyLocationProvider: PharmacyLocationProviding {
    func currentLocation() async throws -> PharmacyLocation {
        PharmacyLocation(latitude: 30.0444, longitude: 31.2357, city: "Cairo", province: "Cairo")
    }

    func location(latitude: Double, longitude: Double) async throws -> PharmacyLocation {
        PharmacyLocation(latitude: latitude, longitude: longitude, city: "Cairo", province: "Cairo")
    }
}
