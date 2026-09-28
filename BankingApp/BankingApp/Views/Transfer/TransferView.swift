//
//  TransferView.swift
//  BankingApp
//
//  Pantalla para realizar transferencias.
//

import SwiftUI

struct TransferView: View {

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 50))

                Text("Transferir")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Aquí construiremos el flujo para enviar dinero.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Transferir")
        }
    }
}


#Preview {
    TransferView()
}
