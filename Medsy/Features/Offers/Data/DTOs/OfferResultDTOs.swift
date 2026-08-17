//
//  OfferResultDTOs.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

protocol OffersRemoteDataSourceProtocol {
    func getOfferResult(requestId: Int) async throws -> OfferResultResponseDTO
    func streamOfferResult(requestId: Int) -> AsyncThrowingStream<OfferResultResponseDTO, Error>
    func selectPharmacy(requestId: Int, selectedItems: [ConfirmOfferItemDTO]) async throws -> SelectPharmacyResponseDTO
    func selectPharmacy(requestId: Int, selectedRequestItemIds: [Int]) async throws -> SelectPharmacyResponseDTO
    func confirmOffer(requestId: Int, fulfillmentMethod: String) async throws -> ConfirmOfferResponseDTO
    func fetchMasterOrders(page: Int, size: Int) async throws -> [MasterOrderDTO]
    func fetchRequest(requestId: Int) async throws -> CompleteRequestResponseDTO
    func fetchRequests(page: Int, size: Int) async throws -> [CompleteRequestResponseDTO]
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
        guard var data = response.data else {
            throw NetworkError.decodingFailed
        }

        if let origReq: APIResponseDTO<CompleteRequestResponseDTO> = try? await networkService.request(endpoint: OffersEndpoint.getRequest(requestId: requestId)), let reqData = origReq.data {
            let enrichedItems = data.items.map { item -> OfferResultItemDTO in
                if let origItem = reqData.items.first(where: { $0.id == item.requestItemId }) {
                    let fallbackName = !origItem.productName.isEmpty ? origItem.productName : "offers.details.unavailableItem".localized
                    let resolvedName = (!item.productName.isEmpty && item.productName != "offers.details.unavailableItem".localized) ? item.productName : fallbackName
                    let resolvedImg = item.imageUrl ?? origItem.imageUrl
                    let resolvedPrice = item.unitPrice > 0 ? item.unitPrice : origItem.unitPrice
                    return OfferResultItemDTO(
                        requestItemId: item.requestItemId,
                        productId: item.productId ?? origItem.productId,
                        productName: resolvedName,
                        imageUrl: resolvedImg,
                        unitPrice: resolvedPrice,
                        isAlternative: item.isAlternative,
                        isAvailable: item.isAvailable
                    )
                }
                return item
            }
            data = OfferResultResponseDTO(items: enrichedItems, totalPrice: data.totalPrice, prescriptionUrl: data.prescriptionUrl ?? reqData.prescriptionUrl)
        }

        return data
    }

    func streamOfferResult(requestId: Int) -> AsyncThrowingStream<OfferResultResponseDTO, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                var currentResult: OfferResultResponseDTO?
                var origRequest: CompleteRequestResponseDTO?

                do {
                    if let orig: APIResponseDTO<CompleteRequestResponseDTO> = try? await networkService.request(endpoint: OffersEndpoint.getRequest(requestId: requestId)), let req = orig.data {
                        let upperStatus = req.status.uppercased()
                        if upperStatus == "COMPLETED" || upperStatus == "CANCELLED" || upperStatus == "DELIVERED" || upperStatus == "REJECTED" {
                            print("[Offers Remote Data Source] 🛑 Request \(requestId) is already \(upperStatus), finishing stream immediately.")
                            continuation.finish()
                            return
                        }

                        origRequest = req
                        let initialItems = req.items.map { item in
                            OfferResultItemDTO(
                                requestItemId: item.id,
                                productId: item.productId,
                                productName: item.productName,
                                imageUrl: item.imageUrl,
                                unitPrice: item.unitPrice,
                                isAlternative: false,
                                isAvailable: false
                            )
                        }
                        currentResult = OfferResultResponseDTO(
                            items: initialItems,
                            totalPrice: 0.0,
                            prescriptionUrl: req.prescriptionUrl
                        )
                    }

                    let sseStream = networkService.streamSSE(endpoint: OffersEndpoint.getStream(requestId: requestId))
                    for try await sseEvent in sseStream {
                        if Task.isCancelled { break }

                        let eventName = sseEvent.event.trimmingCharacters(in: .whitespacesAndNewlines)
                        let rawData = sseEvent.data.data(using: .utf8) ?? Data()

                        print("[Offers Remote Data Source] 📩 Received SSE Event: '\(eventName)', Raw Data: \(sseEvent.data)")

                        if eventName == "stream-closed" {
                            continuation.finish()
                            break
                        }

                        if eventName == "connected" || eventName == "heartbeat" || eventName == "ping" {
                            let fallbackDTO = currentResult ?? OfferResultResponseDTO(items: [], totalPrice: 0.0, prescriptionUrl: nil)
                            continuation.yield(fallbackDTO)
                            continue
                        }

                        var processed = false

                        if eventName == "snapshot" || eventName.isEmpty || eventName == "message" {
                            if var snapshotDTO = try? JSONDecoder().decode(OfferResultResponseDTO.self, from: rawData) {
                                print("[Offers Remote Data Source] ✅ Successfully decoded snapshot DTO with \(snapshotDTO.items.count) items!")
                                let enrichedItems = snapshotDTO.items.map { item -> OfferResultItemDTO in
                                    let origItem = origRequest?.items.first(where: { $0.id == item.requestItemId })
                                    let existing = currentResult?.items.first(where: { $0.requestItemId == item.requestItemId })
                                    let fallbackName = origItem?.productName ?? existing?.productName ?? "offers.details.unavailableItem".localized
                                    let name = (!item.productName.isEmpty && item.productName != "offers.details.unavailableItem".localized) ? item.productName : fallbackName
                                    let img = item.imageUrl ?? existing?.imageUrl ?? origItem?.imageUrl
                                    let price = item.unitPrice > 0 ? item.unitPrice : (existing?.unitPrice ?? origItem?.unitPrice ?? 0.0)
                                    let prodId = item.productId ?? existing?.productId ?? origItem?.productId
                                    return OfferResultItemDTO(
                                        requestItemId: item.requestItemId,
                                        productId: prodId,
                                        productName: name,
                                        imageUrl: img,
                                        unitPrice: price,
                                        isAlternative: item.isAlternative,
                                        isAvailable: item.isAvailable
                                    )
                                }
                                snapshotDTO = OfferResultResponseDTO(
                                    items: enrichedItems,
                                    totalPrice: snapshotDTO.totalPrice > 0 ? snapshotDTO.totalPrice : enrichedItems.reduce(0.0) { $0 + ($1.isAvailable ? $1.unitPrice : 0.0) },
                                    prescriptionUrl: snapshotDTO.prescriptionUrl ?? currentResult?.prescriptionUrl ?? origRequest?.prescriptionUrl
                                )
                                currentResult = snapshotDTO
                                continuation.yield(snapshotDTO)
                                processed = true
                            } else if let env = try? JSONDecoder().decode(GetOfferResultResponseDTO.self, from: rawData), var snapshotDTO = env.data {
                                print("[Offers Remote Data Source] ✅ Successfully decoded snapshot DTO envelope with \(snapshotDTO.items.count) items!")
                                let enrichedItems = snapshotDTO.items.map { item -> OfferResultItemDTO in
                                    let origItem = origRequest?.items.first(where: { $0.id == item.requestItemId })
                                    let existing = currentResult?.items.first(where: { $0.requestItemId == item.requestItemId })
                                    let fallbackName = origItem?.productName ?? existing?.productName ?? "offers.details.unavailableItem".localized
                                    let name = (!item.productName.isEmpty && item.productName != "offers.details.unavailableItem".localized) ? item.productName : fallbackName
                                    let img = item.imageUrl ?? existing?.imageUrl ?? origItem?.imageUrl
                                    let price = item.unitPrice > 0 ? item.unitPrice : (existing?.unitPrice ?? origItem?.unitPrice ?? 0.0)
                                    let prodId = item.productId ?? existing?.productId ?? origItem?.productId
                                    return OfferResultItemDTO(
                                        requestItemId: item.requestItemId,
                                        productId: prodId,
                                        productName: name,
                                        imageUrl: img,
                                        unitPrice: price,
                                        isAlternative: item.isAlternative,
                                        isAvailable: item.isAvailable
                                    )
                                }
                                snapshotDTO = OfferResultResponseDTO(
                                    items: enrichedItems,
                                    totalPrice: snapshotDTO.totalPrice > 0 ? snapshotDTO.totalPrice : enrichedItems.reduce(0.0) { $0 + ($1.isAvailable ? $1.unitPrice : 0.0) },
                                    prescriptionUrl: snapshotDTO.prescriptionUrl ?? currentResult?.prescriptionUrl ?? origRequest?.prescriptionUrl
                                )
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
                                    let isFound = updatedItem.status == "FOUND"
                                    let isAlt = updatedItem.status == "ALTERNATIVE_FOUND" || updatedItem.status?.contains("ALTERNATIVE") == true
                                    let isAvail = isFound || (isAlt && updatedItem.product != nil) || (updatedItem.status != "UNAVAILABLE" && updatedItem.status != "NOT_FOUND" && updatedItem.status != nil)
                                    let prodName = updatedItem.product?.name ?? updatedItem.product?.productName ?? ""
                                    let prodPrice = updatedItem.product?.price ?? 0.0
                                    let origItem = origRequest?.items.first(where: { $0.id == updatedItem.requestItemId })

                                    if let idx = existingItems.firstIndex(where: { $0.requestItemId == updatedItem.requestItemId }) {
                                        let fallbackName = !existingItems[idx].productName.isEmpty && existingItems[idx].productName != "offers.details.unavailableItem".localized ? existingItems[idx].productName : (origItem?.productName ?? "offers.details.unavailableItem".localized)
                                        let finalName = !prodName.isEmpty ? prodName : fallbackName
                                        let finalImg = updatedItem.product?.imageUrl ?? existingItems[idx].imageUrl ?? origItem?.imageUrl
                                        let existingPrice = existingItems[idx].unitPrice > 0 ? existingItems[idx].unitPrice : (origItem?.unitPrice ?? 0.0)
                                        let finalPrice = prodPrice > 0 ? prodPrice : existingPrice
                                        let updatedDTO = OfferResultItemDTO(
                                            requestItemId: updatedItem.requestItemId,
                                            productId: updatedItem.product?.id ?? existingItems[idx].productId ?? origItem?.productId,
                                            productName: finalName,
                                            imageUrl: finalImg,
                                            unitPrice: finalPrice,
                                            isAlternative: isAlt,
                                            isAvailable: isAvail
                                        )
                                        existingItems[idx] = updatedDTO
                                    } else {
                                        let fallbackName = origItem?.productName ?? "offers.details.unavailableItem".localized
                                        let finalName = !prodName.isEmpty ? prodName : fallbackName
                                        let finalImg = updatedItem.product?.imageUrl ?? origItem?.imageUrl
                                        let finalPrice = prodPrice > 0 ? prodPrice : (origItem?.unitPrice ?? 0.0)
                                        let newDTO = OfferResultItemDTO(
                                            requestItemId: updatedItem.requestItemId,
                                            productId: updatedItem.product?.id ?? origItem?.productId,
                                            productName: finalName,
                                            imageUrl: finalImg,
                                            unitPrice: finalPrice,
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
                                    prescriptionUrl: currentResult?.prescriptionUrl ?? origRequest?.prescriptionUrl
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

    func selectPharmacy(requestId: Int, selectedItems: [ConfirmOfferItemDTO]) async throws -> SelectPharmacyResponseDTO {
        let selectBody = ConfirmOfferRequestDTO(selectedItems: selectedItems)
        let selectResponse: APIResponseDTO<SelectPharmacyResponseDTO> = try await networkService.request(
            endpoint: OffersEndpoint.selectPharmacy(requestId: requestId, body: selectBody)
        )
        guard selectResponse.success else {
            throw NetworkError.validationError(selectResponse.message)
        }
        guard let data = selectResponse.data else {
            throw NetworkError.decodingFailed
        }
        return data
    }

    func selectPharmacy(requestId: Int, selectedRequestItemIds: [Int]) async throws -> SelectPharmacyResponseDTO {
        let items = selectedRequestItemIds.map { ConfirmOfferItemDTO(requestItemId: $0, productId: nil) }
        return try await selectPharmacy(requestId: requestId, selectedItems: items)
    }

    func confirmOffer(requestId: Int, fulfillmentMethod: String) async throws -> ConfirmOfferResponseDTO {
        let body = ConfirmOfferFulfillmentRequestDTO(fulfillmentMethod: fulfillmentMethod)
        let response: ConfirmOfferResponseDTOContainer = try await networkService.request(
            endpoint: OffersEndpoint.confirmOffer(requestId: requestId, body: body)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let data = response.data else {
            throw NetworkError.decodingFailed
        }
        return data
    }

    func fetchMasterOrders(page: Int = 0, size: Int = 10) async throws -> [MasterOrderDTO] {
        if let response: APIResponseDTO<MasterOrdersListResponseDTO> = try? await networkService.request(
            endpoint: OffersEndpoint.getMasterOrders(page: page, size: size)
        ), let content = response.data?.content {
            return content
        }
        if let direct: APIResponseDTO<[MasterOrderDTO]> = try? await networkService.request(
            endpoint: OffersEndpoint.getMasterOrders(page: page, size: size)
        ), let data = direct.data {
            return data
        }
        return []
    }

    func fetchRequest(requestId: Int) async throws -> CompleteRequestResponseDTO {
        let response: APIResponseDTO<CompleteRequestResponseDTO> = try await networkService.request(
            endpoint: OffersEndpoint.getRequest(requestId: requestId)
        )
        guard response.success, let data = response.data else {
            throw NetworkError.decodingFailed
        }
        return data
    }

    func fetchRequests(page: Int = 0, size: Int = 3) async throws -> [CompleteRequestResponseDTO] {
        if let response: APIResponseDTO<RequestsListResponseDTO> = try? await networkService.request(
            endpoint: OffersEndpoint.getRequests(page: page, size: size)
        ), let content = response.data?.content {
            return content
        }
        if let direct: APIResponseDTO<[CompleteRequestResponseDTO]> = try? await networkService.request(
            endpoint: OffersEndpoint.getRequests(page: page, size: size)
        ), let data = direct.data {
            return data
        }
        return []
    }
}
