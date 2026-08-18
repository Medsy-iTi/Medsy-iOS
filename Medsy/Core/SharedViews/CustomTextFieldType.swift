//
//  CustomTextField.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI

enum TextFieldType: Equatable {
    case name
    case address
    case phone
    case email
    case password
    case newPassword
    case confirmPassword

    var systemImage: String {
        switch self {
        case .name: "person"
        case .address: "house"
        case .phone: "phone"
        case .email: "envelope"
        case .password, .newPassword, .confirmPassword: "lock"
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .phone: .phonePad
        case .email: .emailAddress
        default: .default
        }
    }

    var contentType: UITextContentType? {
        switch self {
        case .name: .name
        case .address: .fullStreetAddress
        case .phone: .telephoneNumber
        case .email: .emailAddress
        case .password: .password
        case .newPassword, .confirmPassword: .newPassword
        }
    }

    var isSecure: Bool {
        self == .password || self == .newPassword || self == .confirmPassword
    }

    var usesWordCapitalization: Bool {
        self == .name || self == .address
    }
}
