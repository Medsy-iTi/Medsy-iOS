//
//  UpdatePharmacyRequestDTO.swift
//  Medsy-Pharmacy
//

import Foundation

struct UpdatePharmacyRequestDTO: Encodable {
    let name: String?
    let address: String?
    let phoneNumber: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
    }

    private enum CodingKeys: String, CodingKey {
        case name, address, phoneNumber
    }
}
