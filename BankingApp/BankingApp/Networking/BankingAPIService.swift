//
//  BankingAPIService.swift
//  BankingApp
//
//  Servicio que conoce los endpoints específicos
//  de nuestra API bancaria.


import Foundation


// MARK: - Banking API Service

actor BankingAPIService {


    // MARK: Shared Instance

    static let shared = BankingAPIService()


    // MARK: Dependencies

    private let apiClient: APIClient


    // MARK: Initialization

    private init(
        apiClient: APIClient = .shared
    ) {

        self.apiClient = apiClient
    }


    // MARK: - Customer

    func fetchCustomer(
        id: Int
    ) async throws -> Customer {

        let dto: CustomerDTO =
            try await apiClient.get(
                path: "/api/customers/\(id)",
                as: CustomerDTO.self
            )

        return dto.toDomain()
    }


    // MARK: - Accounts

    func fetchAccounts(
        customerId: Int
    ) async throws -> [Account] {

        let dtos: [AccountDTO] =
            try await apiClient.get(
                path:
                    "/api/customers/\(customerId)/accounts",
                as: [AccountDTO].self
            )

        return dtos.map { dto in

            dto.toDomain()
        }
    }


    // MARK: - Credit Cards

    func fetchCreditCards(
        customerId: Int
    ) async throws -> [CreditCard] {

        let dtos: [CreditCardDTO] =
            try await apiClient.get(
                path:
                    "/api/customers/\(customerId)/credit-cards",
                as: [CreditCardDTO].self
            )

        return dtos.map { dto in

            dto.toDomain()
        }
    }


    // MARK: - Transactions

    func fetchTransactions(
        customerId: Int
    ) async throws -> [Transaction] {

        let dtos: [TransactionDTO] =
            try await apiClient.get(
                path:
                    "/api/customers/\(customerId)/transactions",
                as: [TransactionDTO].self
            )

        return try dtos.map { dto in

            try dto.toDomain()
        }
    }
}
