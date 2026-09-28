//
//  BiometricSettings.swift
//  BankingApp
//
//  Guarda la preferencia de autenticación biométrica.
//
//  IMPORTANTE:
//  Aquí solamente guardamos:
//  - si el usuario activó la biometría;
//  - qué cliente está asociado.
//
//  NO almacenamos información biométrica.
//  Face ID / Touch ID son administrados por iOS.
//

import Foundation
import Observation


@Observable
final class BiometricSettings {


    // MARK: - Shared Instance

    static let shared = BiometricSettings()


    // MARK: - Keys

    private let enabledKey =
        "biometricAuthenticationEnabled"

    private let customerIdKey =
        "biometricCustomerId"


    // MARK: - State

    private(set) var isEnabled: Bool

    private(set) var customerId: Int?


    // MARK: - Initialization

    private init() {

        let defaults = UserDefaults.standard


        isEnabled =
            defaults.bool(
                forKey: enabledKey
            )

        if defaults.object(
            forKey: customerIdKey
        ) != nil {

            customerId =
                defaults.integer(
                    forKey: customerIdKey
                )

        } else {

            customerId = nil
        }
    }


    // MARK: - Enable

    func enable(
        for customerId: Int
    ) {

        self.customerId =
            customerId

        isEnabled = true


        UserDefaults.standard.set(
            true,
            forKey: enabledKey
        )


        UserDefaults.standard.set(
            customerId,
            forKey: customerIdKey
        )
    }


    // MARK: - Disable

    func disable() {

        isEnabled = false
        customerId = nil


        UserDefaults.standard.set(
            false,
            forKey: enabledKey
        )


        UserDefaults.standard.removeObject(
            forKey: customerIdKey
        )
    }
}
