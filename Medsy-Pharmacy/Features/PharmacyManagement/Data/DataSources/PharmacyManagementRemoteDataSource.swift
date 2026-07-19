//
//  PharmacyManagementRemoteDataSource.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol PharmacyManagementRemoteDataSourceProtocol {
    func getMyPharmacy() async throws -> PharmacyMineDTO?
    func createPharmacy(input: CreatePharmacyInput) async throws -> PharmacyMutationDTO
    func updatePharmacy(input: UpdatePharmacyInput) async throws -> PharmacyMutationDTO
    func deletePharmacy(id: Int) async throws
}

final class PharmacyManagementRemoteDataSource: PharmacyManagementRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getMyPharmacy() async throws -> PharmacyMineDTO? {
        do {
            let response: PharmacyManagementResponseDTO<PharmacyMineDTO> = try await networkService.request(
                endpoint: PharmacyManagementEndpoint.mine
            )
            return try requiredData(from: response)
        } catch NetworkError.notFound {
            return nil
        } catch NetworkError.validationError(let message)
            where message == "You are not assigned to any pharmacy" {
            return nil
        }
    }

    func createPharmacy(input: CreatePharmacyInput) async throws -> PharmacyMutationDTO {
        let multipart = try PharmacyMultipartBody(
            request: CreatePharmacyRequestDTO(input: input),
            license: input.license
        )
        let response: PharmacyManagementResponseDTO<PharmacyMutationDTO> = try await networkService.request(
            endpoint: PharmacyManagementEndpoint.create(multipart)
        )
        return try requiredData(from: response)
    }

    func updatePharmacy(input: UpdatePharmacyInput) async throws -> PharmacyMutationDTO {
        let response: PharmacyManagementResponseDTO<PharmacyMutationDTO> = try await networkService.request(
            endpoint: PharmacyManagementEndpoint.update(
                input.id,
                UpdatePharmacyRequestDTO(input: input)
            )
        )
        return try requiredData(from: response)
    }

    func deletePharmacy(id: Int) async throws {
        let response: PharmacyDeletionResponseDTO = try await networkService.request(
            endpoint: PharmacyManagementEndpoint.delete(id)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
    }

    private func requiredData<Data>(
        from response: PharmacyManagementResponseDTO<Data>
    ) throws -> Data {
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let data = response.data else {
            throw NetworkError.decodingFailed
        }
        return data
    }
}
