import XCTest
@testable import Medsy

final class CartInteractionDomainTests: XCTestCase {
    func testGetCartInteractionsForwardsLanguageAndWarnings() async throws {
        let warning = CartInteractionWarning(
            severity: .high,
            title: "Interaction",
            advice: "Ask your pharmacist",
            involvedProducts: [
                CartInteractionProduct(
                    productID: 17,
                    productName: "Medicine",
                    ingredient: "Ingredient"
                )
            ]
        )
        let repository = CartInteractionRepositorySpy(warnings: [warning])
        let useCase = GetCartInteractionsUseCase(repository: repository)

        let result = try await useCase.execute(language: "ar")

        XCTAssertEqual(result, [warning])
        XCTAssertEqual(repository.requestedLanguage, "ar")
    }
}

private final class CartInteractionRepositorySpy: CartRepositoryProtocol {
    private let warnings: [CartInteractionWarning]
    private(set) var requestedLanguage: String?

    init(warnings: [CartInteractionWarning]) {
        self.warnings = warnings
    }

    func fetchCachedCart() async throws -> Cart {
        Cart()
    }

    func fetchCart() async throws -> Cart {
        Cart()
    }

    func addItem(input: AddCartItemInput) async throws -> Cart {
        Cart()
    }

    func updateItem(id: Int64, quantity: Int) async throws -> Cart {
        Cart()
    }

    func removeItem(id: Int64) async throws -> Cart {
        Cart()
    }

    func clearCart() async throws {}

    func fetchItemCount() async throws -> Int {
        0
    }

    func fetchInteractions(language: String) async throws -> [CartInteractionWarning] {
        requestedLanguage = language
        return warnings
    }
}
