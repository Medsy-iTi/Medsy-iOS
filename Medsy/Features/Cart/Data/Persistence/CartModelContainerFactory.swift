//
//  CartModelContainerFactory.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftData

enum CartModelContainerFactory {
    static func make() -> ModelContainer {
        do {
            return try ModelContainer(
                for: CachedCartModel.self,
                CachedCartItemModel.self,
                CachedCartPrescriptionModel.self
            )
        } catch {
            fatalError("Unable to create the cart persistence container: \(error.localizedDescription)")
        }
    }
}
