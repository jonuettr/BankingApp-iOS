//
//  CreditCard.swift
//  BankingApp
//
//  Representa una tarjeta de crédito perteneciente a un cliente.
//

import Foundation

// MARK: - Credit Card

struct CreditCard: Codable, Identifiable {

    // Identificador único de la tarjeta.
    let id: Int

    // Cliente propietario de la tarjeta.
    let customerId: Int

    // Nombre comercial que mostraremos en la aplicación.
    let name: String

    // Últimos cuatro dígitos de la tarjeta.
    let lastFourDigits: String

    // Línea de crédito total autorizada.
    let creditLimit: Decimal

    // Cantidad de crédito actualmente utilizada.
    let currentBalance: Decimal

    // Pago mínimo requerido.
    let minimumPayment: Decimal

    // Pago necesario para no generar intereses.
    let paymentToAvoidInterest: Decimal

    // Día del mes en que se realiza el corte.
    let statementDay: Int

    // Día límite de pago.
    let paymentDueDay: Int

    // Indica si la tarjeta está activa.
    let isActive: Bool


    // MARK: - Computed Properties

    // Calcula cuánto crédito todavía puede utilizar el cliente.
    var availableCredit: Decimal {
        creditLimit - currentBalance
    }

    // Calcula qué proporción de la línea de crédito está utilizada.
    var utilizationRatio: Decimal {

        // Evitamos dividir entre cero.
        guard creditLimit > 0 else {
            return 0
        }

        return currentBalance / creditLimit
    }
}
