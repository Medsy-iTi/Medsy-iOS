import Foundation

typealias PrescriptionAnalysisResponseDTO = APIResponseDTO<PrescriptionAnalysisDataDTO>

struct PrescriptionAnalysisDataDTO: Decodable {
    let medicines: [PrescriptionMedicineDTO]
}

struct PrescriptionMedicineDTO: Decodable {
    let localItemId: String
    let rawText: String
    let extractedName: String
    let extractedStrength: String?
    let extractedForm: String?
    let matchStatus: String
    let confidence: Double
    let candidates: [PrescriptionCandidateDTO]
}

struct PrescriptionCandidateDTO: Decodable {
    let productId: Int
    let name: String
    let strength: String?
    let form: String?
    let price: Double
    let imageUrl: String?
}
