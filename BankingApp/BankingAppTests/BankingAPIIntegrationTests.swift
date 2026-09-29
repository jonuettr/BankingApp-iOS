//
//  BankingAPIIntegrationTests.swift
//  BankingAppTests
//
//  Pruebas de integración entre la aplicación iOS
//  y nuestra API REST construida con Spring Boot.
//
//  Estas pruebas utilizan autenticación REAL:
//
//  credenciales
//      ↓
//  POST /api/auth/login
//      ↓
//  JWT
//      ↓
//  Keychain
//      ↓
//  endpoints protegidos
//

import Foundation
import Testing

@testable import BankingApp


// MARK: - Banking API Integration Tests

@MainActor
@Suite("Banking API Integration Tests", .serialized)
struct BankingAPIIntegrationTests {

    // Credenciales exclusivas de nuestro entorno demo.
    //
    // IMPORTANTE:
    // estas NO son credenciales de producción.
    private let demoEmail =
        "alex.rivera@bankingapp.test"

    private let demoPassword =
        "BankingDemo2026!"


    // MARK: - Authentication Helper

    // Cada prueba obtiene un JWT real del backend.
    //
    // Después guardamos ese token en Keychain porque
    // APIClient lo recupera automáticamente para construir:
    //
    // Authorization: Bearer <JWT>
    private func authenticate() async throws {

        let response =
            try await AuthAPIService.shared.login(
                email: demoEmail,
                password: demoPassword
            )

        try KeychainService.shared.saveAccessToken(
            response.accessToken
        )
    }


    // MARK: - Cleanup

    // Eliminamos el JWT después de cada prueba.
    //
    // De esta manera una prueba no depende del estado
    // dejado por otra.
    private func removeAuthentication() {

        KeychainService.shared.deleteAccessToken()
    }


    // MARK: - Customer

    @Test("Login and fetch customer from protected REST API")
    func fetchCustomer() async throws {

        try await authenticate()

        defer {
            removeAuthentication()
        }

        let service =
            BankingAPIService.shared

        let customer =
            try await service.fetchCustomer(
                id: 1
            )

        #expect(customer.id == 1)
        #expect(customer.firstName == "Alex")
        #expect(customer.lastName == "Rivera")

        #expect(
            customer.email ==
                "alex.rivera@bankingapp.test"
        )
    }


    // MARK: - Accounts

    @Test("Login and fetch protected customer accounts")
    func fetchAccounts() async throws {

        try await authenticate()

        defer {
            removeAuthentication()
        }

        let service =
            BankingAPIService.shared

        let accounts =
            try await service.fetchAccounts(
                customerId: 1
            )

        #expect(accounts.count == 2)

        #expect(
            accounts.contains {
                $0.id == 101
            }
        )

        #expect(
            accounts.contains {
                $0.id == 102
            }
        )

        let checkingAccount =
            accounts.first {
                $0.id == 101
            }

        #expect(
            checkingAccount?.isActive == true
        )
    }


    // MARK: - Credit Cards

    @Test("Login and fetch protected credit cards")
    func fetchCreditCards() async throws {

        try await authenticate()

        defer {
            removeAuthentication()
        }

        let service =
            BankingAPIService.shared

        let cards =
            try await service.fetchCreditCards(
                customerId: 1
            )

        #expect(
            cards.contains {
                $0.id == 501
            }
        )
    }


    // MARK: - Transactions

    @Test("Login and fetch protected transaction history")
    func fetchTransactions() async throws {

        try await authenticate()

        defer {
            removeAuthentication()
        }

        let service =
            BankingAPIService.shared

        let transactions =
            try await service.fetchTransactions(
                customerId: 1
            )

        #expect(
            transactions.isEmpty == false
        )

        #expect(
            transactions.contains {
                $0.accountId != nil
            }
        )

        #expect(
            transactions.contains {
                $0.creditCardId != nil
            }
        )
    }
}
