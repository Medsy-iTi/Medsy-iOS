enum PrescriptionPresentationMapper {
    static func map(_ analysis: PrescriptionAnalysis) -> [PrescriptionMedicineDisplay] {
        analysis.medicines.map(map)
    }

    static func map(_ medicine: AnalyzedPrescriptionMedicine) -> PrescriptionMedicineDisplay {
        PrescriptionMedicineDisplay(
            id: medicine.id,
            rawText: medicine.rawText,
            extractedName: medicine.extractedName,
            extractedStrength: medicine.extractedStrength,
            extractedForm: medicine.extractedForm,
            matchStatus: medicine.matchStatus,
            confidence: medicine.confidence,
            candidates: medicine.candidates.map(map)
        )
    }

    static func map(_ candidate: PrescriptionCandidate) -> PrescriptionCandidateDisplay {
        PrescriptionCandidateDisplay(
            id: candidate.id,
            name: candidate.name,
            strength: candidate.strength,
            form: candidate.form,
            price: candidate.price,
            imageURL: candidate.imageURL
        )
    }

    static func selectedProduct(from candidate: PrescriptionCandidateDisplay) -> PrescriptionSelectedProductDisplay {
        PrescriptionSelectedProductDisplay(
            productID: Int64(candidate.id),
            name: candidate.name,
            details: candidate.details,
            unitPrice: candidate.price,
            imageURL: candidate.imageURL
        )
    }

    static func selectedProduct(from product: MedsyProduct) -> PrescriptionSelectedProductDisplay? {
        guard let productID = Int64(product.id) else { return nil }
        let details = product.dosageInfo.isEmpty ? product.categoryName : product.dosageInfo
        return PrescriptionSelectedProductDisplay(
            productID: productID,
            name: product.name,
            details: details,
            unitPrice: product.price,
            imageURL: product.imageUrl
        )
    }
}
