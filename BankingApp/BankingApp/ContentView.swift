//
//  ContentView.swift
//  BankingApp
//
//  Vista raíz de la aplicación.
//
//  Su responsabilidad es controlar la navegación
//  principal entre las diferentes secciones.
//

import SwiftUI

struct ContentView: View {

    var body: some View {

        // TabView crea una navegación por pestañas.
        //
        // Cada elemento dentro del TabView representa
        // una sección principal de nuestra aplicación.
        TabView {


            // MARK: - Home

            HomeView()
                .tabItem {

                    // SF Symbol utilizado como icono.
                    Image(systemName: "house.fill")

                    // Texto mostrado debajo del icono.
                    Text("Inicio")
                }


            // MARK: - Transactions

            TransactionsView()
                .tabItem {

                    Image(systemName: "list.bullet.rectangle")

                    Text("Movimientos")
                }


            // MARK: - Transfer

            TransferView()
                .tabItem {

                    Image(systemName: "arrow.left.arrow.right")

                    Text("Transferir")
                }


            // MARK: - Analysis

            AnalysisView()
                .tabItem {

                    Image(systemName: "chart.bar.fill")

                    Text("Análisis")
                }


            // MARK: - Profile

            ProfileView()
                .tabItem {

                    Image(systemName: "person.crop.circle")

                    Text("Perfil")
                }
        }
    }
}


// MARK: - Preview

#Preview {
    ContentView()
}
