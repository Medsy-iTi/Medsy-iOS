import XCTest
@testable import Medsy

final class PrescriptionAnalysisContractTests: XCTestCase {
    func testAnalyzeEndpointBuildsAuthenticatedMultipartRequest() throws {
        let imageData = Data("jpeg-bytes".utf8)
        let builder = NetworkRequestBuilder(
            languageManager: .shared,
            defaultBaseURL: "https://example.com/api/v1/"
        )

        let request = try builder.makeRequest(
            for: PrescriptionEndpoint.analyze(imageData: imageData, language: "en"),
            accessToken: "access-token"
        )

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.path, "/api/v1/prescriptions/analyze")
        XCTAssertEqual(
            URLComponents(url: try XCTUnwrap(request.url), resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "lang" })?.value,
            "en"
        )
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer access-token")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Gemini-Api-Key"), Constants.geminiKey)
        XCTAssertTrue(request.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data; boundary=") == true)

        let body = try XCTUnwrap(request.httpBody)
        let bodyText = try XCTUnwrap(String(data: body, encoding: .utf8))
        XCTAssertTrue(bodyText.contains("name=\"image\""))
        XCTAssertTrue(bodyText.contains("filename=\"prescription.jpg\""))
        XCTAssertTrue(bodyText.contains("Content-Type: image/jpeg"))
        XCTAssertTrue(bodyText.contains("jpeg-bytes"))
    }

    func testSuccessResponseDecodesNullFieldsAndAllCandidates() throws {
        let data = Data(successJSON.utf8)

        let response = try JSONDecoder().decode(PrescriptionAnalysisResponseDTO.self, from: data)
        let medicine = try XCTUnwrap(response.data?.medicines.first)

        XCTAssertTrue(response.success)
        XCTAssertNil(medicine.extractedStrength)
        XCTAssertNil(medicine.extractedForm)
        XCTAssertEqual(medicine.confidence, 0.95)
        XCTAssertEqual(medicine.candidates.count, 2)
        XCTAssertEqual(medicine.candidates.first?.price, 62)
    }

    func testFailureEnvelopePreservesBackendMessage() throws {
        let message = "Gemini rate limit or quota was exceeded. Please try again later"
        let data = Data(
            "{\"success\":false,\"message\":\"\(message)\",\"data\":null}".utf8
        )

        guard case let .validationError(mappedMessage)? = NetworkErrorHandler.apiEnvelopeError(from: data) else {
            return XCTFail("Expected validation error from unsuccessful API envelope")
        }
        XCTAssertEqual(mappedMessage, message)
    }

    private var successJSON: String {
        """
        {
          "success": true,
          "message": "Prescription analyzed",
          "data": {
            "medicines": [{
              "localItemId": "medicine-1",
              "rawText": "R/ Panadol",
              "extractedName": "Panadol",
              "extractedStrength": null,
              "extractedForm": null,
              "matchStatus": "NOT_FOUND",
              "confidence": 0.95,
              "candidates": [
                {
                  "productId": 561,
                  "name": "PANADOL ACUTE HEAD COLD 20 TABS",
                  "strength": null,
                  "form": "TABS",
                  "price": 62,
                  "imageUrl": null
                },
                {
                  "productId": 562,
                  "name": "PANADOL ADVANCE 500 MG 24 TABS",
                  "strength": "500 MG",
                  "form": "TABS",
                  "price": 46.5,
                  "imageUrl": "https://example.com/panadol.jpg"
                }
              ]
            }]
          }
        }
        """
    }
}
