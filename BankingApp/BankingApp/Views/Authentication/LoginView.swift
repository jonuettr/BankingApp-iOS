//
//  LoginView.swift
//  BankingApp
//
//  Inicio de sesión real contra Spring Boot.
//

import SwiftUI


struct LoginView: View {

    // MARK: Session

    private let session =
        SessionManager.shared


    // MARK: Login State

    @State private var email =
        "alex.rivera@bankingapp.test"

    @State private var password =
        ""

    @State private var errorMessage:
        String?


    // MARK: Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 28) {


                    // MARK: Header

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
                        .foregroundStyle(
                            .secondary
                        )
                    }
                    .padding(.top, 50)


                    // MARK: Credentials

                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {

                        Text("Correo")
                            .font(.headline)


                        TextField(
                            "correo@ejemplo.com",
                            text: $email
                        )
                        .textInputAutocapitalization(
                            .never
                        )
                        .keyboardType(
                            .emailAddress
                        )
                        .autocorrectionDisabled()
                        .textFieldStyle(
                            .roundedBorder
                        )


                        Text("Contraseña")
                            .font(.headline)


                        SecureField(
                            "Contraseña",
                            text: $password
                        )
                        .textContentType(
                            .password
                        )
                        .textFieldStyle(
                            .roundedBorder
                        )
                    }
                    .padding()
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


                    // MARK: Error

                    if let errorMessage {

                        Label(
                            errorMessage,
                            systemImage:
                                "exclamationmark.triangle.fill"
                        )
                        .foregroundStyle(.red)
                    }


                    // MARK: Login Button

                    Button {

                        performLogin()

                    } label: {

                        HStack {

                            Spacer()


                            if session.isLoggingIn {

                                ProgressView()

                            } else {

                                Text(
                                    "Iniciar sesión"
                                )
                                .fontWeight(
                                    .semibold
                                )
                            }


                            Spacer()
                        }
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                    .controlSize(.large)
                    .disabled(
                        session.isLoggingIn
                        || email.isEmpty
                        || password.isEmpty
                    )


                    // MARK: Demo Credentials

                    VStack(spacing: 4) {

                        Text(
                            "Cuenta de demostración"
                        )
                        .fontWeight(
                            .semibold
                        )


                        Text(
                            "alex.rivera@bankingapp.test"
                        )


                        Text(
                            "BankingDemo2026!"
                        )
                    }
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )


                    Text(
                        "Proyecto demostrativo. No utiliza información bancaria real."
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                    .multilineTextAlignment(
                        .center
                    )
                    .padding(.top, 10)
                }
                .padding()
            }
        }
    }


    // MARK: - Login

    private func performLogin() {

        errorMessage =
            nil


        Task {

            do {

                try await session.login(
                    email: email,
                    password: password
                )

            } catch {

                errorMessage =
                    error.localizedDescription
            }
        }
    }
}


// MARK: - Preview

#Preview {

    LoginView()
}
