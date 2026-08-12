//
//  AuthSessionDTO.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

struct AuthSessionResponseDTO: Decodable, Equatable {
    let success: Bool
    let message: String
    let data: AuthSessionDTO?
}

struct AuthSessionDTO: Decodable, Equatable {
    let accessToken: String
    let refreshToken: String
    let user: AuthenticatedUserDTO

    func toDomain() -> AuthenticatedSession {
        AuthenticatedSession(accessToken: accessToken, refreshToken: refreshToken, user: user.toDomain())
    }
}

struct AuthenticatedUserDTO: Decodable, Equatable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let role: String
    let homeAddress: String
    let dob: String
    let latitude: Double?
    let longitude: Double?

    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName
        case lastName
        case role
        case homeAddress
        case deliveryLatitude
        case deliveryLongitude
        case dob
        case latitude
        case longitude
        case backendLatitude = "Lattitude"
        case backendLongitude = "Longitude"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        role = try container.decode(String.self, forKey: .role)
        homeAddress = try container.decodeIfPresent(String.self, forKey: .homeAddress) ?? ""
        dob = try container.decodeIfPresent(String.self, forKey: .dob) ?? ""
        latitude = try container.decodeIfPresent(Double.self, forKey: .deliveryLatitude)
            ?? container.decodeIfPresent(Double.self, forKey: .latitude)
            ?? container.decodeIfPresent(Double.self, forKey: .backendLatitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .deliveryLongitude)
            ?? container.decodeIfPresent(Double.self, forKey: .longitude)
            ?? container.decodeIfPresent(Double.self, forKey: .backendLongitude)
    }

    func toDomain() -> AuthenticatedUser {
        AuthenticatedUser(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: role,
            homeAddress: homeAddress,
            dateOfBirth: dob,
            homeLatitude: latitude,
            homeLongitude: longitude
        )
    }
}
