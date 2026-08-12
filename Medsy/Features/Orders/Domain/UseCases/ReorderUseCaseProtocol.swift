//
//  ReorderUseCase.swift
//  Medsy
//
//  Created by Shahudaa on 25/07/2026.
//

import Foundation


protocol ReorderUseCaseProtocol: AnyObject {
    func execute(items: [ReorderItem]) async -> ReorderResult
}



final class ReorderUseCase: ReorderUseCaseProtocol {
    private let addCartItemUseCase: AddCartItemUseCaseProtocol

    init(addCartItemUseCase: AddCartItemUseCaseProtocol) {
        self.addCartItemUseCase = addCartItemUseCase
    }
    func execute(items: [ReorderItem]) async -> ReorderResult {
        guard !items.isEmpty else { return .failure }

        var addedCount = 0

        for item in items {
            do {
                _ = try await addCartItemUseCase.execute(
                    input: AddCartItemInput(
                        productID: Int64(item.productId),
                        quantity: item.quantity
                    )
                )
                addedCount += 1
            } catch {
                
            }
        }

        switch addedCount {
        case items.count:
            return .success
        case 0:
            return .failure
        default:
            return .partial(added: addedCount, total: items.count)
        }
    }
}
