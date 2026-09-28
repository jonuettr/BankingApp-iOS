
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

// MARK: - Banking Data

// BankingService mantiene el estado bancario compartido
// entre Inicio, Movimientos, Transferencias y Análisis.
private let bankingService =
    BankingService.shared

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
            .task(id: customer.id) {

                // MARK: - Initial API Load
                //
                // ContentView es el contenedor de todas las pestañas.
                // Por eso hacemos aquí la carga desde el servidor
                // una sola vez para el cliente autenticado.
                //
                // Flujo:
                //
                // MySQL
                //   ↓
                // Spring Boot
                //   ↓
                // REST / JSON
                //   ↓
                // BankingAPIService
                //   ↓
                // BankingService
                //   ↓
                // ViewModels
                //   ↓
                // SwiftUI

                do {

                    try await bankingService
                        .loadCustomerData(
                            customerId: customer.id
                        )

                } catch {

                    // BankingService ya guarda el mensaje
                    // del error en errorMessage.
                    //
                    // Más adelante mostraremos este error
                    // visualmente y agregaremos un botón
                    // para volver a intentar.
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
