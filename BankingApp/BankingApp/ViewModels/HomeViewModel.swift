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

        // Ya no leemos las cuentas directamente desde MockData.
        //
        // BankingService.shared contiene el estado actual
        // de la sesión, incluyendo los cambios producidos
        // por las transferencias.
        accounts = BankingService.shared.accounts.filter { account in

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

        let accountIds = Set(
            accounts.map { account in
                account.id
            }
        )

        let creditCardIds = Set(
            creditCards.map { card in
                card.id
            }
        )

        // CAMBIO IMPORTANTE:
        //
        // Los movimientos ahora proceden de BankingService.
        //
        // Por tanto, si Transferir acaba de crear un nuevo
        // movimiento, aquí podremos encontrarlo.
        transactions =
            BankingService.shared.transactions.filter { transaction in

                if let accountId = transaction.accountId,
                   accountIds.contains(accountId) {

                    return true
                }

                if let creditCardId = transaction.creditCardId,
                   creditCardIds.contains(creditCardId) {

                    return true
                }

                return false
            }
    }
 
    // MARK: - Refresh

    // Vuelve a consultar el estado actual del servicio.
    //
    // La vista podrá llamar esta función cuando aparezca
    // nuevamente en pantalla.
    func refresh() {

        guard let customer else {
            return
        }

        loadAccounts(customerId: customer.id)
        loadCreditCards(customerId: customer.id)
        loadTransactions()
    }
}
