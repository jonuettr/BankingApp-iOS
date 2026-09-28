//
//  AnalysisViewModel.swift
//  BankingApp
//
//  Prepara la información financiera utilizada
//  por la pantalla de análisis.
//

import Foundation
import Observation


// MARK: - Category Summary

// Representa el total gastado en una categoría.
struct CategorySummary: Identifiable {

    var id: TransactionCategory {
        category
    }

    let category: TransactionCategory

    let amount: Decimal
}


// MARK: - Analysis View Model

@Observable
final class AnalysisViewModel {


    // MARK: - Customer

    private let customerId: Int


    // MARK: - Data

    private(set) var transactions: [Transaction] = []


    // MARK: - Initialization

    init(customerId: Int) {

        self.customerId = customerId

        loadTransactions()
    }


    // MARK: - Income

    // Aquí contamos únicamente ingresos financieros reales.
    var totalIncome: Decimal {

        transactions
            .filter { transaction in

                transaction.type == .deposit
            }
            .reduce(Decimal.zero) { result, transaction in

                result + transaction.amount
            }
    }


    // MARK: - Expenses

    var totalExpenses: Decimal {

        expenseTransactions.reduce(
            Decimal.zero
        ) { result, transaction in

            result + transaction.amount
        }
    }


    // MARK: - Net Cash Flow

    // Diferencia entre ingresos y gastos
    // considerados por nuestro análisis.
    var netCashFlow: Decimal {

        totalIncome - totalExpenses
    }


    // MARK: - Expense Transactions

    // Centralizamos la definición de "gasto"
    // para no repetir la regla en diferentes cálculos.
    private var expenseTransactions: [Transaction] {

        transactions.filter { transaction in

            transaction.type == .purchase ||
            transaction.type == .directDebit
        }
    }


    // MARK: - Expenses By Category

    var expensesByCategory: [CategorySummary] {

        // Dictionary(grouping:) agrupa los movimientos
        // que comparten una misma categoría.
        let groupedTransactions =
            Dictionary(
                grouping: expenseTransactions
            ) { transaction in

                transaction.category
            }


        // Convertimos cada grupo en CategorySummary.
        let summaries =
            groupedTransactions.map {
                category,
                transactions in

                let total =
                    transactions.reduce(
                        Decimal.zero
                    ) { result, transaction in

                        result + transaction.amount
                    }

                return CategorySummary(
                    category: category,
                    amount: total
                )
            }


        // Mostramos primero las categorías
        // con mayor gasto.
        return summaries.sorted {
            first,
            second in

            first.amount > second.amount
        }
    }


    // MARK: - Expense Percentage

    // Calcula qué porcentaje del gasto total
    // corresponde a una categoría.
    func expensePercentage(
        for amount: Decimal
    ) -> Decimal {

        guard totalExpenses > 0 else {
            return 0
        }

        return amount / totalExpenses
    }


    // MARK: - Refresh

    func refresh() {

        loadTransactions()
    }


    // MARK: - Load Transactions

    private func loadTransactions() {

        // Obtenemos las cuentas actuales del cliente
        // desde BankingService.
        let accountIds = Set(
            BankingService.shared.accounts
                .filter { account in

                    account.customerId == customerId
                }
                .map { account in

                    account.id
                }
        )


        // Las tarjetas todavía proceden de MockData.
        let creditCardIds = Set(
            MockData.creditCards
                .filter { card in

                    card.customerId == customerId
                }
                .map { card in

                    card.id
                }
        )


        // Seleccionamos todos los movimientos
        // pertenecientes a esos productos.
        transactions =
            BankingService.shared.transactions.filter {
                transaction in

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


    // MARK: - Category Name

    // Traducimos nuestros valores internos
    // a nombres apropiados para la interfaz.
    func categoryName(
        _ category: TransactionCategory
    ) -> String {

        switch category {

        case .income:
            return "Ingresos"

        case .food:
            return "Alimentos"

        case .transportation:
            return "Transporte"

        case .entertainment:
            return "Entretenimiento"

        case .shopping:
            return "Compras"

        case .services:
            return "Servicios"

        case .health:
            return "Salud"

        case .transfers:
            return "Transferencias"

        case .financial:
            return "Financiero"

        case .other:
            return "Otros"
        }
    }
}
