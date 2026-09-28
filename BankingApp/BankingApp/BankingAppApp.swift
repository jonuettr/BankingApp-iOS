//
//  BankingAppApp.swift
//  BankingApp
//
//  Punto de entrada principal de la aplicación.
//

import SwiftUI


@main
struct BankingAppApp: App {


    // MARK: - Session

    @State private var session =
        SessionManager.shared


    // MARK: - Application

    var body: some Scene {

        WindowGroup {

            if session.isAuthenticated {

                ContentView()

            } else {

                LoginView()
            }
        }
    }
}
