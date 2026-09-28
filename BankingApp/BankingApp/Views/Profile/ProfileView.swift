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


                        Label(
                            "Autenticación biométrica",
                            systemImage:
                                "faceid"
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
        }
    }


    // MARK: - Logout

    private func logout() {

        session.logout()
    }
}


// MARK: - Preview

#Preview {

    ProfileView()
}
