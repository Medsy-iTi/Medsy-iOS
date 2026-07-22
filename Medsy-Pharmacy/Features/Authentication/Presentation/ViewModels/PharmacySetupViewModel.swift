import Foundation
import Observation

enum PharmacySetupState: Equatable {
    case idle
    case resolvingLocation
    case loadingLicense
    case submitting
    case success
    case error(String)
}

@MainActor
@Observable
final class PharmacySetupViewModel {
    var pharmacyName = ""
    var phoneNumber = ""
    private(set) var location: PharmacyLocation?
    private(set) var license: PharmacyLicenseDocument?
    private(set) var state: PharmacySetupState = .idle
    private(set) var validationMessage: String?

    private let locationProvider: PharmacyLocationProviding
    private let createAction: (CreatePharmacyInput) async throws -> CreatedPharmacy

    init(
        locationProvider: PharmacyLocationProviding,
        createAction: @escaping (CreatePharmacyInput) async throws -> CreatedPharmacy
    ) {
        self.locationProvider = locationProvider
        self.createAction = createAction
    }

    var isBusy: Bool {
        switch state {
        case .resolvingLocation, .loadingLicense, .submitting:
            true
        default:
            false
        }
    }

    var canSubmit: Bool {
        !pharmacyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && phoneNumber.range(of: "^01[0125][0-9]{8}$", options: .regularExpression) != nil
            && location != nil
            && license != nil
            && !isBusy
    }

    var alertMessage: String? {
        guard case let .error(message) = state else { return nil }
        return message
    }

    func useCurrentLocation() async {
        guard !isBusy else { return }
        state = .resolvingLocation
        validationMessage = nil

        do {
            location = try await locationProvider.currentLocation()
            state = .idle
        } catch is CancellationError {
            state = .idle
        } catch {
            show(error)
        }
    }

    func selectMapCoordinate(latitude: Double, longitude: Double) async {
        guard state != .submitting else { return }
        state = .resolvingLocation
        validationMessage = nil

        do {
            location = try await locationProvider.location(
                latitude: latitude,
                longitude: longitude
            )
            state = .idle
        } catch is CancellationError {
            state = .idle
        } catch {
            show(error)
        }
    }

    func selectLicense(at url: URL) async {
        guard !isBusy else { return }
        state = .loadingLicense
        validationMessage = nil

        let hasAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasAccess { url.stopAccessingSecurityScopedResource() }
        }

        do {
            guard url.pathExtension.lowercased() == "pdf" else {
                throw PharmacySetupValidationError.licenseMustBePDF
            }

            let values = try url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
            guard values.isRegularFile == true else {
                throw PharmacySetupValidationError.unreadableLicense
            }
            if let fileSize = values.fileSize,
               fileSize > PharmacyLicenseDocument.maximumByteCount {
                throw PharmacySetupValidationError.licenseTooLarge
            }

            let data = try Data(contentsOf: url, options: [.mappedIfSafe])
            guard data.count <= PharmacyLicenseDocument.maximumByteCount else {
                throw PharmacySetupValidationError.licenseTooLarge
            }
            guard data.starts(with: Data("%PDF".utf8)) else {
                throw PharmacySetupValidationError.licenseMustBePDF
            }

            license = PharmacyLicenseDocument(
                fileName: url.lastPathComponent,
                data: data
            )
            state = .idle
        } catch let error as PharmacySetupValidationError {
            show(error)
        } catch {
            show(PharmacySetupValidationError.unreadableLicense)
        }
    }

    func submit() async -> Bool {
        guard !isBusy else { return false }
        guard let location, let license else {
            validationMessage = PharmacySetupValidationError.missingRequiredFields.localizedDescription
            return false
        }

        state = .submitting
        validationMessage = nil

        do {
            _ = try await createAction(
                CreatePharmacyInput(
                    name: pharmacyName,
                    phoneNumber: phoneNumber,
                    location: location,
                    license: license
                )
            )
            state = .success
            return true
        } catch is CancellationError {
            state = .idle
            return false
        } catch {
            show(error)
            return false
        }
    }

    func dismissError() {
        guard case .error = state else { return }
        state = .idle
    }

    private func show(_ error: Error) {
        let message = error.localizedDescription
        validationMessage = message
        state = .error(message)
    }
}
