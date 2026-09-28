//
//  TransferView.swift
//  BankingApp
//
//  Formulario para preparar una transferencia bancaria.
//

import SwiftUI


struct TransferView: View {

    // MARK: - View Model

    @State private var viewModel =
        TransferViewModel(customerId: 1)


    // MARK: - State

    @State private var showConfirmation = false


    // MARK: - Body

    var body: some View {

        NavigationStack {

            Form {


                // MARK: - Source Account

                Section("Cuenta de origen") {

                    Picker(
                        "Cuenta",
                        selection: $viewModel.selectedAccountId
                    ) {

                        ForEach(viewModel.accounts) { account in

                            VStack(alignment: .leading) {

                                Text(account.name)

                                Text(
                                    "•••• \(account.lastFourDigits)"
                                )
                            }
                            .tag(Optional(account.id))
                        }
                    }


                    if let account = viewModel.selectedAccount {

                        HStack {

                            Text("Saldo disponible")

                            Spacer()

                            Text(
                                account.balance,
                                format: .currency(
                                    code: account.currency
                                )
                            )
                            .fontWeight(.semibold)
                        }
                    }
                }


                // MARK: - Beneficiary

                Section("Beneficiario") {

                    Picker(
                        "Enviar a",
                        selection: $viewModel.selectedBeneficiaryId
                    ) {

                        ForEach(viewModel.beneficiaries) { beneficiary in

                            Text(beneficiary.name)
                                .tag(Optional(beneficiary.id))
                        }
                    }


                    // Información adicional del beneficiario.
                    if let beneficiary =
                        viewModel.selectedBeneficiary {

                        VStack(
                            alignment: .leading,
                            spacing: 5
                        ) {

                            Text(beneficiary.bankName)
                                .font(.subheadline)

                            Text(
                                maskedCLABE(
                                    beneficiary.clabe
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }


                // MARK: - Transfer Data

                Section("Datos de la transferencia") {

                    TextField(
                        "Monto",
                        text: $viewModel.amountText
                    )
                    .keyboardType(.decimalPad)


                    TextField(
                        "Concepto",
                        text: $viewModel.concept
                    )
                }


                // MARK: - Validation Error

                // Esta sección solamente existe cuando
                // validationMessage contiene un valor.
                if let message =
                    viewModel.validationMessage {

                    Section {

                        Label(
                            message,
                            systemImage:
                                "exclamationmark.triangle.fill"
                        )
                        .foregroundStyle(.red)
                    }
                }


                // MARK: - Continue

                Section {

                    Button {

                        // Pedimos al ViewModel preparar
                        // la transferencia.
                        //
                        // Si devuelve true:
                        // - los datos son válidos
                        // - RiskEngine ya fue ejecutado
                        if viewModel.prepareTransfer() {

                            showConfirmation = true
                        }

                    } label: {

                        HStack {

                            Spacer()

                            Text("Continuar")
                                .fontWeight(.semibold)

                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Transferir")


            // MARK: - Navigation

            .navigationDestination(
                isPresented: $showConfirmation
            ) {

                TransferRiskResultView(
                    viewModel: viewModel
                )
            }
        }
    }


    // MARK: - CLABE Formatting

    private func maskedCLABE(
        _ clabe: String
    ) -> String {

        let lastFour = clabe.suffix(4)

        return "CLABE •••• \(lastFour)"
    }
}


// MARK: - Risk Result View

struct TransferRiskResultView: View {

    let viewModel: TransferViewModel

    // Controla la navegación hacia el comprobante.
    @State private var showReceipt = false
    
    var body: some View {

        ScrollView {

            VStack(spacing: 24) {


                // MARK: - Icon

                Image(
                    systemName:
                        "checkmark.shield.fill"
                )
                .font(.system(size: 52))


                // MARK: - Title

                Text("Transferencia preparada")
                    .font(.title2)
                    .fontWeight(.bold)


                // MARK: - Transfer Information

                VStack(spacing: 0) {

                    if let account =
                        viewModel.selectedAccount {

                        detailRow(
                            title: "Desde",
                            value:
                                "\(account.name) •••• \(account.lastFourDigits)"
                        )

                        Divider()
                    }


                    if let beneficiary =
                        viewModel.selectedBeneficiary {

                        detailRow(
                            title: "Para",
                            value: beneficiary.name
                        )

                        Divider()
                    }


                    if let amount = viewModel.amount {

                        detailRow(
                            title: "Monto",
                            value: amount.formatted(
                                .currency(code: "MXN")
                            )
                        )

                        Divider()
                    }


                    detailRow(
                        title: "Concepto",
                        value: viewModel.concept
                    )
                }
                .padding(.horizontal)
                .background(
                    Color(.secondarySystemBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )


                // MARK: - Risk Result

                if let risk =
                    viewModel.riskResult {

                    VStack(spacing: 12) {

                        Text("Evaluación de riesgo")
                            .font(.headline)


                        Text(
                            riskLevelText(
                                risk.level
                            )
                        )
                        .font(.title2)
                        .fontWeight(.bold)


                        Text(
                            "Score: \(risk.score)"
                        )
                        .foregroundStyle(.secondary)


                        if risk.requiresVerification {

                            Label(
                                "Requiere verificación adicional",
                                systemImage:
                                    "exclamationmark.shield.fill"
                            )
                            .fontWeight(.medium)

                        } else {

                            Label(
                                "Operación autorizada para continuar",
                                systemImage:
                                    "checkmark.circle.fill"
                            )
                            .fontWeight(.medium)
                        }


                        // Si alguna regla se activó,
                        // mostramos las razones.
                        if !risk.reasons.isEmpty {

                            Divider()

                            VStack(
                                alignment: .leading,
                                spacing: 8
                            ) {

                                Text("Reglas activadas")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)


                                ForEach(
                                    risk.reasons,
                                    id: \.self
                                ) { reason in

                                    Label(
                                        reason,
                                        systemImage:
                                            "exclamationmark.circle"
                                    )
                                    .font(.caption)
                                }
                            }
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        }
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity
                    )
                    .background(
                        Color(.secondarySystemBackground)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                }

                // MARK: - Confirm Transfer

                Button {

                    // Aquí ocurre la transferencia real.
                    if viewModel.executeTransfer() {

                        showReceipt = true
                    }

                } label: {

                    HStack {

                        Spacer()

                        Text("Confirmar transferencia")
                            .fontWeight(.semibold)

                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)


                // Si BankingService produjo un error,
                // lo mostramos debajo del botón.
                if let errorMessage =
                    viewModel.executionErrorMessage {

                    Label(
                        errorMessage,
                        systemImage:
                            "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(.red)
                    .font(.subheadline)
                }
            }
            .padding()
        }
        .navigationTitle("Confirmación")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(
            isPresented: $showReceipt
        ) {

            TransferReceiptView(
                viewModel: viewModel
            )
        }
    }


    // MARK: - Detail Row

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


    // MARK: - Risk Level Text

    private func riskLevelText(
        _ level: RiskLevel
    ) -> String {

        switch level {

        case .low:
            return "Riesgo bajo"

        case .medium:
            return "Riesgo medio"

        case .high:
            return "Riesgo alto"
        }
    }
}


// MARK: - Preview

#Preview {
    TransferView()
}
