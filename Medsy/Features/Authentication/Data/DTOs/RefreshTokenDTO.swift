//
//  RefreshTokenDTO.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

struct RefreshTokenRequestDTO: Encodable, Equatable {
    let refreshToken: String
}

typealias LogoutRequestDTO = RefreshTokenRequestDTO
typealias LogoutResponseDTO = APIResponseDTO<LogoutResponseDataDTO>

struct LogoutResponseDataDTO: Decodable, Equatable {}
