//
//  UpdatePharmacyProfileRequestDTO.swift
//  Medsy-Pharmacy
//

struct UpdatePharmacyProfileRequestDTO: Encodable {
    let email: String?
    let firstName: String?
    let lastName: String?
    let homeAddress: String?
    let dob: String?
}
