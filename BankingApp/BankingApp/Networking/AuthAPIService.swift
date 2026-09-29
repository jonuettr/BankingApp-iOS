//
//  AuthAPIService.swift
//  BankingApp
//
//  Servicio responsable exclusivamente
//  de autenticación contra Spring Boot.
//
//  APIClient ya es un actor, por lo que él se encarga
//  de proteger el estado relacionado con networking.
//

import Foundation


// MARK: - Authentication API Service

nonisolated final class AuthAPIService: Sendable {

    // MARK: Shared Instance

    static let shared =
        AuthAPIService()


    // MARK: Dependencies

    private let apiClient:
        APIClient


    // MARK: Initialization

    private init(
        apiClient: APIClient = .shared
    ) {

        self.apiClient =
            apiClient
    }


    // MARK: - Login

    func login(
        email: String,
        password: String
    ) async throws -> LoginResponseDTO {

        let loginRequest =
            LoginRequestDTO(
                email: email,
                password: password
            )


        return try await apiClient.post(
            path: "/api/auth/login",
            body: loginRequest,
            as: LoginResponseDTO.self,
            requiresAuthentication: false
        )
    }
}
