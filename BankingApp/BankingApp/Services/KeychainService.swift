//
//  KeychainService.swift
//  BankingApp
//
//  Guarda información sensible utilizando
//  el Keychain de Apple.

import Foundation
import Security


// MARK: - Keychain Error

enum KeychainError: Error {

    case unableToSave(OSStatus)

    case unableToRead(OSStatus)

    case invalidData
}


// MARK: - Keychain Service

nonisolated final class KeychainService: Sendable {

    // MARK: Shared Instance

    static let shared =
        KeychainService()


    // MARK: Configuration

    private let service =
        "com.jonuettr.BankingApp"

    private let accessTokenAccount =
        "accessToken"


    // MARK: Initialization

    private init() {}


    // MARK: - Save Access Token

    func saveAccessToken(
        _ token: String
    ) throws {

        guard let data =
                token.data(
                    using: .utf8
                )
        else {

            throw KeychainError.invalidData
        }


        // Primero eliminamos cualquier token anterior.
        // Así evitamos duplicados en Keychain.
        deleteAccessToken()


        let query: [String: Any] = [

            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                service,

            kSecAttrAccount as String:
                accessTokenAccount,

            kSecValueData as String:
                data,

            // El token solamente estará disponible
            // después de desbloquear el dispositivo.
            kSecAttrAccessible as String:
                kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]


        let status =
            SecItemAdd(
                query as CFDictionary,
                nil
            )


        guard status == errSecSuccess
        else {

            throw KeychainError
                .unableToSave(status)
        }
    }


    // MARK: - Read Access Token

    func readAccessToken() throws -> String? {

        let query: [String: Any] = [

            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                service,

            kSecAttrAccount as String:
                accessTokenAccount,

            kSecReturnData as String:
                true,

            kSecMatchLimit as String:
                kSecMatchLimitOne
        ]


        var result: AnyObject?


        let status =
            SecItemCopyMatching(
                query as CFDictionary,
                &result
            )


        // No tener token no es un error.
        // Simplemente significa que no existe
        // una sesión guardada.
        if status == errSecItemNotFound {

            return nil
        }


        guard status == errSecSuccess
        else {

            throw KeychainError
                .unableToRead(status)
        }


        guard
            let data = result as? Data,
            let token = String(
                data: data,
                encoding: .utf8
            )
        else {

            throw KeychainError.invalidData
        }


        return token
    }


    // MARK: - Delete Access Token

    func deleteAccessToken() {

        let query: [String: Any] = [

            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                service,

            kSecAttrAccount as String:
                accessTokenAccount
        ]


        SecItemDelete(
            query as CFDictionary
        )
    }
}
