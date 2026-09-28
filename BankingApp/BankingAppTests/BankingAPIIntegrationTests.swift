//
//  BankingAPIIntegrationTests.swift
//  BankingAppTests
//
//  Pruebas de integración entre la aplicación iOS
//  y nuestra API REST construida con Spring Boot.
//

import Foundation
import Testing

@testable import BankingApp


// MARK: - Banking API Integration Tests

@MainActor
@Suite("Banking API Integration Tests", .serialized)
struct BankingAPIIntegrationTests {


    // MARK: - Customer

    @Test("Fetch customer from REST API")
    func fetchCustomer() async throws {

        let service = BankingAPIService.shared

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

    @Test("Fetch customer accounts from REST API")
    func fetchAccounts() async throws {

        let service = BankingAPIService.shared

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

    @Test("Fetch credit cards from REST API")
    func fetchCreditCards() async throws {

        let service = BankingAPIService.shared

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

    @Test("Fetch transaction history from REST API")
    func fetchTransactions() async throws {

        let service = BankingAPIService.shared

        let transactions =
            try await service.fetchTransactions(
                customerId: 1
            )

        #expect(transactions.isEmpty == false)


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
