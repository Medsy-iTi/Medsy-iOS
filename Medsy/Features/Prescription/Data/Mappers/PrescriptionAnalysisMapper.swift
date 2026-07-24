enum PrescriptionAnalysisMapper {
    static func map(_ dto: PrescriptionAnalysisDataDTO) -> PrescriptionAnalysis {
        PrescriptionAnalysis(medicines: dto.medicines.map(map))
    }

    private static func map(_ dto: PrescriptionMedicineDTO) -> AnalyzedPrescriptionMedicine {
        AnalyzedPrescriptionMedicine(
            id: dto.localItemId,
            rawText: dto.rawText,
            extractedName: dto.extractedName,
            extractedStrength: dto.extractedStrength,
            extractedForm: dto.extractedForm,
            matchStatus: dto.matchStatus,
            confidence: dto.confidence,
            candidates: dto.candidates.map(map)
        )
    }

    private static func map(_ dto: PrescriptionCandidateDTO) -> PrescriptionCandidate {
        PrescriptionCandidate(
            id: dto.productId,
            name: dto.name,
            strength: dto.strength,
            form: dto.form,
            price: dto.price,
            imageURL: dto.imageUrl
        )
    }
}
