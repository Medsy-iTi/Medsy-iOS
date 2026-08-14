//
//  ConfirmationAlert.swift
//  Medsy
//
//  Created by Ehab Salah on 14/08/2026.
//

import SwiftUI

struct ConfirmationAlert<Item> {
    let title: String
    let message: (Item) -> String
    let confirmButtonTitle: String
    let cancelButtonTitle: String
    let confirmRole: ButtonRole?
    let onConfirm: (Item) -> Void

    init(
        title: String,
        message: @escaping (Item) -> String,
        confirmButtonTitle: String,
        cancelButtonTitle: String,
        confirmRole: ButtonRole? = nil,
        onConfirm: @escaping (Item) -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmButtonTitle = confirmButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.confirmRole = confirmRole
        self.onConfirm = onConfirm
    }
}

private struct ConfirmationAlertModifier<Item>: ViewModifier {
    @Binding var item: Item?
    let configuration: ConfirmationAlert<Item>

    func body(content: Content) -> some View {
        content.alert(
            configuration.title,
            isPresented: Binding(
                get: { item != nil },
                set: { if !$0 { item = nil } }
            ),
            presenting: item
        ) { item in
            Button(configuration.cancelButtonTitle, role: .cancel) {}
            Button(configuration.confirmButtonTitle, role: configuration.confirmRole) {
                configuration.onConfirm(item)
            }
        } message: { item in
            Text(configuration.message(item))
        }
    }
}

extension View {
    func confirmationAlert<Item>(
        item: Binding<Item?>,
        configuration: ConfirmationAlert<Item>
    ) -> some View {
        modifier(ConfirmationAlertModifier(item: item, configuration: configuration))
    }
}
