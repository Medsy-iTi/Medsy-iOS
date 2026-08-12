//
//  OrdersTabRootView.swift
//  Medsy
//
//  Created by Shahudaa on 22/07/2026.
//


import SwiftUI

struct OrdersTabRootView: View {
	@State private var coordinator: PharmacyOrdersCoordinator

	init(factory: PharmacyOrdersFactory) {
		_coordinator = State(initialValue: factory.makeCoordinator())
	}

	var body: some View {
		PharmacyOrdersCoordinatorView(coordinator: coordinator)
	}
}
