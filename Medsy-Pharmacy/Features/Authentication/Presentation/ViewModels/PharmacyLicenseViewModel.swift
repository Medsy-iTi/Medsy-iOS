//
//  PharmacyLicenseViewModel.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation
import Observation

enum PharmacyLicenseState: Equatable {
    case idle
    case selected
    case loading
    case success
    case error(String)
}

enum PharmacyLicenseEvent {
    case documentSelected(Result<[URL], Error>)
    case documentRemoved
    case documentSubmitted
    case errorDismissed
}

@MainActor
@Observable
final class PharmacyLicenseViewModel {
    var document: PharmacyLicenseDocument?
    private(set) var state: PharmacyLicenseState = .idle
    private(set) var validationMessage: String?
    private let submitAction: (PharmacyLicenseDocument) async throws -> Void

    init(submitAction: @escaping (PharmacyLicenseDocument) async throws -> Void) {
        self.submitAction = submitAction
    }

    var isLoading: Bool {
        state == .loading
    }

    func handle(_ event: PharmacyLicenseEvent) async -> Bool {
        switch event {
        case let .documentSelected(result):
            return selectDocument(result)
        case .documentRemoved:
            document = nil
            state = .idle
            validationMessage = nil
            return true
        case .documentSubmitted:
            return await submitDocument()
        case .errorDismissed:
            state = document == nil ? .idle : .selected
            validationMessage = nil
            return true
        }
    }

    private func selectDocument(_ result: Result<[URL], Error>) -> Bool {
        do {
            guard let url = try result.get().first else { return false }
            document = try PharmacyLicenseDocument(url: url)
            state = .selected
            validationMessage = nil
            return true
        } catch let error as PharmacyLicenseDocumentError {
            document = nil
            state = .error(error.localizedMessage)
            validationMessage = error.localizedMessage
            return false
        } catch {
            let message = "pharmacy.auth.license.error.read".localized
            document = nil
            state = .error(message)
            validationMessage = message
            return false
        }
    }

    private func submitDocument() async -> Bool {
        guard !isLoading else { return false }
        guard let document else {
            validationMessage = "pharmacy.auth.license.error.required".localized
            return false
        }

        state = .loading

        do {
            try await submitAction(document)
            state = .success
            return true
        } catch is CancellationError {
            state = .selected
            return false
        } catch {
            let message = error.localizedDescription
            state = .error(message)
            validationMessage = message
            return false
        }
    }
}
