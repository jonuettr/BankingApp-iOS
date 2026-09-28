//
//  SessionManager.swift
//  BankingApp
//
//  Administra la sesión del usuario autenticado.
//
//  En esta primera versión la autenticación es local.

import Foundation
import Observation


@Observable
final class SessionManager {


    // MARK: - Shared Instance

    static let shared = SessionManager()


    // MARK: - Session State

    private(set) var currentCustomer: Customer?

    var isAuthenticated: Bool {

        currentCustomer != nil
    }


    // MARK: - Initialization

    private init() {

        currentCustomer = nil
    }


    // MARK: - Login

    @discardableResult
    func login(
        customerId: Int
    ) -> Bool {

        guard let customer =
            MockData.customers.first(
                where: { customer in

                    customer.id == customerId
                }
            )
        else {

            return false
        }


        currentCustomer = customer

        return true
    }


    // MARK: - Logout

    func logout() {

        currentCustomer = nil
    }
}
