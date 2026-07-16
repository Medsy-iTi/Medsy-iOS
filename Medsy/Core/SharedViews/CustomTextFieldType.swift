//
//  CustomTextField.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI

enum TextFieldType: Equatable {
    case name
    case phone
    case email
    case password
    case confirmPassword

    var systemImage: String {
        switch self {
        case .name: "person"
        case .phone: "phone"
        case .email: "envelope"
        case .password, .confirmPassword: "lock"
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
        case .phone: .telephoneNumber
        case .email: .emailAddress
        case .password: .password
        case .confirmPassword: .newPassword
        }
    }

    var isSecure: Bool {
        self == .password || self == .confirmPassword
    }

    var usesWordCapitalization: Bool {
        self == .name
    }
}
