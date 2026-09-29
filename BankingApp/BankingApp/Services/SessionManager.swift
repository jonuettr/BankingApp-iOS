//
//  SessionManager.swift
//  BankingApp
//
//  Administra la sesión autenticada.
//
//  Responsabilidades:
//  - iniciar sesión contra el backend;
//  - guardar/eliminar el JWT del Keychain;
//  - recuperar una sesión al abrir la app;
//  - solicitar biometría cuando el usuario la tenga habilitada;
//  - eliminar sesiones que ya no sean válidas.
//

import Foundation
import Observation


@MainActor
@Observable
final class SessionManager {

    // MARK: - Shared Instance

    static let shared =
        SessionManager()


    // MARK: - Dependencies

    private let authService:
        AuthAPIService

    private let keychain:
        KeychainService

    private let biometricSettings:
        BiometricSettings


    // MARK: - Session State

    private(set) var currentCustomer:
        Customer?

    private(set) var isLoggingIn =
        false

    private(set) var isRestoringSession =
        false

    // Evita ejecutar la restauración varias veces
    // durante el mismo ciclo de vida de la app.
    private var didAttemptSessionRestore =
        false


    var isAuthenticated: Bool {

        currentCustomer != nil
    }


    // MARK: - Initialization

    private init() {

        // AuthAPIService y KeychainService son servicios
        // compartidos de infraestructura.
        self.authService =
            AuthAPIService.shared

        self.keychain =
            KeychainService.shared

        self.biometricSettings =
            BiometricSettings.shared

        currentCustomer =
            nil
    }


    // MARK: - Login

    func login(
        email: String,
        password: String
    ) async throws {

        guard !isLoggingIn
        else {

            return
        }


        isLoggingIn =
            true


        defer {

            isLoggingIn =
                false
        }


        // El backend comprueba las credenciales
        // y devuelve un JWT cuando son válidas.
        let response =
            try await authService.login(
                email: email,
                password: password
            )


        // El token se almacena en Keychain,
        // no en UserDefaults.
        try keychain.saveAccessToken(
            response.accessToken
        )


        do {

            // Esta petición ya utiliza automáticamente
            // el JWT recién almacenado.
            let customer =
                try await BankingAPIService
                    .shared
                    .fetchCustomer(
                        id:
                            response.customerId
                    )


            currentCustomer =
                customer

        } catch {

            // Si el JWT se obtuvo pero no podemos
            // construir una sesión válida, lo eliminamos.
            keychain.deleteAccessToken()

            throw error
        }
    }


    // MARK: - Restore Session

    func restoreSessionIfPossible() async {
        // Esta comprobación solamente debe hacerse
        // una vez durante este arranque de la app.
        guard !didAttemptSessionRestore
        else {

            return
        }


        didAttemptSessionRestore =
            true

        isRestoringSession =
            true


        defer {

            isRestoringSession =
                false
        }


        // Primero comprobamos si realmente existe
        // un JWT guardado en Keychain.
        // Primero comprobamos si realmente existe
        // un JWT guardado en Keychain.
        let storedToken: String?

        do {

            storedToken =
                try keychain.readAccessToken()

        } catch {

            // Si ni siquiera podemos leer correctamente
            // el Keychain, no conservamos una sesión dudosa.
            invalidateSession()

            return
        }


        guard storedToken != nil
        else {

            // No existe una sesión anterior.
            return
        }

        // BiometricSettings guarda el customerId
        // únicamente cuando el usuario habilitó biometría.
        //
        // Por ahora usamos ese customerId para reconstruir
        // una sesión biométrica existente.
        guard biometricSettings.isEnabled,
              let customerId = biometricSettings.customerId
        else {

            // Existe un token, pero no tenemos todavía
            // una identidad persistida apropiada para
            // reconstruir automáticamente la sesión.
            //
            // No borramos el JWT aquí porque puede seguir
            // siendo válido; simplemente mostramos Login.
            return
        }


let biometricService =
            BiometricAuthService()


        // Antes de utilizar la sesión almacenada,
        // comprobamos la identidad del propietario
        // del dispositivo mediante Face ID / Touch ID.
        let authenticated =
            await biometricService.authenticate()


        guard authenticated
        else {

            // Cancelar o fallar Face ID no destruye
            // automáticamente la sesión almacenada.
            // Simplemente dejamos al usuario en Login.
            return
        }


        do {

            // Esta llamada tiene dos propósitos:
            //
            // 1. comprobar que el JWT sigue siendo aceptado;
            // 2. reconstruir currentCustomer con datos reales.
            //
            // APIClient añadirá el Bearer token
            // almacenado en Keychain.
            let customer =
                try await BankingAPIService
                    .shared
                    .fetchCustomer(
                        id:
                            customerId
                    )


            currentCustomer =
                customer

        } catch APIError.unauthorized {

            // El servidor rechazó el JWT:
            // pudo expirar o dejar de ser válido.
            invalidateSession()

        } catch APIError.authenticationRequired {

            // No existe una credencial utilizable.
            invalidateSession()

        } catch {

            // Un error temporal de red NO debería borrar
            // una credencial potencialmente válida.
            //
            // Dejamos al usuario en Login para que pueda
            // volver a intentarlo posteriormente.
            currentCustomer =
                nil
        }
    }


    // MARK: - Logout

    func logout() {

        // Logout explícito significa que el usuario
        // ya no quiere conservar esa sesión.
        keychain.deleteAccessToken()

        currentCustomer =
            nil
    }


    // MARK: - Expired / Invalid Session

    func invalidateSession() {

        keychain.deleteAccessToken()

        currentCustomer =
            nil
    }
}
