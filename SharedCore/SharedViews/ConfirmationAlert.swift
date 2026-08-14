//
//  ConfirmationAlert.swift
//  SharedCore
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
    let onCancel: (Item) -> Void
    let onConfirm: (Item) -> Void

    init(
        title: String,
        message: @escaping (Item) -> String,
        confirmButtonTitle: String,
        cancelButtonTitle: String,
        confirmRole: ButtonRole? = nil,
        onCancel: @escaping (Item) -> Void = { _ in },
        onConfirm: @escaping (Item) -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmButtonTitle = confirmButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.confirmRole = confirmRole
        self.onCancel = onCancel
        self.onConfirm = onConfirm
    }
}

extension ConfirmationAlert where Item == Void {
    init(
        title: String,
        message: String,
        confirmButtonTitle: String,
        cancelButtonTitle: String,
        confirmRole: ButtonRole? = nil,
        onCancel: @escaping () -> Void = {},
        onConfirm: @escaping () -> Void
    ) {
        self.init(
            title: title,
            message: { _ in message },
            confirmButtonTitle: confirmButtonTitle,
            cancelButtonTitle: cancelButtonTitle,
            confirmRole: confirmRole,
            onCancel: { _ in onCancel() },
            onConfirm: { _ in onConfirm() }
        )
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
            Button(configuration.cancelButtonTitle, role: .cancel) {
                configuration.onCancel(item)
            }
            Button(configuration.confirmButtonTitle, role: configuration.confirmRole) {
                configuration.onConfirm(item)
            }
        } message: { item in
            Text(configuration.message(item))
        }
    }
}

private struct BooleanConfirmationAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let configuration: ConfirmationAlert<Void>

    func body(content: Content) -> some View {
        content.alert(configuration.title, isPresented: $isPresented) {
            Button(configuration.cancelButtonTitle, role: .cancel) {
                configuration.onCancel(())
            }
            Button(configuration.confirmButtonTitle, role: configuration.confirmRole) {
                configuration.onConfirm(())
            }
        } message: {
            Text(configuration.message(()))
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

    func confirmationAlert(
        isPresented: Binding<Bool>,
        configuration: ConfirmationAlert<Void>
    ) -> some View {
        modifier(BooleanConfirmationAlertModifier(
            isPresented: isPresented,
            configuration: configuration
        ))
    }
}
