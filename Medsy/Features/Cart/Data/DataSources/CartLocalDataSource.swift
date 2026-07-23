//
//  CartLocalDataSource.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation
import SwiftData

protocol CartLocalDataSourceProtocol {
    func fetchCart() async throws -> CachedCartDTO?
    func saveCart(_ cart: CartDTO, dosageByProductID: [Int64: String]) async throws
    func clearCart() async throws
    func fetchPrescriptions() async throws -> [CachedCartPrescriptionDTO]
    func addPrescription(_ prescription: CachedCartPrescriptionDTO) async throws
    func replacePrescription(id: UUID, with prescription: CachedCartPrescriptionDTO) async throws
    func removePrescription(id: UUID) async throws
    func clearPrescriptions() async throws
}

actor CartLocalDataSource: CartLocalDataSourceProtocol {
    private let modelContainer: ModelContainer
    private let accountScopeProvider: CartAccountScopeProviderProtocol

    init(
        modelContainer: ModelContainer,
        accountScopeProvider: CartAccountScopeProviderProtocol
    ) {
        self.modelContainer = modelContainer
        self.accountScopeProvider = accountScopeProvider
    }

    func fetchCart() throws -> CachedCartDTO? {
        let accountIdentifier = try accountScopeProvider.currentIdentifier()
        let context = ModelContext(modelContainer)
        let metadataDescriptor = FetchDescriptor<CachedCartModel>(
            predicate: #Predicate { $0.accountIdentifier == accountIdentifier }
        )
        guard let metadata = try context.fetch(metadataDescriptor).first,
              let cartID = metadata.cartID else {
            return nil
        }

        let itemDescriptor = FetchDescriptor<CachedCartItemModel>(
            predicate: #Predicate { $0.accountIdentifier == accountIdentifier },
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        let items = try context.fetch(itemDescriptor).map {
            CachedCartItemDTO(
                id: $0.cartItemID,
                productId: $0.productID,
                productName: $0.productName,
                dosageInfo: $0.dosageInfo,
                imageUrl: $0.imageURL,
                unitPrice: $0.unitPrice,
                quantity: $0.quantity,
                subtotal: $0.subtotal
            )
        }
        return CachedCartDTO(id: cartID, items: items, totalPrice: metadata.totalPrice)
    }

    func saveCart(_ cart: CartDTO, dosageByProductID: [Int64: String]) throws {
        let accountIdentifier = try accountScopeProvider.currentIdentifier()
        let context = ModelContext(modelContainer)
        let metadataDescriptor = FetchDescriptor<CachedCartModel>(
            predicate: #Predicate { $0.accountIdentifier == accountIdentifier }
        )
        if let metadata = try context.fetch(metadataDescriptor).first {
            metadata.cartID = cart.id
            metadata.totalPrice = cart.totalPrice
        } else {
            context.insert(
                CachedCartModel(
                    accountIdentifier: accountIdentifier,
                    cartID: cart.id,
                    totalPrice: cart.totalPrice
                )
            )
        }

        let itemDescriptor = FetchDescriptor<CachedCartItemModel>(
            predicate: #Predicate { $0.accountIdentifier == accountIdentifier }
        )
        let existingItems = try context.fetch(itemDescriptor)
        let existingDosage = existingItems.reduce(into: [Int64: String]()) {
            $0[$1.productID] = $1.dosageInfo
        }
        existingItems.forEach(context.delete)

        for (index, item) in cart.items.enumerated() {
            context.insert(
                CachedCartItemModel(
                    cacheIdentifier: "\(accountIdentifier)|\(item.id)",
                    accountIdentifier: accountIdentifier,
                    cartItemID: item.id,
                    productID: item.productId,
                    productName: item.productName,
                    dosageInfo: dosageByProductID[item.productId] ?? existingDosage[item.productId] ?? "",
                    imageURL: item.imageUrl,
                    unitPrice: item.unitPrice,
                    quantity: item.quantity,
                    subtotal: item.subtotal,
                    sortOrder: index
                )
            )
        }
        try context.save()
    }

    func clearCart() throws {
        let accountIdentifier = try accountScopeProvider.currentIdentifier()
        let context = ModelContext(modelContainer)
        let itemDescriptor = FetchDescriptor<CachedCartItemModel>(
            predicate: #Predicate { $0.accountIdentifier == accountIdentifier }
        )
        try context.fetch(itemDescriptor).forEach(context.delete)

        let metadataDescriptor = FetchDescriptor<CachedCartModel>(
            predicate: #Predicate { $0.accountIdentifier == accountIdentifier }
        )
        if let metadata = try context.fetch(metadataDescriptor).first {
            metadata.totalPrice = 0
        }
        try context.save()
    }

    func fetchPrescriptions() throws -> [CachedCartPrescriptionDTO] {
        let accountIdentifier = try accountScopeProvider.currentIdentifier()
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<CachedCartPrescriptionModel>(
            predicate: #Predicate { $0.accountIdentifier == accountIdentifier },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        let storedPrescriptions = try context.fetch(descriptor)
        guard let newestPrescription = storedPrescriptions.last else { return [] }

        if storedPrescriptions.count > 1 {
            storedPrescriptions.dropLast().forEach(context.delete)
            try context.save()
        }

        guard let source = CartPrescriptionSource(rawValue: newestPrescription.source) else {
            throw CartPersistenceError.invalidPrescriptionSource
        }
        return [
            CachedCartPrescriptionDTO(
                id: newestPrescription.prescriptionID,
                data: newestPrescription.data,
                source: source,
                createdAt: newestPrescription.createdAt
            )
        ]
    }

    func addPrescription(_ prescription: CachedCartPrescriptionDTO) throws {
        let accountIdentifier = try accountScopeProvider.currentIdentifier()
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<CachedCartPrescriptionModel>(
            predicate: #Predicate { $0.accountIdentifier == accountIdentifier }
        )
        try context.fetch(descriptor).forEach(context.delete)
        context.insert(model(from: prescription, accountIdentifier: accountIdentifier))
        try context.save()
    }

    func replacePrescription(id _: UUID, with prescription: CachedCartPrescriptionDTO) throws {
        let accountIdentifier = try accountScopeProvider.currentIdentifier()
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<CachedCartPrescriptionModel>(
            predicate: #Predicate { $0.accountIdentifier == accountIdentifier }
        )
        try context.fetch(descriptor).forEach(context.delete)
        context.insert(model(from: prescription, accountIdentifier: accountIdentifier))
        try context.save()
    }

    func removePrescription(id: UUID) throws {
        let accountIdentifier = try accountScopeProvider.currentIdentifier()
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<CachedCartPrescriptionModel>(
            predicate: #Predicate {
                $0.accountIdentifier == accountIdentifier && $0.prescriptionID == id
            }
        )
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    func clearPrescriptions() throws {
        let accountIdentifier = try accountScopeProvider.currentIdentifier()
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<CachedCartPrescriptionModel>(
            predicate: #Predicate { $0.accountIdentifier == accountIdentifier }
        )
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    private func model(
        from prescription: CachedCartPrescriptionDTO,
        accountIdentifier: String
    ) -> CachedCartPrescriptionModel {
        CachedCartPrescriptionModel(
            cacheIdentifier: "\(accountIdentifier)|\(prescription.id.uuidString)",
            accountIdentifier: accountIdentifier,
            prescriptionID: prescription.id,
            data: prescription.data,
            source: prescription.source.rawValue,
            createdAt: prescription.createdAt
        )
    }
}
