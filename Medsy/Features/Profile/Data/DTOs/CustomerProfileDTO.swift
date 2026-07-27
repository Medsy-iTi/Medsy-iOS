//
//  CustomerProfileDTO.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

typealias CustomerProfileResponseDTO = APIResponseDTO<CustomerProfileDTO>

struct CustomerProfileDTO: Decodable, Equatable {
	let id: Int
	let email: String
	let firstName: String
	let lastName: String
	let homeAddress: String?
	let deliveryLatitude: Double?
	let deliveryLongitude: Double?
	let dob: String?
	let phoneNumber: String

    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName
        case lastName
        case homeAddress
        case deliveryLatitude
        case deliveryLongitude
        case latitude
        case longitude
        case backendLatitude = "Lattitude"
        case backendLongitude = "Longitude"
        case dob
        case phoneNumber
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        homeAddress = try container.decodeIfPresent(String.self, forKey: .homeAddress)
        deliveryLatitude = try container.decodeIfPresent(Double.self, forKey: .deliveryLatitude)
            ?? container.decodeIfPresent(Double.self, forKey: .latitude)
            ?? container.decodeIfPresent(Double.self, forKey: .backendLatitude)
        deliveryLongitude = try container.decodeIfPresent(Double.self, forKey: .deliveryLongitude)
            ?? container.decodeIfPresent(Double.self, forKey: .longitude)
            ?? container.decodeIfPresent(Double.self, forKey: .backendLongitude)
        dob = try container.decodeIfPresent(String.self, forKey: .dob)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber) ?? ""
    }
}

struct UpdateCustomerProfileRequestDTO: Encodable, Equatable {
    let firstName: String
    let lastName: String
    let homeAddress: String?
	let deliveryLatitude: Double?
	let deliveryLongitude: Double?
    let dob: String?

    init(input: UpdateCustomerProfileInput) {
        firstName = input.firstName
        lastName = input.lastName
        homeAddress = input.homeAddress
		deliveryLatitude = input.homeLatitude
		deliveryLongitude = input.homeLongitude
        dob = input.dateOfBirth.map(ProfileDateMapper.string)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encodeIfPresent(homeAddress, forKey: .homeAddress)
		try container.encodeIfPresent(deliveryLatitude, forKey: .deliveryLatitude)
		try container.encodeIfPresent(deliveryLongitude, forKey: .deliveryLongitude)
        try container.encodeIfPresent(dob, forKey: .dob)
    }

    private enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case homeAddress
		case deliveryLatitude
		case deliveryLongitude
        case dob
    }
}
