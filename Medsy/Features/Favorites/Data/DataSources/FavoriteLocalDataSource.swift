//
//  FavoriteLocalDataSource.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import Foundation
import SwiftData

struct FavoriteMedicineRecord: Equatable, Sendable {
    let productID: Int
    let name: String
    let arabicName: String
    let scientificName: String
    let price: Double
    let imageURL: String?
    let categoryID: Int
    let categoryName: String
    let company: String
    let route: String
    let createdAt: Date
}

protocol FavoriteLocalDataSourceProtocol {
    func fetchAll(accountID: String) async throws -> [FavoriteMedicineRecord]
    func contains(productID: Int, accountID: String) async throws -> Bool
    func upsert(_ record: FavoriteMedicineRecord, accountID: String) async throws
    func remove(productID: Int, accountID: String) async throws
}

actor FavoriteLocalDataSource: FavoriteLocalDataSourceProtocol {
    private let modelContainer: ModelContainer

    init(
        swiftDataFactory: SwiftDataFactory = .shared,
        configuration: SwiftDataStoreConfiguration = .persistent(name: "MedsyFavorites")
    ) throws {
        modelContainer = try swiftDataFactory.makeContainer(
            for: Schema([FavoriteMedicineModel.self]),
            configuration: configuration
        )
    }

    func fetchAll(accountID: String) throws -> [FavoriteMedicineRecord] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<FavoriteMedicineModel>(
            predicate: #Predicate { $0.accountIdentifier == accountID },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map(Self.record)
    }

    func contains(productID: Int, accountID: String) throws -> Bool {
        let storageKey = FavoriteMedicineModel.storageKey(accountIdentifier: accountID, productID: productID)
        let context = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<FavoriteMedicineModel>(
            predicate: #Predicate { $0.storageKey == storageKey }
        )
        descriptor.fetchLimit = 1
        return try !context.fetch(descriptor).isEmpty
    }

    func upsert(_ record: FavoriteMedicineRecord, accountID: String) throws {
        let storageKey = FavoriteMedicineModel.storageKey(accountIdentifier: accountID, productID: record.productID)
        let context = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<FavoriteMedicineModel>(
            predicate: #Predicate { $0.storageKey == storageKey }
        )
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            existing.update(from: record)
        } else {
            context.insert(FavoriteMedicineModel(accountIdentifier: accountID, record: record))
        }
        try context.save()
    }

    func remove(productID: Int, accountID: String) throws {
        let storageKey = FavoriteMedicineModel.storageKey(accountIdentifier: accountID, productID: productID)
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<FavoriteMedicineModel>(
            predicate: #Predicate { $0.storageKey == storageKey }
        )
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    private static func record(_ model: FavoriteMedicineModel) -> FavoriteMedicineRecord {
        FavoriteMedicineRecord(
            productID: model.productID,
            name: model.name,
            arabicName: model.arabicName,
            scientificName: model.scientificName,
            price: model.price,
            imageURL: model.imageURL,
            categoryID: model.categoryID,
            categoryName: model.categoryName,
            company: model.company,
            route: model.route,
            createdAt: model.createdAt
        )
    }
}
