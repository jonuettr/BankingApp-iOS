//
//  Transfer.swift
//  BankingApp
//
//  Representa una transferencia de dinero desde una cuenta
//  de origen hacia una cuenta beneficiaria.
//

import Foundation

// MARK: - Transfer Status

// Define los estados posibles de una transferencia.
enum TransferStatus: String, Codable {

    case created
    case processing
    case completed
    case declined
}


// MARK: - Transfer

struct Transfer: Codable, Identifiable {

    // Identificador único de la transferencia.
    let id: Int

    // Cuenta desde la que saldrá el dinero.
    let sourceAccountId: Int

    // Beneficiario que recibirá el dinero.
    let beneficiaryId: Int

    // Importe de la transferencia.
    let amount: Decimal

    // Concepto introducido por el usuario.
    let concept: String

    // Referencia numérica opcional.
    let reference: String?

    // Estado actual de la transferencia.
    let status: TransferStatus

    // Fecha y hora en que se creó la operación.
    let createdAt: Date

    // Fecha en la que terminó de procesarse.
    let completedAt: Date?
}
