//
//  MedicineAnalyzeContractTests.swift
//  MedsyTests
//
//  Created by Ehab Salah on 23/07/2026.
//

import XCTest
@testable import Medsy

final class MedicineAnalyzeContractTests: XCTestCase {
    func testAnalyzeEndpointBuildsAuthenticatedMultipartRequest() throws {
        let imageData = Data("jpeg-bytes".utf8)
        let builder = NetworkRequestBuilder(
            languageManager: .shared,
            defaultBaseURL: "https://example.com/api/v1/"
        )

        let request = try builder.makeRequest(
            for: MedicineAnalyzeEndpoint.analyze(
                imageData: imageData,
                language: "ar"
            ),
            accessToken: "access-token"
        )

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.path, "/api/v1/products/analyze-image")
        XCTAssertEqual(
            URLComponents(url: try XCTUnwrap(request.url), resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "lang" })?
                .value,
            "ar"
        )
        XCTAssertEqual(
            request.value(forHTTPHeaderField: "Authorization"),
            "Bearer access-token"
        )
        XCTAssertEqual(
            request.value(forHTTPHeaderField: "X-AI-Api-Key"),
            Constants.aiKey
        )
        XCTAssertTrue(
            request.value(forHTTPHeaderField: "Content-Type")?
                .hasPrefix("multipart/form-data; boundary=") == true
        )

        let body = try XCTUnwrap(request.httpBody)
        let bodyText = try XCTUnwrap(String(data: body, encoding: .utf8))
        XCTAssertTrue(bodyText.contains("name=\"image\""))
        XCTAssertTrue(bodyText.contains("filename=\"medicine.jpg\""))
        XCTAssertTrue(bodyText.contains("Content-Type: image/jpeg"))
        XCTAssertTrue(bodyText.contains("jpeg-bytes"))
    }

    func testSuccessResponseDecodesAllProductFields() throws {
        let response = try JSONDecoder().decode(
            MedicineImageAnalysisResponseDTO.self,
            from: Data(successJSON.utf8)
        )
        let product = try XCTUnwrap(response.data?.first)

        XCTAssertTrue(response.success)
        XCTAssertEqual(product.id, 564)
        XCTAssertEqual(product.productName, "PANADOL EXTRA")
        XCTAssertNil(product.strength)
        XCTAssertEqual(product.packSize, "24")
        XCTAssertEqual(product.form, "TABS")
        XCTAssertEqual(product.price, 54)
        XCTAssertEqual(product.scientificCategory, "MILD ANALGESIC")
        XCTAssertEqual(product.consumerCategory, "PAIN RELIEF")
        XCTAssertEqual(product.categoryId, 2)
        XCTAssertEqual(product.imageUrl, "https://example.com/panadol.jpg")
    }

    func testFailureEnvelopePreservesBackendMessage() {
        let message = "Gemini rate limit or quota was exceeded. Please try again later"
        let data = Data(
            "{\"success\":false,\"message\":\"\(message)\",\"data\":null}".utf8
        )

        guard case let .validationError(mappedMessage)? =
            NetworkErrorHandler.apiEnvelopeError(from: data) else {
            return XCTFail("Expected validation error from unsuccessful envelope")
        }
        XCTAssertEqual(mappedMessage, message)
    }

    private var successJSON: String {
        """
        {
          "success": true,
          "message": "Medicine image analyzed",
          "data": [{
            "id": 564,
            "name": "PANADOL EXTRA 24 TABS",
            "productName": "PANADOL EXTRA",
            "strength": null,
            "packSize": "24",
            "form": "TABS",
            "price": 54,
            "scientificName": "CAFFEINE+PARACETAMOL(ACETAMINOPHEN)",
            "scientificCategory": "MILD ANALGESIC",
            "categoryId": 2,
            "consumerCategory": "PAIN RELIEF",
            "company": "ALEXANDRIA > GLAXO SMITHKLINE",
            "route": "ORAL.SOLID",
            "description": "Relieves mild pain.",
            "imageUrl": "https://example.com/panadol.jpg"
          }]
        }
        """
    }
}
