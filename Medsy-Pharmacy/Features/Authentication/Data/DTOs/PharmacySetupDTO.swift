struct PharmacyProfileEnvelopeDTO: Decodable {
    let success: Bool
    let message: String
    let data: PharmacyProfileDTO?
}

struct PharmacyProfileDTO: Decodable {
    let pharmacyId: Int?
    let pharmacyAdmin: Bool?

    func toDomain() -> PharmacyMembership {
        PharmacyMembership(
            pharmacyID: pharmacyId,
            isAdmin: pharmacyAdmin ?? false
        )
    }
}

struct CreatePharmacyRequestDTO: Encodable {
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String
    let phoneNumber: String

    init(input: CreatePharmacyInput) {
        name = input.name
        latitude = input.location.latitude
        longitude = input.location.longitude
        address = input.location.address
        phoneNumber = input.phoneNumber
    }
}

struct PharmacyResponseEnvelopeDTO: Decodable {
    let success: Bool
    let message: String
    let data: PharmacyResponseDTO?
}

struct PharmacyResponseDTO: Decodable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let phoneNumber: String?

    func toDomain() -> CreatedPharmacy {
        CreatedPharmacy(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            address: address,
            phoneNumber: phoneNumber
        )
    }
}
