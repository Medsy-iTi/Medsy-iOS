//
//  Medsy_PharmacyTests.swift
//  Medsy-PharmacyTests
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import XCTest
@testable import Medsy_Pharmacy

final class Medsy_PharmacyTests: XCTestCase {
    func testRegistrationRequestUsesPharmacistRole() {
        let input = PharmacyRegistrationInput(
            firstName: "Ahmed",
            lastName: "Elkady",
            phoneNumber: "01012345678",
            email: "ahmed@example.com",
            password: "Password123",
            homeAddress: "Cairo",
            dateOfBirth: Date(timeIntervalSince1970: 0)
        )

        let request = PharmacyRegistrationRequestDTO(input: input)

        XCTAssertEqual(request.role, "PHARMACIST")
        XCTAssertEqual(request.homeAddress, "Cairo")
        XCTAssertEqual(request.dob, "1970-01-01")
    }

    func testAuthenticationSessionDecodesNullableProfileFields() throws {
        let data = Data(
            """
            {
              "success": true,
              "message": "Verified successfully",
              "data": {
                "accessToken": "access-token",
                "refreshToken": "refresh-token",
                "user": {
                  "id": 12,
                  "email": "pharmacist@example.com",
                  "firstName": "Ahmed",
                  "lastName": "Elkady",
                  "role": "PHARMACIST",
                  "homeAddress": null,
                  "dob": null
                }
              }
            }
            """.utf8
        )

        let response = try JSONDecoder().decode(
            PharmacyAuthenticationSessionResponseDTO.self,
            from: data
        )

        XCTAssertEqual(response.data?.user.role, "PHARMACIST")
        XCTAssertNil(response.data?.user.homeAddress)
        XCTAssertNil(response.data?.user.dob)
    }
}
