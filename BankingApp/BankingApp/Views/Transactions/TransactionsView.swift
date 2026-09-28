//
//  TransactionsView.swift
//  BankingApp
//
//  Historial de movimientos del cliente.
//

import SwiftUI


struct TransactionsView: View {

    // MARK: - View Model

    @State private var viewModel =
        TransactionsViewModel(customerId: 1)


    // MARK: - Body

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {


                // MARK: Summary

                // Mostramos un pequeño resumen antes
                // del historial completo.
                HStack(spacing: 12) {

                    summaryCard(
                        title: "Ingresos",
                        amount: viewModel.totalIncome,
                        icon: "arrow.down"
                    )

                    summaryCard(
                        title: "Gastos",
                        amount: viewModel.totalExpenses,
                        icon: "arrow.up"
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 12)


                // MARK: Filter

                // Picker con estilo segmented crea el control:
                //
                // Todos | Ingresos | Gastos
                Picker(
                    "Filtro",
                    selection: $viewModel.selectedFilter
                ) {

                    ForEach(TransactionFilter.allCases) { filter in

                        Text(filter.rawValue)
                            .tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 8)


                // MARK: Transactions

                if viewModel.filteredTransactions.isEmpty {

                    // Si una búsqueda no encuentra resultados,
                    // mostramos un estado vacío.
                    ContentUnavailableView(
                        "Sin movimientos",
                        systemImage: "magnifyingglass",
                        description: Text(
                            "No encontramos movimientos con estos filtros."
                        )
                    )

                } else {

                    // List está optimizado para mostrar
                    // colecciones desplazables de elementos.
                    List(
                        viewModel.filteredTransactions
                    ) { transaction in

                        // NavigationLink convierte nuestra fila
                        // en un elemento navegable.
                        //
                        // Al tocarla, SwiftUI crea la vista
                        // TransactionDetailView y le entrega
                        // la transacción seleccionada.
                        NavigationLink {

                            TransactionDetailView(
                                transaction: transaction
                            )

                        } label: {

                            transactionRow(transaction)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Movimientos")

            // searchable agrega automáticamente una
            // barra de búsqueda compatible con iOS.
            .searchable(
                text: $viewModel.searchText,
                prompt: "Buscar movimientos"
            )
        }
        .onAppear {

            // Al regresar a esta pestaña recargamos
            // los movimientos actuales de la sesión.
            viewModel.refresh()
        }
    }


    // MARK: - Summary Card

    // Esta función devuelve una pequeña vista reutilizable.
    //
    // "some View" significa que la función devuelve
    // algún tipo de vista de SwiftUI.
    private func summaryCard(
        title: String,
        amount: Decimal,
        icon: String
    ) -> some View {

        HStack {

            Image(systemName: icon)
                .font(.headline)

            VStack(alignment: .leading, spacing: 3) {

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(
                    amount,
                    format: .currency(code: "MXN")
                )
                .font(.subheadline)
                .fontWeight(.semibold)
            }

            Spacer()
        }
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
    }


    // MARK: - Transaction Row

    private func transactionRow(
        _ transaction: Transaction
    ) -> some View {

        HStack(spacing: 12) {

            // Icono correspondiente al tipo de movimiento.
            Image(
                systemName: transactionIcon(
                    for: transaction
                )
            )
            .frame(width: 38, height: 38)
            .background(
                Color(.secondarySystemBackground)
            )
            .clipShape(Circle())


            VStack(alignment: .leading, spacing: 4) {

                Text(transaction.description)
                    .fontWeight(.medium)

                HStack(spacing: 6) {

                    Text(
                        transaction.date,
                        format: .dateTime
                            .day()
                            .month(.abbreviated)
                    )

                    // Si el movimiento está pendiente,
                    // mostramos visualmente su estado.
                    if transaction.status == .pending {

                        Text("• Pendiente")
                            .fontWeight(.medium)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }


            Spacer()


            Text(
                transactionAmountText(transaction)
            )
            .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }


    // MARK: - Transaction Icon

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


    // MARK: - Amount Formatting

    private func transactionAmountText(
        _ transaction: Transaction
    ) -> String {

        let formatter = NumberFormatter()

        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        formatter.locale = Locale(identifier: "es_MX")

        let number = NSDecimalNumber(
            decimal: transaction.amount
        )

        let formattedAmount =
            formatter.string(from: number) ?? "$0.00"

        let sign =
            viewModel.isIncome(transaction)
            ? "+"
            : "-"

        return "\(sign)\(formattedAmount)"
    }
}


// MARK: - Preview

#Preview {
    TransactionsView()
}
