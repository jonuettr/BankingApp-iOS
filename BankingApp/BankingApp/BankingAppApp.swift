//
//  BankingAppApp.swift
//  BankingApp
//
//  Punto de entrada principal de la aplicación.
//

import SwiftUI


@main
struct BankingAppApp: App {

    // SessionManager es compartido por toda la app.
    @State private var session =
        SessionManager.shared


    var body: some Scene {

        WindowGroup {

            Group {

                // Mientras comprobamos si existe una
                // sesión anterior válida, evitamos mostrar
                // momentáneamente la pantalla de Login.
                if session.isRestoringSession {

                    ProgressView(
                        "Verificando sesión..."
                    )

                } else if session.isAuthenticated {

                    ContentView()

                } else {

                    LoginView()
                }
            }

            // Al iniciar la interfaz intentamos recuperar
            // una sesión anterior exactamente una vez.
            .task {

                await session
                    .restoreSessionIfPossible()
            }
        }
    }
}
