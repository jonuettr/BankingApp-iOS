//
//  BiometricAuthService.swift
//  BankingApp
//
//  Servicio encargado de interactuar con
//  LocalAuthentication de Apple.

import Foundation
import LocalAuthentication
import Observation


@Observable
final class BiometricAuthService {


    // MARK: - Biometric Type

    // Representa los métodos biométricos
    // que podemos encontrar en un dispositivo Apple.
    enum BiometricType {

        case none
        case faceID
        case touchID


        // Nombre que mostraremos en la interfaz.
        var displayName: String {

            switch self {

            case .none:
                return "Biometría"

            case .faceID:
                return "Face ID"

            case .touchID:
                return "Touch ID"
            }
        }


        // Icono correspondiente de SF Symbols.
        var systemImage: String {

            switch self {

            case .none:
                return "lock.fill"

            case .faceID:
                return "faceid"

            case .touchID:
                return "touchid"
            }
        }
    }


    // MARK: - State

    private(set) var biometricType:
        BiometricType = .none

    private(set) var isAvailable = false

    private(set) var errorMessage: String?


    // MARK: - Initialization

    init() {

        checkAvailability()
    }


    // MARK: - Availability

    func checkAvailability() {

        let context = LAContext()

        var error: NSError?

        isAvailable =
            context.canEvaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                error: &error
            )


        // biometricType nos indica qué tecnología
        // utiliza el dispositivo.
        switch context.biometryType {

        case .faceID:
            biometricType = .faceID

        case .touchID:
            biometricType = .touchID

        default:
            biometricType = .none
        }


        if isAvailable {

            errorMessage = nil

        } else {

            errorMessage =
                "La autenticación biométrica no está disponible."
        }
    }


    // MARK: - Authentication

    func authenticate() async -> Bool {

        let context = LAContext()

        context.localizedCancelTitle =
            "Cancelar"


        var error: NSError?


        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) else {

            await MainActor.run {

                errorMessage =
                    "La autenticación biométrica no está disponible."
            }

            return false
        }


        do {

            let success =
                try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason:
                        "Confirma tu identidad para acceder a BankingApp."
                )


            await MainActor.run {

                errorMessage = nil
            }


            return success

        } catch {

            await MainActor.run {

                errorMessage =
                    "No fue posible verificar tu identidad."
            }


            return false
        }
    }
}
