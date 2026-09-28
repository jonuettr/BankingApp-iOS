//
//  HomeViewModel.swift
//  BankingApp
//
//  ViewModel encargado de preparar la información
//  necesaria para HomeView.
//
//  Dentro de MVVM:
//
//  Model     → Customer, Account, Transaction, etc.
//  View      → HomeView
//  ViewModel → HomeViewModel
//

import Foundation
import Observation


// MARK: - Home View Model

@Observable
final class HomeViewModel {


    // MARK: - Dependencies

    // Identificador del cliente cuya información
    // debe mostrar esta pantalla.
    private let customerId: Int


    // BankingService es la fuente central de datos.
    //
    // IMPORTANTE:
    //
    // Ya no vamos a COPIAR sus datos a propiedades
    // almacenadas dentro de HomeViewModel.
    //
    // HomeViewModel los consultará directamente.
    private let bankingService =
        BankingService.shared


    // MARK: - Initialization

    init(customerId: Int) {

        self.customerId = customerId
    }


    // MARK: - Customer

    // Esta es una propiedad calculada.
    //
    // No almacena una segunda copia del cliente.
    // Cada vez que alguien consulta "customer",
    // leemos el estado actual de BankingService.
    var customer: Customer? {

        guard let customer =
            bankingService.customer,
              customer.id == customerId
        else {

            return nil
        }

        return customer
    }


    // MARK: - Accounts

    // Igual que customer, esta propiedad siempre
    // consulta el estado actual de BankingService.
    //
    // Por eso, si la API cambia un saldo:
    //
    // MySQL
    //   ↓
    // Spring Boot
    //   ↓
    // BankingService
    //   ↓
    // accounts
    //
    // Home ya no conserva una copia vieja.
    var accounts: [Account] {

        bankingService.accounts
            .filter { account in

                account.customerId == customerId &&
                account.isActive
            }
    }


    // MARK: - Credit Cards

    var creditCards: [CreditCard] {

        bankingService.creditCards
            .filter { card in

                card.customerId == customerId &&
                card.isActive
            }
    }


    // MARK: - Transactions

    var transactions: [Transaction] {

        // Primero obtenemos los productos actuales
        // pertenecientes al cliente.
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


        // Después conservamos únicamente movimientos
        // asociados con esos productos.
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


    // MARK: - Total Balance

    var totalBalance: Decimal {

        accounts.reduce(Decimal.zero) {
            partialResult,
            account in

            partialResult + account.balance
        }
    }


    // MARK: - Recent Transactions

    var recentTransactions: [Transaction] {

        transactions.sorted {
            firstTransaction,
            secondTransaction in

            firstTransaction.date >
                secondTransaction.date
        }
    }


    // MARK: - Refresh

    // HomeView actualmente llama refresh()
    // cuando aparece.
    //
    // Ya no necesitamos copiar nada aquí porque todas
    // las propiedades anteriores leen directamente
    // BankingService.
    //
    // Conservamos temporalmente este método para no
    // romper la interfaz actual de HomeView.
    func refresh() {

        // Intencionalmente vacío.
    }
}
