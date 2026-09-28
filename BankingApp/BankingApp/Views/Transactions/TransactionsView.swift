//
//  TransactionsView.swift
//  BankingApp
//
//  Pantalla que mostrará el historial completo
//  de movimientos del cliente.
//

import SwiftUI

struct TransactionsView: View {

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 50))

                Text("Movimientos")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Aquí mostraremos el historial completo de operaciones.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Movimientos")
        }
    }
}


#Preview {
    TransactionsView()
}
