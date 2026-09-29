//
//  APIErrorHandler.swift
//  BankingApp
//
//  Convierte errores técnicos de red en acciones y mensajes
//  que tienen sentido para la aplicación.
//

import Foundation

// MARK: - API Error Handler

@MainActor
enum APIErrorHandler {

    // Procesa un error recibido desde la capa de red.
    //
    // Si el servidor responde 401 significa que el JWT
    // ya no autoriza al usuario. En ese caso eliminamos
    // la sesión local.
    //
    // Como BankingAppApp observa SessionManager,
    // currentCustomer = nil provoca automáticamente:
    //
    // Home -> Login
    static func handle(
        _ error: Error,
        session: SessionManager = .shared
    ) -> String {

        guard let apiError = error as? APIError else {
            return messageForNetworkError(error)
        }

        switch apiError {

        case .authenticationRequired,
             .unauthorized:

            session.invalidateSession()

            return """
            Tu sesión expiró. Inicia sesión nuevamente.
            """

        case .invalidURL,
             .invalidResponse:

            return """
            No fue posible comunicarse correctamente con el servidor.
            """

        case let .serverError(statusCode, message):

            return messageForServerError(
                statusCode: statusCode,
                backendMessage: message
            )

        case .decodingError:

            return """
            Recibimos información que la aplicación no pudo interpretar.
            """
        }
    }

    // MARK: - Server Errors

    private static func messageForServerError(
        statusCode: Int,
        backendMessage: String?
    ) -> String {

        switch statusCode {

        case 403:
            return """
            No tienes autorización para realizar esta operación.
            """

        case 400...499:
            // Algunos mensajes del backend sí son apropiados
            // para mostrarlos al usuario.
            if let backendMessage,
               !backendMessage.isEmpty {

                return backendMessage
            }

            return """
            No fue posible completar la solicitud.
            """

        case 500...599:
            return """
            El servicio no está disponible en este momento. Inténtalo más tarde.
            """

        default:
            return """
            Ocurrió un error al comunicarse con el servidor.
            """
        }
    }

    // MARK: - URLSession Errors

    private static func messageForNetworkError(
        _ error: Error
    ) -> String {

        guard let urlError = error as? URLError else {
            return """
            Ocurrió un error inesperado. Inténtalo nuevamente.
            """
        }

        switch urlError.code {

        case .notConnectedToInternet,
             .networkConnectionLost:

            return """
            No hay conexión a Internet. Revisa tu conexión e inténtalo nuevamente.
            """

        case .timedOut:

            return """
            El servidor tardó demasiado en responder. Inténtalo nuevamente.
            """

        case .cannotConnectToHost,
             .cannotFindHost:

            return """
            No fue posible conectarse con el servidor.
            """

        default:

            return """
            Ocurrió un problema de conexión. Inténtalo nuevamente.
            """
        }
    }
}
