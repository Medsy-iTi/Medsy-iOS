//
//  OffersRemoteDataSource.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

protocol OffersRemoteDataSourceProtocol {
    func getOfferResult(requestId: Int) async throws -> OfferResultResponseDTO
    func streamOfferResult(requestId: Int) -> AsyncThrowingStream<OfferResultResponseDTO, Error>
    func confirmOffer(requestId: Int, selectedItems: [ConfirmOfferItemDTO]) async throws -> ConfirmOfferResponseDTO
    func confirmOffer(requestId: Int, selectedRequestItemIds: [Int]) async throws -> ConfirmOfferResponseDTO
}

final class OffersRemoteDataSource: OffersRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getOfferResult(requestId: Int) async throws -> OfferResultResponseDTO {
        let response: GetOfferResultResponseDTO = try await networkService.request(
            endpoint: OffersEndpoint.getResult(requestId: requestId)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let data = response.data else {
            throw NetworkError.decodingFailed
        }
        return data
    }

    func streamOfferResult(requestId: Int) -> AsyncThrowingStream<OfferResultResponseDTO, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                var currentResult: OfferResultResponseDTO?

                do {
                    let sseStream = networkService.streamSSE(endpoint: OffersEndpoint.getStream(requestId: requestId))
                    for try await sseEvent in sseStream {
                        if Task.isCancelled { break }

                        let eventName = sseEvent.event.trimmingCharacters(in: .whitespacesAndNewlines)
                        let rawData = sseEvent.data.data(using: .utf8) ?? Data()

                        print("[Offers Remote Data Source] 📩 Received SSE Event: '\(eventName)', Raw Data: \(sseEvent.data)")

                        var processed = false

                        if eventName == "snapshot" || eventName.isEmpty || eventName == "message" {
                            if let snapshotDTO = try? JSONDecoder().decode(OfferResultResponseDTO.self, from: rawData) {
                                print("[Offers Remote Data Source] ✅ Successfully decoded snapshot DTO with \(snapshotDTO.items.count) items!")
                                currentResult = snapshotDTO
                                continuation.yield(snapshotDTO)
                                processed = true
                            } else if let env = try? JSONDecoder().decode(GetOfferResultResponseDTO.self, from: rawData), let snapshotDTO = env.data {
                                print("[Offers Remote Data Source] ✅ Successfully decoded snapshot DTO envelope with \(snapshotDTO.items.count) items!")
                                currentResult = snapshotDTO
                                continuation.yield(snapshotDTO)
                                processed = true
                            }
                        }

                        if !processed && (eventName == "request-item-updated" || eventName.isEmpty || eventName == "message") {
                            if let updateEvent = try? JSONDecoder().decode(RequestItemUpdatedEventDTO.self, from: rawData) {
                                print("[Offers Remote Data Source] 🔄 Successfully decoded request-item-updated event with \(updateEvent.updatedItems.count) updated items!")
                                var existingItems = currentResult?.items ?? []

                                for updatedItem in updateEvent.updatedItems {
                                    let isAlt = updatedItem.status?.contains("ALTERNATIVE") == true
                                    let isAvail = updatedItem.status != "UNAVAILABLE" && updatedItem.product != nil
                                    let prodName = updatedItem.product?.name ?? updatedItem.product?.productName ?? ""
                                    let prodPrice = updatedItem.product?.price ?? 0.0

                                    if let idx = existingItems.firstIndex(where: { $0.requestItemId == updatedItem.requestItemId }) {
                                        let updatedDTO = OfferResultItemDTO(
                                            requestItemId: updatedItem.requestItemId,
                                            productId: updatedItem.product?.id ?? existingItems[idx].productId,
                                            productName: !prodName.isEmpty ? prodName : existingItems[idx].productName,
                                            imageUrl: updatedItem.product?.imageUrl ?? existingItems[idx].imageUrl,
                                            unitPrice: prodPrice > 0 ? prodPrice : existingItems[idx].unitPrice,
                                            isAlternative: isAlt,
                                            isAvailable: isAvail
                                        )
                                        existingItems[idx] = updatedDTO
                                    } else {
                                        let newDTO = OfferResultItemDTO(
                                            requestItemId: updatedItem.requestItemId,
                                            productId: updatedItem.product?.id,
                                            productName: prodName,
                                            imageUrl: updatedItem.product?.imageUrl,
                                            unitPrice: prodPrice,
                                            isAlternative: isAlt,
                                            isAvailable: isAvail
                                        )
                                        existingItems.append(newDTO)
                                    }
                                }

                                let calculatedTotal = existingItems.reduce(0.0) { $0 + ($1.isAvailable ? $1.unitPrice : 0.0) }
                                let newResult = OfferResultResponseDTO(
                                    items: existingItems,
                                    totalPrice: calculatedTotal,
                                    prescriptionUrl: currentResult?.prescriptionUrl
                                )
                                currentResult = newResult
                                continuation.yield(newResult)
                                processed = true
                            }
                        }

                        if !processed {
                            print("[Offers Remote Data Source] ⚠️ Warning: Unhandled or failed-to-decode SSE event '\(eventName)' with data '\(sseEvent.data)'")
                        }
                    }
                    continuation.finish()
                } catch {
                    print("[Offers Remote Data Source] ❌ Error in streamOfferResult: \(error)")
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    func confirmOffer(requestId: Int, selectedItems: [ConfirmOfferItemDTO]) async throws -> ConfirmOfferResponseDTO {
        let selectBody = ConfirmOfferRequestDTO(selectedItems: selectedItems)
        let selectResponse: APIResponseDTO<SelectPharmacyResponseDTO> = try await networkService.request(
            endpoint: OffersEndpoint.selectPharmacy(requestId: requestId, body: selectBody)
        )
        guard selectResponse.success else {
            throw NetworkError.validationError(selectResponse.message)
        }

        let response: ConfirmOfferResponseDTOContainer = try await networkService.request(
            endpoint: OffersEndpoint.confirmOffer(requestId: requestId)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let data = response.data else {
            throw NetworkError.decodingFailed
        }
        return data
    }

    func confirmOffer(requestId: Int, selectedRequestItemIds: [Int]) async throws -> ConfirmOfferResponseDTO {
        let items = selectedRequestItemIds.map { ConfirmOfferItemDTO(requestItemId: $0, productId: nil) }
        return try await confirmOffer(requestId: requestId, selectedItems: items)
    }
}
