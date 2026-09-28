//
//  TransactionsViewModel.swift
//  BankingApp
//
//  ViewModel encargado de preparar, buscar y filtrar
//  los movimientos mostrados en TransactionsView.
//

import Foundation
import Observation


// MARK: - Transaction Filter

// Este enum representa los filtros principales
// disponibles en la pantalla de movimientos.
//
// "all"     → todos los movimientos.
// "income"  → solamente entradas de dinero.
// "expenses" → solamente salidas de dinero.
enum TransactionFilter: String, CaseIterable, Identifiable {

    case all = "Todos"
    case income = "Ingresos"
    case expenses = "Gastos"

    // Identifiable requiere un id.
    //
    // Como cada rawValue es diferente, podemos utilizarlo
    // como identificador.
    var id: String {
        rawValue
    }
}


// MARK: - Transactions View Model

@Observable
final class TransactionsViewModel {

    private let customerId: Int

    // MARK: - Properties

    // Todos los movimientos pertenecientes al cliente.
    private(set) var transactions: [Transaction] = []

    // Texto introducido por el usuario en el buscador.
    //
    // Esta propiedad sí puede modificarse desde la vista.
    var searchText: String = ""

    // Filtro seleccionado actualmente.
    var selectedFilter: TransactionFilter = .all


    // MARK: - Initialization

    init(customerId: Int) {

        self.customerId = customerId

        loadTransactions(customerId: customerId)
    }


    // MARK: - Filtered Transactions

    // Esta propiedad combina:
    //
    // 1. búsqueda por texto
    // 2. filtro de ingresos/gastos
    // 3. orden por fecha
    //
    // TransactionsView solamente tendrá que pedir:
    //
    // viewModel.filteredTransactions
    var filteredTransactions: [Transaction] {

        transactions

            // PRIMER FILTRO:
            // Ingresos, gastos o todos.
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

            // SEGUNDO FILTRO:
            // Búsqueda por descripción, comercio
            // o referencia.
            .filter { transaction in

                // Si el buscador está vacío,
                // mostramos el movimiento.
                guard !searchText.isEmpty else {
                    return true
                }

                // Buscamos dentro de la descripción.
                let matchesDescription =
                    transaction.description.localizedCaseInsensitiveContains(
                        searchText
                    )

                let matchesMerchant =
                    transaction.merchant?
                        .localizedCaseInsensitiveContains(searchText)
                    ?? false

                let matchesReference =
                    transaction.reference?
                        .localizedCaseInsensitiveContains(searchText)
                    ?? false

                return matchesDescription ||
                       matchesMerchant ||
                       matchesReference
            }

            // Finalmente ordenamos de más reciente
            // a más antiguo.
            .sorted { firstTransaction, secondTransaction in

                firstTransaction.date > secondTransaction.date
            }
    }


    // MARK: - Summary

    // Total de entradas de dinero.
    var totalIncome: Decimal {

        transactions
            .filter { transaction in
                isIncome(transaction)
            }
            .reduce(Decimal.zero) { result, transaction in
                result + transaction.amount
            }
    }

    // Total de salidas.
    var totalExpenses: Decimal {

        transactions
            .filter { transaction in
                !isIncome(transaction)
            }
            .reduce(Decimal.zero) { result, transaction in
                result + transaction.amount
            }
    }

    // MARK: - Refresh

    // Recarga el historial desde BankingService.
    // Esto permite detectar movimientos creados después
    // de inicializar este ViewModel.
    func refresh() {

        loadTransactions(customerId: customerId)
    }

    // MARK: - Load Transactions

    private func loadTransactions(customerId: Int) {

        // Obtenemos las cuentas del cliente.
        let accountIds = Set(
            BankingService.shared.accounts
                .filter { account in
                    account.customerId == customerId
                }
                .map { account in
                    account.id
                }
        )

        // Obtenemos sus tarjetas.
        let creditCardIds = Set(
            MockData.creditCards
                .filter { card in
                    card.customerId == customerId
                }
                .map { card in
                    card.id
                }
        )

        // Conservamos los movimientos que pertenezcan
        // a cualquiera de esos productos.
        transactions = BankingService.shared.transactions.filter { transaction in

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


    // MARK: - Income / Expense

    // Centralizamos aquí la regla que determina
    // si un movimiento representa entrada de dinero.
    //
    // Esto evita repetir la condición muchas veces.
    func isIncome(_ transaction: Transaction) -> Bool {

        transaction.type == .deposit ||
        transaction.type == .transferIn
    }
}
