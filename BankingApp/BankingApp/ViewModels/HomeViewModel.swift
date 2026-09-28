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

    // MARK: - Load Transactions

    private func loadTransactions() {

        // Primero obtenemos los IDs de todas las cuentas
        // pertenecientes al cliente.
        let accountIds = Set(
            accounts.map { account in
                account.id
            }
        )

        // También obtenemos los IDs de todas las tarjetas
        // de crédito pertenecientes al cliente.
        let creditCardIds = Set(
            creditCards.map { card in
                card.id
            }
        )

        // Ahora recorremos todas las transacciones disponibles
        // y conservamos solamente aquellas que pertenecen
        // a alguno de los productos financieros del cliente.
        transactions = MockData.transactions.filter { transaction in

            // PRIMERA POSIBILIDAD:
            // La transacción pertenece a una cuenta bancaria.
            //
            // Como accountId ahora es Int?, primero usamos
            // "if let" para comprobar que contiene un valor.
            if let accountId = transaction.accountId,
               accountIds.contains(accountId) {

                return true
            }

            // SEGUNDA POSIBILIDAD:
            // La transacción pertenece a una tarjeta de crédito.
            //
            // Si creditCardId contiene un valor y ese ID
            // pertenece al cliente, también conservamos
            // la transacción.
            if let creditCardId = transaction.creditCardId,
               creditCardIds.contains(creditCardId) {

                return true
            }

            // Si la transacción no pertenece ni a una cuenta
            // ni a una tarjeta del cliente, la descartamos.
            return false
        }
    }
}
