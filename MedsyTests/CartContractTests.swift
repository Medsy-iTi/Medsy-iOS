import XCTest
@testable import Medsy

final class CartContractTests: XCTestCase {
    func testDecodesCurrentNestedCartResponse() throws {
        let response = try decodeResponse(
            """
            {
              "success": true,
              "message": "Cart fetched",
              "data": {
                "id": 9,
                "items": [
                  {
                    "id": 21,
                    "productId": 562,
                    "unitPrice": 42.5,
                    "quantity": 2,
                    "subtotal": 85,
                    "product": {
                      "id": 562,
                      "name": "Panadol",
                      "productName": "Panadol Extra",
                      "strength": "500 mg",
                      "packSize": "24 tablets",
                      "price": 42.5,
                      "imageUrl": "https://example.com/panadol.png"
                    }
                  }
                ],
                "totalPrice": 85
              }
            }
            """
        )

        let item = try XCTUnwrap(response.data?.items.first)
        XCTAssertEqual(item.productId, 562)
        XCTAssertEqual(item.productName, "Panadol Extra")
        XCTAssertEqual(item.dosageInfo, "500 mg • 24 tablets")
        XCTAssertEqual(item.imageUrl, "https://example.com/panadol.png")
        XCTAssertEqual(item.unitPrice, 42.5)
        XCTAssertEqual(item.quantity, 2)
        XCTAssertEqual(item.subtotal, 85)
    }

    func testDecodesLegacyFlatCartResponse() throws {
        let response = try decodeResponse(
            """
            {
              "success": true,
              "message": "Cart fetched",
              "data": {
                "id": 9,
                "items": [
                  {
                    "id": 21,
                    "productId": 562,
                    "productName": "Panadol Extra",
                    "dosageInfo": "500 mg",
                    "imageUrl": "https://example.com/panadol.png",
                    "unitPrice": 42.5,
                    "quantity": 2,
                    "subtotal": 85
                  }
                ],
                "totalPrice": 85
              }
            }
            """
        )

        let item = try XCTUnwrap(response.data?.items.first)
        XCTAssertEqual(item.productId, 562)
        XCTAssertEqual(item.productName, "Panadol Extra")
        XCTAssertEqual(item.dosageInfo, "500 mg")
        XCTAssertEqual(item.imageUrl, "https://example.com/panadol.png")
    }

    func testUsesNestedProductFallbacksForSparseCartLine() throws {
        let response = try decodeResponse(
            """
            {
              "success": true,
              "message": "Cart fetched",
              "data": {
                "id": 9,
                "items": [
                  {
                    "id": 21,
                    "quantity": 3,
                    "product": {
                      "id": 562,
                      "name": "Panadol",
                      "form": "Tablet",
                      "price": 10
                    }
                  }
                ]
              }
            }
            """
        )

        let cart = try XCTUnwrap(response.data)
        let item = try XCTUnwrap(cart.items.first)
        XCTAssertEqual(item.productId, 562)
        XCTAssertEqual(item.productName, "Panadol")
        XCTAssertEqual(item.dosageInfo, "Tablet")
        XCTAssertEqual(item.unitPrice, 10)
        XCTAssertEqual(item.subtotal, 30)
        XCTAssertEqual(cart.totalPrice, 30)
    }

    func testRejectsCartLineWithoutProductIdentifier() {
        XCTAssertThrowsError(
            try decodeResponse(
                """
                {
                  "success": true,
                  "message": "Cart fetched",
                  "data": {
                    "id": 9,
                    "items": [
                      {
                        "id": 21,
                        "quantity": 1,
                        "unitPrice": 10
                      }
                    ],
                    "totalPrice": 10
                  }
                }
                """
            )
        )
    }

    func testDecodesAndMapsCartInteractionWarnings() throws {
        let response = try decodeInteractions(
            """
            {
              "success": true,
              "message": "Cart interactions evaluated",
              "data": {
                "warnings": [
                  {
                    "severity": "HIGH",
                    "title": "Potential interaction",
                    "advice": "Ask your pharmacist",
                    "involvedProducts": [
                      {
                        "productId": 17,
                        "productName": "Medicine",
                        "ingredient": "Ingredient"
                      }
                    ]
                  }
                ]
              }
            }
            """
        )

        let dto = try XCTUnwrap(response.data?.warnings.first)
        let warning = CartMapper.map(dto)
        XCTAssertEqual(warning.severity, .high)
        XCTAssertEqual(warning.title, "Potential interaction")
        XCTAssertEqual(warning.advice, "Ask your pharmacist")
        XCTAssertEqual(warning.involvedProducts.first?.productID, 17)
        XCTAssertEqual(warning.involvedProducts.first?.productName, "Medicine")
        XCTAssertEqual(warning.involvedProducts.first?.ingredient, "Ingredient")
    }

    func testInteractionContractDefaultsSparseCollectionsAndUnknownSeverity() throws {
        let response = try decodeInteractions(
            """
            {
              "success": true,
              "message": "Cart interactions evaluated",
              "data": {
                "warnings": [
                  {
                    "severity": "CRITICAL",
                    "title": "Review medicines",
                    "advice": ""
                  }
                ]
              }
            }
            """
        )

        let dto = try XCTUnwrap(response.data?.warnings.first)
        let warning = CartMapper.map(dto)
        XCTAssertEqual(warning.severity, .moderate)
        XCTAssertTrue(warning.involvedProducts.isEmpty)
    }

    func testInteractionContractDefaultsMissingWarningsToEmpty() throws {
        let response = try decodeInteractions(
            """
            {
              "success": true,
              "message": "Cart interactions evaluated",
              "data": {}
            }
            """
        )

        XCTAssertEqual(response.data?.warnings, [])
    }

    func testInteractionEndpointUsesCurrentCartAndLanguage() {
        let endpoint = CartEndpoint.interactions(language: "ar")

        XCTAssertEqual(endpoint.path, "cart/interactions")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(endpoint.queryParameters?["lang"] as? String, "ar")
        XCTAssertTrue(endpoint.requiresAuthentication)
    }

    private func decodeResponse(_ json: String) throws -> CartResponseDTO {
        try JSONDecoder().decode(CartResponseDTO.self, from: Data(json.utf8))
    }

    private func decodeInteractions(_ json: String) throws -> CartInteractionsResponseDTO {
        try JSONDecoder().decode(CartInteractionsResponseDTO.self, from: Data(json.utf8))
    }
}
