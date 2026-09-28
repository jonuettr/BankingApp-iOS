//
//  ProfileView.swift
//  BankingApp
//
//  Muestra información del cliente autenticado,
//  sus dispositivos y opciones relacionadas con la sesión.
//

import SwiftUI


struct ProfileView: View {


    // MARK: - Session

    private let session =
        SessionManager.shared

    // MARK: - Biometrics
    @State private var biometricAuth =
        BiometricAuthService()

    @State private var biometricSettings =
        BiometricSettings.shared

    @State private var showBiometricError = false
    
    // MARK: - Body

    var body: some View {

        NavigationStack {

            List {

                if let customer =
                    session.currentCustomer {


                    // MARK: - Customer

                    Section {

                        HStack(spacing: 16) {

                            Image(
                                systemName:
                                    "person.crop.circle.fill"
                            )
                            .font(
                                .system(size: 54)
                            )
                            .foregroundStyle(
                                .blue
                            )


                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {

                                Text(
                                    customer.fullName
                                )
                                .font(.headline)


                                Text(
                                    customer.email
                                )
                                .font(.subheadline)
                                .foregroundStyle(
                                    .secondary
                                )
                            }
                        }
                        .padding(
                            .vertical,
                            8
                        )

                    } header: {

                        Text("Cliente")
                    }


                    // MARK: - Security

                    Section(
                        "Seguridad"
                    ) {

                        NavigationLink {

                            DevicesView(
                                customerId:
                                    customer.id
                            )

                        } label: {

                            Label(
                                "Dispositivos",
                                systemImage:
                                    "iphone.gen3"
                            )
                        }


                        Toggle(
                            isOn: Binding(
                                get: {

                                    biometricSettings.isEnabled
                                },

                                set: { newValue in

                                    handleBiometricToggle(
                                        newValue
                                    )
                                }
                            )
                        ) {

                            Label(
                                biometricAuth.biometricType.displayName,
                                systemImage:
                                    biometricAuth.biometricType.systemImage
                            )
                        }
                        .disabled(
                            !biometricAuth.isAvailable
                        )
                    }


                    // MARK: - Session

                    Section(
                        "Sesión"
                    ) {

                        Button(
                            role: .destructive
                        ) {

                            logout()

                        } label: {

                            Label(
                                "Cerrar sesión",
                                systemImage:
                                    "rectangle.portrait.and.arrow.right"
                            )
                        }
                    }
                    // MARK: - Information

                    Section(
                        "Información"
                    ) {

                        LabeledContent(
                            "Aplicación",
                            value:
                                "BankingApp"
                        )


                        LabeledContent(
                            "Versión",
                            value:
                                "1.0"
                        )
                    }
                }
            }
            .navigationTitle(
                "Perfil"
            )
            .alert(
                "Autenticación no completada",
                isPresented:
                    $showBiometricError
            ) {

                Button(
                    "Aceptar",
                    role: .cancel
                ) { }

            } message: {

                Text(
                    biometricAuth.errorMessage
                    ?? "No fue posible verificar tu identidad."
                )
            }
        }
    }


    // MARK: - Logout

    private func logout() {

        // Al eliminar la sesión actual,
        // BankingAppApp detectará el cambio
        // y regresará automáticamente al LoginView.
        session.logout()
    }


    // MARK: - Biometrics

    private func handleBiometricToggle(
        _ newValue: Bool
    ) {

        // Si el usuario está desactivando
        // la biometría, no necesitamos volver
        // a solicitar Face ID.
        if !newValue {

            biometricSettings.disable()

            return
        }


        // Para activar Face ID necesitamos
        // saber qué cliente está autenticado.
        guard let customer =
            session.currentCustomer
        else {

            return
        }


        // authenticate() es una función async,
        // por eso la ejecutamos dentro de Task.
        Task {

            let success =
                await biometricAuth.authenticate()


            if success {

                // Solamente asociamos Face ID
                // al cliente después de que iOS
                // haya confirmado su identidad.
                biometricSettings.enable(
                    for: customer.id
                )

            } else {

                // Si Face ID falla o se cancela,
                // mostramos nuestro Alert.
                showBiometricError = true
            }
        }
    }
}
