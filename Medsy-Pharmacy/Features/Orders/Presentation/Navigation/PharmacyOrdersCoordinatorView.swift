//
//  PharmacyOrdersCoordinatorView.swift
//  Medsy
//
//  Created by Shahudaa on 22/07/2026.
//


import SwiftUI

struct PharmacyOrdersCoordinatorView: View {
	@Bindable var coordinator: PharmacyOrdersCoordinator

	var body: some View {
		NavigationStack(path: $coordinator.path) {
			coordinator.start()
		}
	}
}
