import XCTest
@testable import Medsy

final class HomeFeaturedCategoryCatalogTests: XCTestCase {
    func testCatalogContainsExpectedFeaturedCategoriesInDisplayOrder() {
        let categories = HomeFeaturedCategoryCatalog.categories

        XCTAssertEqual(categories.map(\.id), [9, 13, 21, 11, 7, 22, 4, 8, 19])
        XCTAssertEqual(categories.count, 9)
        XCTAssertTrue(categories.allSatisfy { !$0.name.isEmpty })
        XCTAssertTrue(categories.allSatisfy { $0.artworkName != nil })
    }
}
