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


    // MARK: - Dependencies

    private let customerId: Int

    private let bankingService =
        BankingService.shared


    // MARK: - Initialization

    init(customerId: Int) {

        self.customerId = customerId
    }


    // MARK: - Transactions

    // No almacenamos otra copia del historial.
    //
    // Siempre trabajamos con el estado actual
    // recibido por BankingService.
    private var transactions: [Transaction] {

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


    // MARK: - Income

    // Conservamos la misma regla financiera que
    // ya utilizaba esta pantalla:
    //
    // únicamente "deposit" cuenta como ingreso
    // para el análisis financiero.
    var totalIncome: Decimal {

        transactions
            .filter { transaction in

                transaction.type == .deposit
            }
            .reduce(Decimal.zero) {
                result,
                transaction in

                result + transaction.amount
            }
    }


    // MARK: - Expenses

    var totalExpenses: Decimal {

        expenseTransactions.reduce(
            Decimal.zero
        ) {
            result,
            transaction in

            result + transaction.amount
        }
    }


    // MARK: - Net Cash Flow

    var netCashFlow: Decimal {

        totalIncome - totalExpenses
    }


    // MARK: - Expense Transactions

    // Para análisis financiero solamente consideramos
    // compras y cargos domiciliados como gasto.
    //
    // Las transferencias y pagos de tarjeta no se
    // contabilizan aquí como consumo.
    private var expenseTransactions: [Transaction] {

        transactions.filter { transaction in

            transaction.type == .purchase ||
            transaction.type == .directDebit
        }
    }


    // MARK: - Expenses By Category

    var expensesByCategory: [CategorySummary] {

        let groupedTransactions =
            Dictionary(
                grouping: expenseTransactions
            ) { transaction in

                transaction.category
            }


        let summaries =
            groupedTransactions.map {
                category,
                transactions in

                let total =
                    transactions.reduce(
                        Decimal.zero
                    ) {
                        result,
                        transaction in

                        result + transaction.amount
                    }

                return CategorySummary(
                    category: category,
                    amount: total
                )
            }


        return summaries.sorted {
            first,
            second in

            first.amount > second.amount
        }
    }


    // MARK: - Expense Percentage

    func expensePercentage(
        for amount: Decimal
    ) -> Decimal {

        guard totalExpenses > 0 else {
            return 0
        }

        return amount / totalExpenses
    }


    // MARK: - Refresh

    // Se conserva para mantener compatible AnalysisView.
    //
    // Como los cálculos ahora consultan directamente
    // BankingService, no necesitamos recargar una copia.
    func refresh() {
        // Intencionalmente vacío.
    }


    // MARK: - Category Name

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
