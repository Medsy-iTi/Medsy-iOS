import XCTest
@testable import Medsy

final class CategoryArtworkMappingTests: XCTestCase {
    func testCategoryIDsMapToExpectedArtwork() {
        let expected = [
            1: "CategoryMentalHealth",
            2: "CategoryPainRelief",
            3: "CategoryColdCough",
            4: "CategoryBrainNerves",
            5: "CategorySkinCare",
            6: "CategoryHeartBloodPressure",
            7: "CategoryAntivirals",
            8: "CategoryCancerImmunity",
            9: "CategoryAllergy",
            10: "CategoryStomachDigestion",
            11: "CategoryAntiparasitics",
            12: "CategoryVitaminsSupplements",
            13: "CategoryAntibiotics",
            14: "CategoryDiabetes",
            15: "CategoryUrinaryKidney",
            16: "CategoryWomensHealth",
            17: "CategoryMensHealth",
            18: "CategoryGout",
            19: "CategoryCholesterol",
            20: "CategoryLiverGallbladder",
            21: "CategoryAntifungals",
            22: "CategoryAsthmaBreathing",
            23: "CategoryHemorrhoidsVeins",
            24: "CategoryEyeCare"
        ]

        for (id, artworkName) in expected {
            XCTAssertEqual(Category(id: id, name: "Category").artworkName, artworkName)
        }
    }

    func testUnknownCategoryUsesFallbackArtwork() {
        XCTAssertNil(Category(id: 999, name: "Unknown").artworkName)
    }
}
