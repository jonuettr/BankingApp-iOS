//
//  LoginView.swift
//  BankingApp
//
//  Pantalla inicial de autenticación.
//
//  Permite iniciar sesión manualmente con clientes
//  ficticios y utilizar Face ID / Touch ID cuando
//  el usuario previamente habilitó la biometría.
//

import SwiftUI


struct LoginView: View {


    // MARK: - Session

    private let session =
        SessionManager.shared


    // MARK: - Login State

    // Cliente seleccionado para el login manual.
    @State private var selectedCustomerId = 1

    // Mensaje mostrado cuando ocurre algún error.
    @State private var errorMessage: String?


    // MARK: - Biometrics


    @State private var biometricAuth =
        BiometricAuthService()


    @State private var biometricSettings =
        BiometricSettings.shared

    @State private var isAuthenticatingWithBiometrics =
        false


    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 28) {


                    // MARK: - Header

                    VStack(spacing: 16) {

                        Image(
                            systemName:
                                "building.columns.fill"
                        )
                        .font(
                            .system(size: 64)
                        )


                        Text("BankingApp")
                            .font(.largeTitle)
                            .fontWeight(.bold)


                        Text(
                            "Banca digital de demostración"
                        )
                        .foregroundStyle(.secondary)
                    }
                    .padding(.top, 50)


                    // MARK: - Biometric Login

                    if canUseBiometricLogin,
                       let customer =
                        biometricCustomer {

                        VStack(spacing: 14) {

                            Text(
                                "Continuar como"
                            )
                            .font(.subheadline)
                            .foregroundStyle(
                                .secondary
                            )


                            Text(
                                customer.fullName
                            )
                            .font(.title3)
                            .fontWeight(
                                .semibold
                            )


                            Button {

                                authenticateWithBiometrics()

                            } label: {

                                HStack {

                                    if isAuthenticatingWithBiometrics {

                                        ProgressView()

                                    } else {

                                        Image(
                                            systemName:
                                                biometricAuth
                                                .biometricType
                                                .systemImage
                                        )
                                    }


                                    Text(
                                        "Continuar con \(biometricAuth.biometricType.displayName)"
                                    )
                                    .fontWeight(
                                        .semibold
                                    )
                                }
                                .frame(
                                    maxWidth:
                                        .infinity
                                )
                            }
                            .buttonStyle(
                                .borderedProminent
                            )
                            .controlSize(.large)
                            .disabled(
                                isAuthenticatingWithBiometrics
                            )

                            HStack {

                                Rectangle()
                                    .frame(
                                        height: 1
                                    )
                                    .foregroundStyle(
                                        Color.secondary
                                            .opacity(0.3)
                                    )


                                Text("o")
                                    .font(.caption)
                                    .foregroundStyle(
                                        .secondary
                                    )


                                Rectangle()
                                    .frame(
                                        height: 1
                                    )
                                    .foregroundStyle(
                                        Color.secondary
                                            .opacity(0.3)
                                    )
                            }
                        }
                    }


                    // MARK: - Manual Login

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
                                .tag(
                                    customer.id
                                )
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


                                Text(
                                    customer.email
                                )
                            }
                            .font(.subheadline)
                            .foregroundStyle(
                                .secondary
                            )
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


                    // MARK: - Manual Login Button

                    Button {

                        login()

                    } label: {

                        HStack {

                            Spacer()


                            Text(
                                "Iniciar sesión"
                            )
                            .fontWeight(
                                .semibold
                            )


                            Spacer()
                        }
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                    .controlSize(.large)


                    // MARK: - Demo Notice

                    Text(
                        "Proyecto demostrativo. No utiliza información bancaria real."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(
                        .center
                    )
                    .padding(.top, 10)
                }
                .padding()
            }
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


    // MARK: - Biometric Customer

    private var biometricCustomer: Customer? {

        guard
            biometricSettings.isEnabled,
            let customerId =
                biometricSettings.customerId
        else {

            return nil
        }


        return MockData.customers.first {
            customer in

            customer.id ==
                customerId
        }
    }


    // MARK: - Biometric Availability

    private var canUseBiometricLogin: Bool {

        biometricSettings.isEnabled &&
        biometricAuth.isAvailable &&
        biometricCustomer != nil
    }


    // MARK: - Manual Login

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


    // MARK: - Biometric Login

    private func authenticateWithBiometrics() {

        guard
            !isAuthenticatingWithBiometrics
        else {

            return
        }

        guard let customer =
            biometricCustomer
        else {

            errorMessage =
                "No existe un cliente asociado a la autenticación biométrica."

            return
        }


        isAuthenticatingWithBiometrics =
            true

        errorMessage = nil


        Task {

            let success =
                await biometricAuth
                    .authenticate()


            isAuthenticatingWithBiometrics =
                false


            guard success else {

                errorMessage =
                    biometricAuth.errorMessage
                    ?? "No fue posible verificar tu identidad."

                return
            }

            let loginSuccess =
                session.login(
                    customerId:
                        customer.id
                )


            if !loginSuccess {

                errorMessage =
                    "No fue posible recuperar la sesión del cliente."
            }
        }
    }
}


// MARK: - Preview

#Preview {

    LoginView()
}
