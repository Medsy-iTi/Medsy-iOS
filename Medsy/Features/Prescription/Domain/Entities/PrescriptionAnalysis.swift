import Foundation

struct PrescriptionAnalysis: Equatable {
    let medicines: [AnalyzedPrescriptionMedicine]
}

struct AnalyzedPrescriptionMedicine: Identifiable, Equatable {
    let id: String
    let rawText: String
    let extractedName: String
    let extractedStrength: String?
    let extractedForm: String?
    let matchStatus: String
    let confidence: Double
    let candidates: [PrescriptionCandidate]
}

struct PrescriptionCandidate: Identifiable, Equatable {
    let id: Int
    let name: String
    let strength: String?
    let form: String?
    let price: Double
    let imageURL: String?
}
