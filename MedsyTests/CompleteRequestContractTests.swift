//
//  CompleteRequestContractTests.swift
//  MedsyTests
//
//  Created by Ehab Salah on 24/07/2026.
//

import XCTest
@testable import Medsy

final class CompleteRequestContractTests: XCTestCase {
    func testSubmitEndpointBuildsAuthenticatedPostRequest() throws {
        let input = SubmitCompleteRequestInput(
            deliveryLatitude: 30.0444,
            deliveryLongitude: 31.2357,
            deliveryAddress: "Tahrir Square, Cairo"
        )
        let builder = NetworkRequestBuilder(
            languageManager: .shared,
            defaultBaseURL: "https://example.com/api/v1/"
        )

        let request = try builder.makeRequest(
            for: CompleteRequestEndpoint.submit(
                CompleteRequestDTO(input: input)
            ),
            accessToken: "access-token"
        )

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.path, "/api/v1/requests")
        XCTAssertEqual(
            request.value(forHTTPHeaderField: "Authorization"),
            "Bearer access-token"
        )
        XCTAssertFalse(
            CompleteRequestEndpoint
                .submit(CompleteRequestDTO(input: input))
                .allowsResponseLogging
        )

        let body = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: Any]
        )
        XCTAssertEqual(json["deliveryLatitude"] as? Double, 30.0444)
        XCTAssertEqual(json["deliveryLongitude"] as? Double, 31.2357)
        XCTAssertEqual(json["deliveryAddress"] as? String, "Tahrir Square, Cairo")
        XCTAssertEqual(json.count, 3)
    }

    func testSuccessResponseDecodesAndMapsRequest() throws {
        let response = try JSONDecoder().decode(
            SubmitCompleteRequestResponseDTO.self,
            from: Data(successJSON.utf8)
        )
        let dto = try XCTUnwrap(response.data)
        let request = try CompleteRequestMapper.map(dto)

        XCTAssertTrue(response.success)
        XCTAssertEqual(request.id, 50)
        XCTAssertEqual(request.customerID, 12)
        XCTAssertEqual(request.deliveryLatitude, 30.0444)
        XCTAssertEqual(request.deliveryLongitude, 31.2357)
        XCTAssertEqual(request.deliveryAddress, "Tahrir Square, Cairo")
        XCTAssertEqual(request.status, "PENDING")
        XCTAssertEqual(request.items, [
            SubmittedMedicineRequestItem(id: 70, productID: 20, quantity: 2)
        ])
    }

    func testFailureEnvelopePreservesBackendMessage() {
        let message = "A request cannot be created from an empty cart"
        let data = Data(
            "{\"success\":false,\"message\":\"\(message)\",\"data\":null}".utf8
        )

        guard case let .validationError(mappedMessage)? =
            NetworkErrorHandler.apiEnvelopeError(from: data) else {
            return XCTFail("Expected backend validation error")
        }
        XCTAssertEqual(mappedMessage, message)
    }

    private var successJSON: String {
        """
        {
          "success": true,
          "message": "Request created",
          "data": {
            "id": 50,
            "customerId": 12,
            "deliveryLatitude": 30.0444,
            "deliveryLongitude": 31.2357,
            "deliveryAddress": "Tahrir Square, Cairo",
            "status": "PENDING",
            "createdAt": "2026-07-24T08:42:58.765Z",
            "items": [{
              "id": 70,
              "productId": 20,
              "quantity": 2
            }]
          }
        }
        """
    }
}
