//
//  PharmacistAvatarView.swift
//  Medsy-Pharmacy
//
//  Avatar view for pharmacist with initials fallback
//

import SwiftUI

struct PharmacistAvatarView: View {
    let pharmacist: Pharmacist
    var diameter: CGFloat = 52

    private var initials: String {
        let first = pharmacist.firstName.first.map(String.init) ?? ""
        let last = pharmacist.lastName.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }

    var body: some View {
        ZStack {
            if let url = pharmacist.avatarURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: diameter, height: diameter)
        .clipShape(Circle())
        .overlay(Circle().stroke(PharmacyColor.border, lineWidth: 1))
    }

    private var initialsView: some View {
        ZStack {
            PharmacyColor.primarySoft
            Text(initials)
                .font(PharmacyColor.sans(diameter * 0.34, .semibold))
                .foregroundStyle(PharmacyColor.primary)
        }
    }
}

#Preview {
    PharmacistAvatarView(
        pharmacist: Pharmacist(id: "1", firstName: "أحمد", lastName: "محمد", email: "", role: .admin, isVerified: true, yearsOfExperience: 7, avatarURLString: nil)
    )
    .padding()
}
