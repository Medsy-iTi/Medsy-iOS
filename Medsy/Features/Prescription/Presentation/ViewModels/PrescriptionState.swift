//
//  PrescriptionState.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import Foundation

enum PrescriptionImageSource: Equatable {
    case camera
    case gallery
}

enum PrescriptionFlowResult: Equatable {
    case added
    case uploadFailed
    case readingFailed
    case noMedicines
}

enum PrescriptionReadingStage: Int, CaseIterable, Equatable {
    case uploading
    case analysing
    case extracting
}

enum PrescriptionViewState: Equatable {
    case upload
    case preview
    case reading(PrescriptionReadingStage)
    case review
    case medicineSearch(UUID)
    case result(PrescriptionFlowResult)
}

enum PrescriptionEvent {
    case imageSelected(Data, PrescriptionImageSource)
    case continueFromPreview
    case changeImage
    case deleteImage
    case cancelReading
    case confirmMedicine(UUID)
    case chooseAlternative(UUID)
    case replaceMedicine(UUID, MedsyProduct)
    case cancelMedicineSearch
    case addToCart
    case retry
    case continueWithoutReading
    case addMedicineManually
    case viewCart
    case backHome
    case back
}

enum PrescriptionEffect {
    case exit
}

enum PrescriptionMockOutcome {
    case success
    case uploadFailed
    case readingFailed
    case noMedicines
}
