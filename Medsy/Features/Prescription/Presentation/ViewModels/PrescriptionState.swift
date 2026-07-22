import Foundation

enum PrescriptionImageSource: Equatable {
    case camera
    case gallery
}

enum PrescriptionFlowResult: Equatable {
    case added
    case analysisFailed(String)
    case noMedicines
}

enum PrescriptionMedicineSearchContext: Equatable {
    case replace(medicineID: String, query: String)
    case add(query: String)

    var query: String {
        switch self {
        case let .replace(_, query), let .add(query):
            return query
        }
    }
}

enum PrescriptionViewState: Equatable {
    case upload
    case preview
    case reading
    case review
    case medicineSearch(PrescriptionMedicineSearchContext)
    case result(PrescriptionFlowResult)
}

enum PrescriptionEvent {
    case imageSelected(Data, PrescriptionImageSource)
    case continueFromPreview
    case changeImage
    case deleteImage
    case cancelReading
    case toggleCandidates(String)
    case selectCandidate(medicineID: String, candidateID: Int)
    case searchCatalog(String)
    case selectSearchedMedicine(MedsyProduct)
    case cancelMedicineSearch
    case increaseQuantity(String)
    case decreaseQuantity(String)
    case deleteMedicine(String)
    case addToCart
    case addToCartSucceeded
    case addToCartFailed(String)
    case retry
    case addMedicineManually
    case backHome
    case back
}

enum PrescriptionEffect {
    case exit
}
