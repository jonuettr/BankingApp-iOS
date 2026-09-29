//
//  APIClient.swift
//  BankingApp
//
//  Cliente HTTP central de la aplicación.
//
//  Las peticiones protegidas reciben automáticamente:
//
//  Authorization: Bearer <JWT>
//

import Foundation


// MARK: - API Error

enum APIError: Error, LocalizedError {

    case invalidURL

    case invalidResponse

    case authenticationRequired

    case unauthorized

    case serverError(
        statusCode: Int,
        message: String?
    )

    case decodingError(Error)


    var errorDescription: String? {

        switch self {

        case .invalidURL:

            return "No fue posible construir la URL del servidor."


        case .invalidResponse:

            return "El servidor devolvió una respuesta inválida."


        case .authenticationRequired:

            return "No existe una sesión autenticada."


        case .unauthorized:

            return "La sesión expiró o dejó de ser válida."


        case let .serverError(
            statusCode,
            message
        ):

            if let message,
               !message.isEmpty {

                return "Error \(statusCode): \(message)"
            }

            return "El servidor devolvió el error \(statusCode)."


        case let .decodingError(error):

            return """
            No fue posible interpretar la respuesta: \
            \(error.localizedDescription)
            """
        }
    }
}


// MARK: - API Error Response

private nonisolated struct APIErrorResponse:
    Decodable,
    Sendable {

    // Nuestro backend utiliza "error".
    let error: String?

    // Lo conservamos por compatibilidad con
    // otras respuestas que pudieran utilizar "message".
    let message: String?
}


// MARK: - HTTP Method

enum HTTPMethod: String {

    case get = "GET"

    case post = "POST"
}


// MARK: - API Client

actor APIClient {

    // MARK: Shared Instance

    static let shared =
        APIClient()


    // MARK: Configuration

    private let baseURL =
        "http://127.0.0.1:8080"

    private let session:
        URLSession
    private let decoder:
        JSONDecoder

    private let encoder:
        JSONEncoder

    private let keychain:
        KeychainService


    // MARK: Initialization

    private init(
        keychain: KeychainService = .shared
    ) {

        session =
            URLSession.shared

        decoder =
            JSONDecoder()

        encoder =
            JSONEncoder()

        self.keychain =
            keychain
    }


    // MARK: - GET

    func get<T: Decodable & Sendable>(
        path: String,
        as type: T.Type,
        requiresAuthentication: Bool = true
    ) async throws -> T {

        try await request(
            path: path,
            method: .get,
            body: nil,
            requiresAuthentication:
                requiresAuthentication,
            as: type
        )
    }


    // MARK: - POST

    func post<
        RequestBody: Encodable & Sendable,
        Response: Decodable & Sendable
    >(
        path: String,
        body: RequestBody,
        as type: Response.Type,
        requiresAuthentication: Bool = true
    ) async throws -> Response {

        let encodedBody =
            try encoder.encode(body)


        return try await request(
            path: path,
            method: .post,
            body: encodedBody,
            requiresAuthentication:
                requiresAuthentication,
            as: type
        )
    }


    // MARK: - Generic Request

    private func request<
        T: Decodable & Sendable
    >(
        path: String,
        method: HTTPMethod,
        body: Data?,
        requiresAuthentication: Bool,
        as type: T.Type
    ) async throws -> T {


        // ---------------------------------------------
        // 1. CONSTRUIR URL
        // ---------------------------------------------

        guard let url =
                URL(
                    string:
                        baseURL + path
                )
        else {

            throw APIError.invalidURL
        }


        // ---------------------------------------------
        // 2. CREAR REQUEST
        // ---------------------------------------------

        var request =
            URLRequest(url: url)

        request.httpMethod =
            method.rawValue


        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )


        if let body {

            request.httpBody =
                body

            request.setValue(
                "application/json",
                forHTTPHeaderField:
                    "Content-Type"
            )
        }


        // ---------------------------------------------
        // 3. AGREGAR JWT
        // ---------------------------------------------

        if requiresAuthentication {

            guard let token =
                    try keychain
                        .readAccessToken()
            else {

                throw APIError
                    .authenticationRequired
            }


            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField:
                    "Authorization"
            )
        }


        // ---------------------------------------------
        // 4. ENVIAR PETICIÓN
        // ---------------------------------------------

        let (data, response) =
            try await session.data(
                for: request
            )


        guard let httpResponse =
                response as? HTTPURLResponse
        else {

            throw APIError
                .invalidResponse
        }


        // ---------------------------------------------
        // 5. TOKEN INVÁLIDO O EXPIRADO
        // ---------------------------------------------

        if httpResponse.statusCode == 401 {

            throw APIError.unauthorized
        }


        // ---------------------------------------------
        // 6. OTROS ERRORES HTTP
        // ---------------------------------------------

        guard (200...299).contains(
            httpResponse.statusCode
        )
        else {

            let errorResponse =
                try? decoder.decode(
                    APIErrorResponse.self,
                    from: data
                )


            let message =
                errorResponse?.error
                ?? errorResponse?.message


            throw APIError.serverError(
                statusCode:
                    httpResponse.statusCode,
                message:
                    message
            )
        }


        // ---------------------------------------------
        // 7. JSON → SWIFT
        // ---------------------------------------------

        do {

            return try decoder.decode(
                T.self,
                from: data
            )

        } catch {

            throw APIError
                .decodingError(error)
        }
    }
}
