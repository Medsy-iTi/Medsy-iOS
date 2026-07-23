import XCTest
@testable import Medsy_Pharmacy

final class PharmacyOrdersRequestsEndpointTests: XCTestCase {

    func test_decodingPharmacyRequestsPayload() throws {
        let jsonString = """
        {
          "success": true,
          "message": "Pharmacy requests fetched successfully",
          "data": {
            "content": [
              {
                "id": 12,
                "customerId": 12,
                "deliveryLatitude": 30.0444,
                "deliveryLongitude": 31.2357,
                "deliveryAddress": "Cairo",
                "status": "PENDING",
                "createdAt": "2026-07-23T17:10:31.250537",
                "items": [
                  {
                    "id": 17,
                    "productId": 705,
                    "quantity": 1
                  },
                  {
                    "id": 18,
                    "productId": 438,
                    "quantity": 1
                  },
                  {
                    "id": 19,
                    "productId": 697,
                    "quantity": 1
                  }
                ]
              },
              {
                "id": 13,
                "customerId": 12,
                "deliveryLatitude": 30.0444,
                "deliveryLongitude": 31.2357,
                "deliveryAddress": "cairo",
                "status": "PENDING",
                "createdAt": "2026-07-23T17:30:57.815767",
                "items": [
                  {
                    "id": 20,
                    "productId": 694,
                    "quantity": 1
                  },
                  {
                    "id": 21,
                    "productId": 518,
                    "quantity": 1
                  },
                  {
                    "id": 22,
                    "productId": 15,
                    "quantity": 1
                  }
                ]
              }
            ],
            "pageNumber": 0,
            "pageSize": 20,
            "totalElements": 2,
            "totalPages": 1,
            "last": true
          }
        }
        """

        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))
        let envelope = try JSONDecoder().decode(APIEnvelope<PageResponseDTO<PharmacyOrderDTO>>.self, from: jsonData)

        XCTAssertTrue(envelope.success)
        XCTAssertEqual(envelope.message, "Pharmacy requests fetched successfully")

        let page = try XCTUnwrap(envelope.data)
        XCTAssertEqual(page.pageNumber, 0)
        XCTAssertEqual(page.pageSize, 20)
        XCTAssertEqual(page.totalElements, 2)
        XCTAssertEqual(page.totalPages, 1)
        XCTAssertTrue(page.last)
        XCTAssertEqual(page.content.count, 2)

        let firstItem = page.content[0]
        XCTAssertEqual(firstItem.id, 12)
        XCTAssertEqual(firstItem.customerId, 12)
        XCTAssertEqual(firstItem.deliveryLatitude, 30.0444)
        XCTAssertEqual(firstItem.deliveryLongitude, 31.2357)
        XCTAssertEqual(firstItem.deliveryAddress, "Cairo")
        XCTAssertEqual(firstItem.status, "PENDING")
        XCTAssertEqual(firstItem.createdAt, "2026-07-23T17:10:31.250537")
        XCTAssertEqual(firstItem.items.count, 3)

        let mappedPage = PharmacyOrderMapper.map(page)
        XCTAssertEqual(mappedPage.orders.count, 2)
        XCTAssertEqual(mappedPage.orders[0].id, 12)
        XCTAssertEqual(mappedPage.orders[0].deliveryAddress, "Cairo")
        XCTAssertEqual(mappedPage.orders[0].status, .pending)
    }

    func test_pharmacyOrdersEndpoint_pathIsPharmaciesRequests() {
        let endpoint = PharmacyOrdersEndpoint.fetchOrders(pharmacyId: 1, page: 0, size: 20)
        XCTAssertEqual(endpoint.path, "pharmacies/requests")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertTrue(endpoint.requiresAuthentication)
        XCTAssertEqual(endpoint.queryParameters?["page"] as? Int, 0)
        XCTAssertEqual(endpoint.queryParameters?["size"] as? Int, 20)
    }
}
