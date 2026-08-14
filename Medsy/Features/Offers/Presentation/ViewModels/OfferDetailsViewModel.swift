import Foundation
import Observation

@MainActor
@Observable
final class OfferDetailsViewModel {
    var offerDetail: OfferDetailPresentationModel
    private(set) var isConfirming = false
    private(set) var confirmErrorMessage: String?
    private(set) var isConfirmed = false

    let requestId: Int?
    private let confirmOfferUseCase: ConfirmOfferUseCaseProtocol?
    private let statusStore: UserDefaultsStatusStoreProtocol?

    init(
        offer: OfferPresentationModel? = nil,
        offerResult: OfferResult? = nil,
        requestId: Int? = nil,
        confirmOfferUseCase: ConfirmOfferUseCaseProtocol? = nil,
        statusStore: UserDefaultsStatusStoreProtocol? = nil
    ) {
        self.requestId = requestId
        self.confirmOfferUseCase = confirmOfferUseCase ?? DIContainer.shared.resolve(ConfirmOfferUseCaseProtocol.self)
        self.statusStore = statusStore ?? DIContainer.shared.resolve(UserDefaultsStatusStoreProtocol.self)

        if let offerResult {
            let items = offerResult.items.map { item in
                OfferMedicineItem(
                    id: "\(item.requestItemId)",
                    requestItemId: item.requestItemId,
                    productId: item.productId,
                    name: item.productName.isEmpty ? "offers.details.unavailableItem".localized : item.productName,
                    dosage: "",
                    price: item.unitPrice,
                    isAvailable: item.isAvailable,
                    isAlternative: item.isAlternative,
                    imageName: item.isAlternative ? "pills.fill" : "pill.fill",
                    imageUrl: item.imageUrl
                )
            }
            let allAvailable = !items.isEmpty && items.allSatisfy(\.isAvailable)
            let comment = allAvailable ? "offers.details.defaultComment".localized : "offers.details.partialComment".localized
            self.offerDetail = OfferDetailPresentationModel(
                id: "\(requestId ?? 1)",
                pharmacyName: "offers.details.title".localized,
                managerName: "",
                medicines: items,
                pharmacistComment: comment,
                totalPrice: offerResult.totalPrice,
                prescriptionUrl: offerResult.prescriptionUrl,
                paymentMethod: offerResult.paymentMethod
            )
        } else {
            self.offerDetail = OfferDetailPresentationModel(
                id: offer?.id ?? "1",
                pharmacyName: offer?.pharmacyName ?? "offers.list.pharmacy.nahda".localized,
                managerName: "",
                medicines: [],
                pharmacistComment: "offers.details.defaultComment".localized,
                totalPrice: Double(offer?.price ?? 0),
                prescriptionUrl: nil
            )
        }
    }

    var hasSelectedMedicines: Bool {
        offerDetail.medicines.contains(where: { $0.isAvailable && $0.isSelected })
    }

    func toggleItemSelection(id: String) {
        guard let index = offerDetail.medicines.firstIndex(where: { $0.id == id }) else { return }
        guard offerDetail.medicines[index].isAvailable else { return }

        var updatedMedicines = offerDetail.medicines
        updatedMedicines[index].isSelected.toggle()

        let newTotal = updatedMedicines
            .filter { $0.isAvailable && $0.isSelected }
            .reduce(0.0) { $0 + $1.price }

        offerDetail = OfferDetailPresentationModel(
            id: offerDetail.id,
            pharmacyName: offerDetail.pharmacyName,
            managerName: offerDetail.managerName,
            medicines: updatedMedicines,
            pharmacistComment: offerDetail.pharmacistComment,
            totalPrice: newTotal,
            prescriptionUrl: offerDetail.prescriptionUrl
        )
    }

    func selectOffer() async -> SelectPharmacyResponseDTO? {
        guard !isConfirming && !isConfirmed else { return nil }
        guard let requestId else {
            isConfirmed = true
            return nil
        }
        guard let confirmOfferUseCase else {
            statusStore?.clearPendingRequestId()
            isConfirmed = true
            return nil
        }

        isConfirming = true
        confirmErrorMessage = nil
        defer { isConfirming = false }

        let selectedItems = offerDetail.medicines
            .filter { $0.isAvailable && $0.isSelected }
            .map { ConfirmSelectedItem(requestItemId: $0.requestItemId, productId: $0.productId) }

        do {
            let result = try await confirmOfferUseCase.selectPharmacy(requestId: requestId, selectedItems: selectedItems)
            if let data = try? JSONEncoder().encode(result) {
                UserDefaults.standard.set(data, forKey: "request.selectResult.\(requestId)")
            }
            UserDefaults.standard.set(true, forKey: "request.isSelected.\(requestId)")
            UserDefaults.standard.set(false, forKey: "request.isConfirmed.\(requestId)")
            isConfirmed = true
            return result
        } catch {
            confirmErrorMessage = error.localizedDescription
            return nil
        }
    }
}

