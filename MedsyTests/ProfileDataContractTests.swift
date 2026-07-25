//
//  ProfileDataContractTests.swift
//  MedsyTests
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import XCTest
@testable import Medsy

final class ProfileDataContractTests: XCTestCase {
    func testProfileResponseDecodesAndMapsEveryBackendField() throws {
        let json = """
        {
          "success": true,
          "message": "Customer profile returned",
          "data": {
            "id": 42,
            "email": "ahmed@example.com",
            "firstName": "Ahmed",
            "lastName": "Elkady",
            "homeAddress": "Cairo",
            "dob": "2000-05-18",
            "phoneNumber": "01012345678"
          }
        }
        """

        let response = try JSONDecoder().decode(
            CustomerProfileResponseDTO.self,
            from: Data(json.utf8)
        )
        let profile = try XCTUnwrap(response.data).mapToDomain()

        XCTAssertEqual(profile.id, 42)
        XCTAssertEqual(profile.email, "ahmed@example.com")
        XCTAssertEqual(profile.firstName, "Ahmed")
        XCTAssertEqual(profile.lastName, "Elkady")
        XCTAssertEqual(profile.homeAddress, "Cairo")
        XCTAssertEqual(profile.dateOfBirth.map(ProfileDateMapper.string), "2000-05-18")
        XCTAssertEqual(profile.phoneNumber, "01012345678")
    }

    func testUpdateRequestOmitsUnchangedValues() throws {
        let input = UpdateCustomerProfileInput(
            homeAddress: "Nasr City",
            homeLatitude: nil,
            homeLongitude: nil,
            dateOfBirth: nil
        )
        let request = UpdateCustomerProfileRequestDTO(input: input)
        let data = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])

        XCTAssertEqual(json["homeAddress"], "Nasr City")
        XCTAssertNil(json["dob"])
    }

    func testProfileEndpointsRequireAuthentication() {
        XCTAssertEqual(ProfileEndpoint.fetch.path, "customers/me")
        XCTAssertTrue(ProfileEndpoint.fetch.requiresAuthentication)
        XCTAssertTrue(ProfileEndpoint.update(emptyUpdateRequest()).requiresAuthentication)
    }

    private func emptyUpdateRequest() -> UpdateCustomerProfileRequestDTO {
        UpdateCustomerProfileRequestDTO(
            input: UpdateCustomerProfileInput(
                homeAddress: nil,
                homeLatitude: nil,
                homeLongitude: nil,
                dateOfBirth: nil
            )
        )
    }
}

private extension CustomerProfileDTO {
    func mapToDomain() -> CustomerProfile {
        CustomerProfileMapper.map(self)
    }
}
