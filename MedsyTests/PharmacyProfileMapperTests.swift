//
//  PharmacyProfileMapperTests.swift
//  MedsyTests
//
//  Created by Antoneos Philip on 21/07/2026.
//

import XCTest
@testable import Medsy

final class PharmacyProfileMapperTests: XCTestCase {
    func testPharmacyResponseDecodesAndMapsToDomain() throws {
        let json = """
        {
            "id": 1,
            "name": "El-Ezbawy Pharmacy",
            "latitude": 30.0444,
            "longitude": 31.2357,
            "address": "Tahrir Square, Cairo",
            "phoneNumber": "01012345678"
        }
        """

        let dto = try JSONDecoder().decode(PharmacyDataDTO.self, from: Data(json.utf8))
        let pharmacy = PharmacyMapper.map(dto)

        XCTAssertEqual(pharmacy.id, 1)
        XCTAssertEqual(pharmacy.name, "El-Ezbawy Pharmacy")
        XCTAssertEqual(pharmacy.latitude, 30.0444)
        XCTAssertEqual(pharmacy.longitude, 31.2357)
        XCTAssertEqual(pharmacy.address, "Tahrir Square, Cairo")
        XCTAssertEqual(pharmacy.phoneNumber, "01012345678")
    }

    func testPharmacyEndpointPathAndAuth() {
        let endpoint = PharmacyEndpoint.fetchProfile(id: 42)
        XCTAssertEqual(endpoint.path, "pharmacies/42")
        XCTAssertTrue(endpoint.requiresAuthentication)
    }
}
