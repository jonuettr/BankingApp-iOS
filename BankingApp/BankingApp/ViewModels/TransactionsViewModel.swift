//
//  TransactionsViewModel.swift
//  BankingApp
//
//  Prepara, busca y filtra los movimientos
//  mostrados en TransactionsView.
//

import Foundation
import Observation


// MARK: - Transaction Filter

enum TransactionFilter: String, CaseIterable, Identifiable {

    case all = "Todos"
    case income = "Ingresos"
    case expenses = "Gastos"

    var id: String {
        rawValue
    }
}


// MARK: - Transactions View Model

@Observable
final class TransactionsViewModel {


    // MARK: - Dependencies

    private let customerId: Int

    // Fuente central de información bancaria.
    //
    // Los datos que contiene son sustituidos por
    // los recibidos desde Spring Boot.
    private let bankingService =
        BankingService.shared


    // MARK: - User Interface State

    // Estos dos valores sí pertenecen al ViewModel
    // porque representan decisiones de la interfaz.
    var searchText: String = ""

    var selectedFilter: TransactionFilter = .all


    // MARK: - Initialization

    init(customerId: Int) {

        self.customerId = customerId
    }


    // MARK: - Transactions

    // Ya NO guardamos una copia local de transactions.
    //
    // Cada vez que SwiftUI consulta esta propiedad,
    // usamos el estado actual de BankingService.
    var transactions: [Transaction] {

        // Cuentas activas pertenecientes al cliente.
        let accountIds = Set(
            bankingService.accounts
                .filter { account in

                    account.customerId == customerId &&
                    account.isActive
                }
                .map { account in
                    account.id
                }
        )


        // Tarjetas activas pertenecientes al cliente.
        //
        // IMPORTANTE:
        // antes esta información venía de MockData.
        // Ahora proviene de BankingService y, por tanto,
        // de nuestra REST API.
        let creditCardIds = Set(
            bankingService.creditCards
                .filter { card in

                    card.customerId == customerId &&
                    card.isActive
                }
                .map { card in
                    card.id
                }
        )


        // Conservamos únicamente movimientos asociados
        // con los productos del cliente.
        return bankingService.transactions
            .filter { transaction in

                if let accountId =
                    transaction.accountId,
                   accountIds.contains(accountId) {

                    return true
                }

                if let creditCardId =
                    transaction.creditCardId,
                   creditCardIds.contains(creditCardId) {

                    return true
                }

                return false
            }
    }


    // MARK: - Filtered Transactions

    var filteredTransactions: [Transaction] {

        transactions

            // Primero aplicamos el filtro seleccionado.
            .filter { transaction in

                switch selectedFilter {

                case .all:
                    return true

                case .income:
                    return isIncome(transaction)

                case .expenses:
                    return !isIncome(transaction)
                }
            }

            // Después aplicamos la búsqueda.
            .filter { transaction in

                guard !searchText.isEmpty else {
                    return true
                }

                let matchesDescription =
                    transaction.description
                        .localizedCaseInsensitiveContains(
                            searchText
                        )

                let matchesMerchant =
                    transaction.merchant?
                        .localizedCaseInsensitiveContains(
                            searchText
                        )
                    ?? false

                let matchesReference =
                    transaction.reference?
                        .localizedCaseInsensitiveContains(
                            searchText
                        )
                    ?? false

                return matchesDescription ||
                       matchesMerchant ||
                       matchesReference
            }

            // Finalmente mostramos primero
            // los movimientos más recientes.
            .sorted { firstTransaction, secondTransaction in

                firstTransaction.date >
                    secondTransaction.date
            }
    }


    // MARK: - Summary

    var totalIncome: Decimal {

        transactions
            .filter { transaction in
                isIncome(transaction)
            }
            .reduce(Decimal.zero) {
                result,
                transaction in

                result + transaction.amount
            }
    }


    var totalExpenses: Decimal {

        transactions
            .filter { transaction in
                !isIncome(transaction)
            }
            .reduce(Decimal.zero) {
                result,
                transaction in

                result + transaction.amount
            }
    }


    // MARK: - Refresh

    // Se conserva porque TransactionsView actualmente
    // llama refresh() cuando aparece.
    //
    // Ya no necesitamos copiar datos manualmente.
    func refresh() {
        // Intencionalmente vacío.
    }


    // MARK: - Income / Expense

    func isIncome(
        _ transaction: Transaction
    ) -> Bool {

        transaction.type == .deposit ||
        transaction.type == .transferIn
    }
}
