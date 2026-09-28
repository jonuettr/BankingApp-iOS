//
//  HomeView.swift
//  BankingApp
//
//  Pantalla principal de la banca digital.


import SwiftUI

struct HomeView: View {

    // MARK: - View Model

    @State private var viewModel = HomeViewModel(customerId: 1)
    
    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 24) {


                    // MARK: Greeting

                    if let customer = viewModel.customer {

                        VStack(alignment: .leading, spacing: 4) {

                            Text("Hola,")
                                .font(.title3)
                                .foregroundStyle(.secondary)

                            Text(customer.firstName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                    }


                    // MARK: Total Balance

                    VStack(alignment: .leading, spacing: 8) {

                        Text("Saldo total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(
                            viewModel.totalBalance,
                            format: .currency(code: "MXN")
                        )
                        .font(.system(size: 34, weight: .bold))
                    }


                    // MARK: Accounts

                    VStack(alignment: .leading, spacing: 12) {

                        Text("Mis cuentas")
                            .font(.headline)

                        ForEach(viewModel.accounts) { account in

                            HStack {

                                VStack(alignment: .leading, spacing: 4) {

                                    Text(account.name)
                                        .fontWeight(.semibold)

                                    Text("•••• \(account.lastFourDigits)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(
                                    account.balance,
                                    format: .currency(code: account.currency)
                                )
                                .fontWeight(.semibold)
                            }
                            .padding()
                            .background(
                                Color(.secondarySystemBackground)
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                        }
                    }


                    // MARK: Credit Cards

                    VStack(alignment: .leading, spacing: 12) {

                        Text("Tarjetas")
                            .font(.headline)

                        ForEach(viewModel.creditCards) { card in

                            VStack(alignment: .leading, spacing: 12) {

                                HStack {

                                    VStack(alignment: .leading, spacing: 4) {

                                        Text(card.name)
                                            .fontWeight(.semibold)

                                        Text("•••• \(card.lastFourDigits)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "creditcard.fill")
                                        .font(.title2)
                                }

                                Divider()

                                HStack {

                                    VStack(alignment: .leading, spacing: 4) {

                                        Text("Saldo utilizado")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)

                                        Text(
                                            card.currentBalance,
                                            format: .currency(code: "MXN")
                                        )
                                        .fontWeight(.semibold)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 4) {

                                        Text("Disponible")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)

                                        Text(
                                            card.availableCredit,
                                            format: .currency(code: "MXN")
                                        )
                                        .fontWeight(.semibold)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                Color(.secondarySystemBackground)
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                        }
                    }


                    // MARK: Recent Transactions

                    VStack(alignment: .leading, spacing: 12) {

                        Text("Movimientos recientes")
                            .font(.headline)

                        ForEach(viewModel.recentTransactions) { transaction in

                            HStack(spacing: 12) {

                                Image(
                                    systemName: transactionIcon(
                                        for: transaction
                                    )
                                )
                                .frame(width: 36, height: 36)
                                .background(
                                    Color(.secondarySystemBackground)
                                )
                                .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 3) {

                                    Text(transaction.description)
                                        .fontWeight(.medium)

                                    Text(
                                        transaction.date,
                                        format: .dateTime
                                            .day()
                                            .month(.abbreviated)
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(
                                    transactionAmountText(transaction)
                                )
                                .fontWeight(.semibold)
                            }

                            Divider()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Inicio")
        }
    }


    // MARK: - Transaction Icon

    // Elegimos un SF Symbol dependiendo del tipo
    // de movimiento.
    private func transactionIcon(
        for transaction: Transaction
    ) -> String {

        switch transaction.type {

        case .deposit:
            return "arrow.down.circle.fill"

        case .transferIn:
            return "arrow.down.left.circle.fill"

        case .transferOut:
            return "arrow.up.right.circle.fill"

        case .purchase:
            return "cart.fill"

        case .directDebit:
            return "doc.text.fill"

        case .creditCardPayment:
            return "creditcard.fill"
        }
    }


    // MARK: - Transaction Amount

    // Convierte el importe del movimiento a un String
    // con formato monetario y agrega + o -.
    private func transactionAmountText(
        _ transaction: Transaction
    ) -> String {

        let isIncome =
            transaction.type == .deposit ||
            transaction.type == .transferIn

        let formatter = NumberFormatter()

        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        formatter.locale = Locale(identifier: "es_MX")

        let number = NSDecimalNumber(
            decimal: transaction.amount
        )

        let formattedAmount =
            formatter.string(from: number) ?? "$0.00"

        let sign = isIncome ? "+" : "-"

        return "\(sign)\(formattedAmount)"
    }
}


// MARK: - Preview

#Preview {
    HomeView()
}
