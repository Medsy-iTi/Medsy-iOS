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
	let latitude: Double?
	let longitude: Double?
	let dob: String?
	let phoneNumber: String
}

struct UpdateCustomerProfileRequestDTO: Encodable, Equatable {
    let homeAddress: String?
	let latitude: Double?
	let longitude: Double?
    let dob: String?

    init(input: UpdateCustomerProfileInput) {
        homeAddress = input.homeAddress
		latitude = input.homeLatitude
		longitude = input.homeLongitude
        dob = input.dateOfBirth.map(ProfileDateMapper.string)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(homeAddress, forKey: .homeAddress)
		try container.encodeIfPresent(latitude, forKey: .latitude)
		try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(dob, forKey: .dob)
    }

    private enum CodingKeys: String, CodingKey {
        case homeAddress
		case latitude
		case longitude
        case dob
    }
}
