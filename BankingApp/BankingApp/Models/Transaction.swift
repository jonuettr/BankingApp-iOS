//
//  Transaction.swift
//  BankingApp
//
//  Representa un movimiento financiero realizado en una cuenta.
//

import Foundation

// MARK: - Transaction Type
// Define los tipos de movimientos que puede registrar una cuenta.

enum TransactionType: String, Codable {

    // Compra realizada con la cuenta.
    case purchase

    // Dinero recibido como depósito, por ejemplo una nómina.
    case deposit

    // Transferencia enviada.
    case transferOut

    // Transferencia recibida.
    case transferIn

    // Pago automático de un servicio.
    case directDebit

    // Pago realizado a una tarjeta de crédito.
    case creditCardPayment
}


// MARK: - Transaction Category

// Categoría utilizada para clasificar los movimientos.

enum TransactionCategory: String, Codable {

    case income
    case food
    case transportation
    case entertainment
    case shopping
    case services
    case health
    case transfers
    case financial
    case other
}


// MARK: - Transaction Status

// Una operación financiera puede encontrarse en distintos estados.
//
// pending   → todavía está siendo procesada.
// completed → terminó correctamente.
// declined  → fue rechazada.
//
// Esto será especialmente útil cuando implementemos transferencias
// y evaluación de riesgo.
enum TransactionStatus: String, Codable {

    case pending
    case completed
    case declined
}


// MARK: - Transaction

struct Transaction: Codable, Identifiable {

    // Identificador único del movimiento.
    let id: Int

    // Cuenta a la que pertenece este movimiento.

    // Cuenta bancaria relacionada con el movimiento.
    let accountId: Int?

    // Tarjeta de crédito relacionada con el movimiento.
    let creditCardId: Int?

    // Texto que verá el usuario.

    let description: String

    // Importe de la operación.

    let amount: Decimal

    // Tipo de movimiento.
    let type: TransactionType

    // Categoría utilizada para análisis financiero.
    let category: TransactionCategory

    // Estado actual de la operación.
    let status: TransactionStatus

    // Fecha y hora en la que ocurrió.

    let date: Date

    // Nombre del comercio cuando aplique.

    let merchant: String?

    // Referencia o concepto adicional de la operación.

    let reference: String?
}
