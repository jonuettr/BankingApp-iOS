//
//  HomeViewModel.swift
//  BankingApp
//
//  ViewModel encargado de preparar la información
//  necesaria para HomeView.
//
//  Dentro del patrón MVVM:
//
//  Model     → Customer, Account, Transaction, etc.
//  View      → HomeView
//  ViewModel → HomeViewModel
//

import Foundation


// MARK: - Home View Model

// @Observable permite que SwiftUI observe los cambios
// realizados en este objeto.

@Observable
final class HomeViewModel {


    // MARK: - Properties

    // Cliente que actualmente inició sesión.
    //
    // Por ahora lo obtenemos desde MockData.
    // Posteriormente llegará desde nuestro sistema
    // de autenticación.
    private(set) var customer: Customer?

    // Cuentas pertenecientes al cliente.
    private(set) var accounts: [Account] = []

    // Tarjetas de crédito del cliente.
    private(set) var creditCards: [CreditCard] = []

    // Movimientos pertenecientes a sus cuentas.
    private(set) var transactions: [Transaction] = []


    // MARK: - Initialization

    // init se ejecuta cuando creamos una instancia
    // de HomeViewModel.

    init(customerId: Int) {

        loadCustomer(customerId: customerId)
        loadAccounts(customerId: customerId)
        loadCreditCards(customerId: customerId)
        loadTransactions()
    }


    // MARK: - Total Balance

    // La vista puede solicitar:
    //
    // viewModel.totalBalance
    //
    // sin tener que saber cómo se calcula.
    var totalBalance: Decimal {

        accounts.reduce(Decimal.zero) { partialResult, account in

            partialResult + account.balance
        }
    }


    // MARK: - Recent Transactions


    var recentTransactions: [Transaction] {

        transactions.sorted { firstTransaction, secondTransaction in

            firstTransaction.date > secondTransaction.date
        }
    }


    // MARK: - Load Customer

    private func loadCustomer(customerId: Int) {

        customer = MockData.customers.first { customer in

            customer.id == customerId
        }
    }


    // MARK: - Load Accounts

    private func loadAccounts(customerId: Int) {

        accounts = MockData.accounts.filter { account in

            account.customerId == customerId
        }
    }


    // MARK: - Load Credit Cards

    private func loadCreditCards(customerId: Int) {

        creditCards = MockData.creditCards.filter { card in

            card.customerId == customerId
        }
    }


    // MARK: - Load Transactions

    private func loadTransactions() {

        // Set representa una colección de valores únicos.

        let accountIds = Set(
            accounts.map { account in
                account.id
            }
        )

        // Después conservamos únicamente las transacciones
        // cuya cuenta pertenece al cliente.
        transactions = MockData.transactions.filter { transaction in

            accountIds.contains(transaction.accountId)
        }
    }
}
