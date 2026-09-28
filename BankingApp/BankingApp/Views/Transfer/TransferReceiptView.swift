//
//  TransferReceiptView.swift
//  BankingApp
//
//  Comprobante mostrado después de una
//  transferencia ejecutada correctamente.
//

import SwiftUI


struct TransferReceiptView: View {

    let viewModel: TransferViewModel


    var body: some View {

        ScrollView {

            VStack(spacing: 24) {


                // MARK: - Success

                Image(
                    systemName:
                        "checkmark.circle.fill"
                )
                .font(.system(size: 64))


                Text("Transferencia realizada")
                    .font(.title2)
                    .fontWeight(.bold)


                Text("La operación se completó correctamente.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)


                // MARK: - Receipt

                if let transfer =
                    viewModel.completedTransfer {

                    VStack(spacing: 0) {


                        // Amount

                        Text(
                            transfer.amount,
                            format:
                                .currency(code: "MXN")
                        )
                        .font(.system(
                            size: 32,
                            weight: .bold
                        ))
                        .padding(.vertical, 20)


                        Divider()


                        if let beneficiary =
                            viewModel.selectedBeneficiary {

                            receiptRow(
                                title: "Beneficiario",
                                value: beneficiary.name
                            )

                            Divider()
                        }


                        if let account =
                            viewModel.selectedAccount {

                            receiptRow(
                                title: "Cuenta origen",
                                value:
                                    "\(account.name) •••• \(account.lastFourDigits)"
                            )

                            Divider()
                        }


                        receiptRow(
                            title: "Concepto",
                            value: transfer.concept
                        )


                        if let reference =
                            transfer.reference {

                            Divider()

                            receiptRow(
                                title: "Referencia",
                                value: reference
                            )
                        }


                        Divider()


                        receiptRow(
                            title: "Estado",
                            value: statusText(
                                transfer.status
                            )
                        )


                        Divider()


                        receiptRow(
                            title: "Fecha",
                            value:
                                transfer.createdAt.formatted(
                                    date: .long,
                                    time: .shortened
                                )
                        )
                    }
                    .padding(.horizontal)
                    .background(
                        Color(.secondarySystemBackground)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Comprobante")
        .navigationBarTitleDisplayMode(.inline)

        // Evitamos que el usuario vuelva accidentalmente
        // a la pantalla de confirmación mediante el botón
        // estándar de navegación.

        .navigationBarBackButtonHidden()
    }


    // MARK: - Receipt Row

    private func receiptRow(
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


    // MARK: - Status

    private func statusText(
        _ status: TransferStatus
    ) -> String {

        switch status {

        case .created:
            return "Creada"

        case .processing:
            return "Procesando"

        case .completed:
            return "Completada"

        case .declined:
            return "Rechazada"
        }
    }
}
