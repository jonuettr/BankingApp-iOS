//
//  ProfileView.swift
//  BankingApp
//
//  Pantalla de perfil y configuración.
//

import SwiftUI

struct ProfileView: View {

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                Image(systemName: "person.crop.circle")
                    .font(.system(size: 50))

                Text("Perfil")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Aquí mostraremos los datos y configuración del cliente.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Perfil")
        }
    }
}


#Preview {
    ProfileView()
}
