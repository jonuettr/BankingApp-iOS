//
//  LoginView.swift
//  BankingApp
//
//  Pantalla inicial de autenticación.
//
//  En esta etapa utilizamos clientes ficticios.

import SwiftUI


struct LoginView: View {


    // MARK: - Session

    private let session = SessionManager.shared


    // MARK: - State

    @State private var selectedCustomerId = 1

    @State private var errorMessage: String?


    // MARK: - Body

    var body: some View {

        NavigationStack {

            VStack(spacing: 28) {


                Spacer()


                // MARK: - Header

                VStack(spacing: 16) {

                    Image(
                        systemName:
                            "building.columns.fill"
                    )
                    .font(.system(size: 64))


                    Text("BankingApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)


                    Text(
                        "Banca digital de demostración"
                    )
                    .foregroundStyle(.secondary)
                }


                // MARK: - Login Form

                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {

                    Text("Cliente")
                        .font(.headline)


                    Picker(
                        "Cliente",
                        selection:
                            $selectedCustomerId
                    ) {

                        ForEach(
                            MockData.customers
                        ) { customer in

                            Text(
                                customer.fullName
                            )
                            .tag(customer.id)
                        }
                    }
                    .pickerStyle(.menu)

                    if let customer =
                        selectedCustomer {

                        HStack {

                            Image(
                                systemName:
                                    "envelope.fill"
                            )

                            Text(customer.email)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color(
                        .secondarySystemBackground
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16
                    )
                )


                // MARK: - Error

                if let errorMessage {

                    Label(
                        errorMessage,
                        systemImage:
                            "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(.red)
                }


                // MARK: - Login Button

                Button {

                    login()

                } label: {

                    HStack {

                        Spacer()

                        Text("Iniciar sesión")
                            .fontWeight(.semibold)

                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)


                Spacer()


                // MARK: - Demo Notice

                Text(
                    "Proyecto demostrativo. No utiliza información bancaria real."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
            .padding()
        }
    }


    // MARK: - Selected Customer

    private var selectedCustomer: Customer? {

        MockData.customers.first {
            customer in

            customer.id ==
            selectedCustomerId
        }
    }


    // MARK: - Login

    private func login() {

        errorMessage = nil


        let success =
            session.login(
                customerId:
                    selectedCustomerId
            )


        if !success {

            errorMessage =
                "No fue posible iniciar sesión."
        }
    }
}


// MARK: - Preview

#Preview {
    LoginView()
}
