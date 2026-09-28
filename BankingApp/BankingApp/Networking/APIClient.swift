//
//  APIClient.swift
//  BankingApp
//
//  Cliente encargado de realizar las peticiones HTTP
//  hacia nuestra API desarrollada con Spring Boot.
//
//  Flujo:
//
//  SwiftUI
//      ↓
//  ViewModel
//      ↓
//  BankingService
//      ↓
//  APIClient
//      ↓
//  Spring Boot
//      ↓
//  MySQL
//

import Foundation


// MARK: - API Error

enum APIError: Error, LocalizedError {

    case invalidURL

    case invalidResponse

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

        case let .serverError(statusCode, message):

            if let message,
               !message.isEmpty {

                return "Error \(statusCode): \(message)"
            }

            return "El servidor devolvió el error \(statusCode)."

        case let .decodingError(error):

            return "No fue posible interpretar la respuesta: \(error.localizedDescription)"
        }
    }
}


// MARK: - API Error Response

private nonisolated struct APIErrorResponse: Decodable, Sendable {

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

    static let shared = APIClient()


    // MARK: Configuration

    private let baseURL =
        "http://127.0.0.1:8080"

    private let session: URLSession

    private let decoder: JSONDecoder

    private let encoder: JSONEncoder


    // MARK: Initialization

    private init() {

        session = URLSession.shared

        decoder = JSONDecoder()

        encoder = JSONEncoder()
    }


    // MARK: - GET

    func get<T: Decodable & Sendable>(
        path: String,
        as type: T.Type
    ) async throws -> T {

        try await request(
            path: path,
            method: .get,
            body: nil,
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
        as type: Response.Type
    ) async throws -> Response {

        let encodedBody = try encoder.encode(body)

        return try await request(
            path: path,
            method: .post,
            body: encodedBody,
            as: type
        )
    }


    // MARK: - Generic Request

    private func request<T: Decodable & Sendable>(
        path: String,
        method: HTTPMethod,
        body: Data?,
        as type: T.Type
    ) async throws -> T {


        // -------------------------------------------------
        // 1. CONSTRUIR URL
        // -------------------------------------------------

        guard let url =
                URL(
                    string: baseURL + path
                )
        else {

            throw APIError.invalidURL
        }


        // -------------------------------------------------
        // 2. CREAR HTTP REQUEST
        // -------------------------------------------------

        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue


        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )


        if let body {

            request.httpBody = body

            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
        }


        // -------------------------------------------------
        // 3. ENVIAR PETICIÓN
        // -------------------------------------------------

        let (data, response) =
            try await session.data(
                for: request
            )


        // -------------------------------------------------
        // 4. VALIDAR RESPUESTA HTTP
        // -------------------------------------------------

        guard let httpResponse =
                response as? HTTPURLResponse
        else {

            throw APIError.invalidResponse
        }


        guard (200...299).contains(
            httpResponse.statusCode
        )
        else {

            let errorResponse =
                try? decoder.decode(
                    APIErrorResponse.self,
                    from: data
                )

            throw APIError.serverError(
                statusCode:
                    httpResponse.statusCode,
                message:
                    errorResponse?.message
            )
        }


        // -------------------------------------------------
        // 5. JSON → SWIFT
        // -------------------------------------------------

        do {

            return try decoder.decode(
                T.self,
                from: data
            )

        } catch {

            throw APIError.decodingError(
                error
            )
        }
    }
}
