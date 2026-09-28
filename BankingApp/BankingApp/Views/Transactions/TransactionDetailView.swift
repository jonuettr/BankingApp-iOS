//
//  TransactionDetailView.swift
//  BankingApp
//
//  Muestra el detalle completo de un movimiento.
//

import SwiftUI


struct TransactionDetailView: View {

    // MARK: - Properties

    // Esta vista recibe una transacción desde
    // TransactionsView.
    let transaction: Transaction


    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(spacing: 24) {


                // MARK: Header

                VStack(spacing: 12) {

                    Image(
                        systemName: transactionIcon
                    )
                    .font(.system(size: 32))
                    .frame(width: 72, height: 72)
                    .background(
                        Color(.secondarySystemBackground)
                    )
                    .clipShape(Circle())


                    Text(transaction.description)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)


                    Text(amountText)
                        .font(.system(size: 32, weight: .bold))


                    // Mostramos el estado de la operación.
                    Text(statusText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Color(.secondarySystemBackground)
                        )
                        .clipShape(Capsule())
                }


                // MARK: Details

                VStack(spacing: 0) {

                    detailRow(
                        title: "Fecha",
                        value: transaction.date.formatted(
                            date: .long,
                            time: .shortened
                        )
                    )

                    Divider()


                    detailRow(
                        title: "Categoría",
                        value: categoryText
                    )

                    Divider()


                    detailRow(
                        title: "Tipo",
                        value: typeText
                    )


                    // merchant es opcional.
                    //
                    // Si contiene un valor, mostramos la fila.
                    // Si es nil, la fila ni siquiera aparece.
                    if let merchant = transaction.merchant {

                        Divider()

                        detailRow(
                            title: "Comercio",
                            value: merchant
                        )
                    }


                    if let reference = transaction.reference {

                        Divider()

                        detailRow(
                            title: "Referencia",
                            value: reference
                        )
                    }


                    Divider()


                    detailRow(
                        title: "Producto",
                        value: productText
                    )


                    Divider()


                    detailRow(
                        title: "ID de operación",
                        value: String(transaction.id)
                    )
                }
                .padding(.horizontal)
                .background(
                    Color(.secondarySystemBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
            }
            .padding()
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
    }


    // MARK: - Detail Row

    // Componente pequeño utilizado para evitar repetir
    // la misma estructura en todas las filas.
    private func detailRow(
        title: String,
        value: String
    ) -> some View {

        HStack(alignment: .top) {

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 14)
    }


    // MARK: - Amount

    private var amountText: String {

        let formatter = NumberFormatter()

        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        formatter.locale = Locale(identifier: "es_MX")

        let number = NSDecimalNumber(
            decimal: transaction.amount
        )

        let formattedAmount =
            formatter.string(from: number) ?? "$0.00"

        let isIncome =
            transaction.type == .deposit ||
            transaction.type == .transferIn

        return "\(isIncome ? "+" : "-")\(formattedAmount)"
    }


    // MARK: - Status

    private var statusText: String {

        switch transaction.status {

        case .pending:
            return "Pendiente"

        case .completed:
            return "Completada"

        case .declined:
            return "Rechazada"
        }
    }


    // MARK: - Category

    private var categoryText: String {

        switch transaction.category {

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


    // MARK: - Type

    private var typeText: String {

        switch transaction.type {

        case .purchase:
            return "Compra"

        case .deposit:
            return "Depósito"

        case .transferOut:
            return "Transferencia enviada"

        case .transferIn:
            return "Transferencia recibida"

        case .directDebit:
            return "Domiciliación"

        case .creditCardPayment:
            return "Pago de tarjeta"
        }
    }


    // MARK: - Product

    private var productText: String {

        // Si tiene accountId, buscamos la cuenta correspondiente.
        if let accountId = transaction.accountId,
           let account = MockData.accounts.first(
                where: { $0.id == accountId }
           ) {

            return "\(account.name) •••• \(account.lastFourDigits)"
        }


        // Si no pertenece a una cuenta, comprobamos
        // si pertenece a una tarjeta.
        if let creditCardId = transaction.creditCardId,
           let card = MockData.creditCards.first(
                where: { $0.id == creditCardId }
           ) {

            return "\(card.name) •••• \(card.lastFourDigits)"
        }


        return "No disponible"
    }


    // MARK: - Icon

    private var transactionIcon: String {

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
}


// MARK: - Preview

#Preview {

    NavigationStack {

        TransactionDetailView(
            transaction: MockData.transactions.first!
        )
    }
}
