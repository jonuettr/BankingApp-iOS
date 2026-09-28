//
//  AnalysisView.swift
//  BankingApp
//
//  Pantalla de análisis financiero.
//

import SwiftUI

struct AnalysisView: View {

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 50))

                Text("Análisis")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Aquí mostraremos gastos, categorías y tendencias.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Análisis")
        }
    }
}


#Preview {
    AnalysisView()
}
