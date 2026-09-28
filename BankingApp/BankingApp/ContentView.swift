//
//  ContentView.swift
//  BankingApp
//
//  Contenedor principal de la aplicación.
//  Muestra las pestañas correspondientes al cliente autenticado.
//

import SwiftUI


struct ContentView: View {


    // MARK: - Session

    private let session =
        SessionManager.shared


    // MARK: - Body

    var body: some View {

        if let customer =
            session.currentCustomer {

            TabView {

                HomeView(
                    customerId: customer.id
                )
                .tabItem {

                    Image(
                        systemName: "house.fill"
                    )

                    Text("Inicio")
                }


                TransactionsView(
                    customerId: customer.id
                )
                .tabItem {

                    Image(
                        systemName:
                            "list.bullet.rectangle"
                    )

                    Text("Movimientos")
                }


                TransferView(
                    customerId: customer.id
                )
                .tabItem {

                    Image(
                        systemName:
                            "arrow.left.arrow.right"
                    )

                    Text("Transferir")
                }


                AnalysisView(
                    customerId: customer.id
                )
                .tabItem {

                    Image(
                        systemName:
                            "chart.bar.fill"
                    )

                    Text("Análisis")
                }


                ProfileView()
                    .tabItem {

                        Image(
                            systemName:
                                "person.crop.circle"
                        )

                        Text("Perfil")
                    }
            }

        } else {

            ContentUnavailableView(
                "Sin sesión",
                systemImage:
                    "person.crop.circle.badge.xmark",
                description:
                    Text(
                        "No existe un cliente autenticado."
                    )
            )
        }
    }
}


// MARK: - Preview

#Preview {

    LoginView()
}
