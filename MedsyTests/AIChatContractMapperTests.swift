//
//  AIChatContractMapperTests.swift
//  MedsyTests
//

import XCTest
@testable import Medsy

final class AIChatContractMapperTests: XCTestCase {
    func testCompleteResponseMapsCardsActionAndPharmacistRanking() throws {
        let dto = try JSONDecoder().decode(
            AIChatMessageResponseDTO.self,
            from: Data(completeResponseJSON.utf8)
        )

        let response = AIChatContractMapper.map(dto)

        XCTAssertEqual(response.intent, .pharmacistPerformance)
        XCTAssertEqual(response.products.map(\.id), [142])
        XCTAssertEqual(response.emergencyNumbers.count, 1)
        XCTAssertEqual(response.emergencyNumbers.first?.service, .ambulance)
        XCTAssertEqual(response.categories, [AIChatCategory(id: 3, name: "Skin Care")])
        XCTAssertEqual(response.action?.type, .addedToCart)
        XCTAssertEqual(response.action?.addedProductIDs, [142])
        XCTAssertEqual(response.pharmacistRankings.first?.metric, .offersCreated)
        XCTAssertEqual(response.pharmacistRankings.first?.period, .lastWeek)
        XCTAssertEqual(response.pharmacistRankings.first?.entries.first?.pharmacistID, 17)
        XCTAssertEqual(response.pharmacistRankings.first?.entries.first?.count, 12)
    }

    func testSparseAndUnknownResponseUsesDefensiveFallbacks() throws {
        let json = """
        {
          "intent": "FUTURE_INTENT",
          "answer": "Fallback answer",
          "action": {"type": "FUTURE_ACTION"}
        }
        """
        let dto = try JSONDecoder().decode(
            AIChatMessageResponseDTO.self,
            from: Data(json.utf8)
        )

        let response = AIChatContractMapper.map(dto)

        XCTAssertEqual(response.intent, .other)
        XCTAssertTrue(response.products.isEmpty)
        XCTAssertTrue(response.alternatives.isEmpty)
        XCTAssertTrue(response.categories.isEmpty)
        XCTAssertTrue(response.pharmacistRankings.isEmpty)
        XCTAssertNil(response.action)
    }

    func testHistoryStripsImageMarkerAndParsesBackendLocalDates() throws {
        let json = """
        {
          "conversationId": 1,
          "messages": [
            {
              "id": 41,
              "role": "USER",
              "content": "Please identify this\n[image] Extracted: Panadol",
              "createdAt": "2026-08-03T14:00:00.123456789"
            },
            {
              "id": 42,
              "role": "ASSISTANT",
              "content": "It is Panadol",
              "intent": "MEDICINE_REQUEST",
              "createdAt": "2026-08-03T14:00:01"
            }
          ]
        }
        """
        let dto = try JSONDecoder().decode(
            AIChatHistoryResponseDTO.self,
            from: Data(json.utf8)
        )

        let history = AIChatContractMapper.map(dto)

        XCTAssertEqual(history.messages.first?.content, "Please identify this")
        XCTAssertEqual(history.messages.first?.role, .user)
        XCTAssertEqual(history.messages.last?.intent, .medicineRequest)
        XCTAssertNotNil(history.messages.first?.createdAt)
        XCTAssertNotNil(history.messages.last?.createdAt)
    }

    func testInteractionWarningsDefaultUnknownSeverityToModerateAndDropMalformedProducts() throws {
        let json = """
        {
          "warnings": [{
            "severity": "FUTURE_SEVERITY",
            "title": "Interaction",
            "advice": "Ask your pharmacist",
            "involvedProducts": [
              {"productId": 142, "productName": "BRUFEN", "ingredient": "IBUPROFEN"},
              {"productName": "Missing identifier"}
            ]
          }]
        }
        """
        let dto = try JSONDecoder().decode(
            AIChatCartInteractionsResponseDTO.self,
            from: Data(json.utf8)
        )

        let warnings = AIChatContractMapper.map(dto)

        XCTAssertEqual(warnings.first?.severity, .moderate)
        XCTAssertEqual(warnings.first?.involvedProducts.count, 1)
        XCTAssertEqual(warnings.first?.involvedProducts.first?.productID, 142)
    }

    func testCartItemDecodesNestedBackendProductAndLegacyFlatFields() throws {
        let nested = """
        {
          "id": 1,
          "productId": 142,
          "unitPrice": 48.0,
          "quantity": 2,
          "subtotal": 96.0,
          "product": {
            "id": 142,
            "name": "BRUFEN 200 MG 30 TABS",
            "productName": "BRUFEN",
            "imageUrl": "https://example.com/brufen.jpg"
          }
        }
        """
        let flat = """
        {
          "id": 2,
          "productId": 143,
          "productName": "PANADOL EXTRA",
          "imageUrl": "https://example.com/panadol.jpg",
          "unitPrice": 54.0,
          "quantity": 1,
          "subtotal": 54.0
        }
        """

        let nestedItem = try JSONDecoder().decode(CartItemDTO.self, from: Data(nested.utf8))
        let flatItem = try JSONDecoder().decode(CartItemDTO.self, from: Data(flat.utf8))

        XCTAssertEqual(nestedItem.productName, "BRUFEN")
        XCTAssertEqual(nestedItem.imageUrl, "https://example.com/brufen.jpg")
        XCTAssertEqual(flatItem.productName, "PANADOL EXTRA")
        XCTAssertEqual(flatItem.imageUrl, "https://example.com/panadol.jpg")
    }

    private var completeResponseJSON: String {
        """
        {
          "conversationId": 1,
          "messageId": 42,
          "intent": "PHARMACIST_PERFORMANCE",
          "answer": "Top staff",
          "products": [{
            "id": 142,
            "name": "BRUFEN 200 MG 30 TABS",
            "productName": "BRUFEN",
            "price": 48.0
          }],
          "alternatives": [],
          "doctorSpecializations": ["Cardiologist"],
          "emergencyNumbers": [
            {"service": "AMBULANCE", "number": "123"},
            {"service": "UNKNOWN", "number": "999"}
          ],
          "categories": [{"id": 3, "name": "Skin Care"}],
          "pharmacistRankings": [{
            "metric": "OFFERS_CREATED",
            "period": "LAST_WEEK",
            "entries": [{
              "rank": 1,
              "pharmacistId": 17,
              "firstName": "Ahmed",
              "lastName": "Ali",
              "count": 12
            }]
          }],
          "disclaimer": null,
          "action": {
            "type": "ADDED_TO_CART",
            "addedProductIds": [142],
            "quantity": 2,
            "cartItemCount": 3
          }
        }
        """
    }
}
