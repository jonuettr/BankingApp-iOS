//
//  Beneficiary.swift
//  BankingApp
//
//  Representa una cuenta beneficiaria a la que el cliente
//  puede realizar una transferencia.
//

import Foundation

// MARK: - Beneficiary

struct Beneficiary: Codable, Identifiable {

    // Identificador único del beneficiario.
    let id: Int

    // Cliente que tiene guardado a este beneficiario.
    let ownerCustomerId: Int

    // Nombre que se mostrará al realizar una transferencia.
    let name: String

    // Banco al que pertenece la cuenta destino.
    let bankName: String

    // CLABE de la cuenta beneficiaria.
    let clabe: String

    // Si el beneficiario corresponde a uno de los clientes
    // existentes dentro de nuestra propia aplicación, podremos
    // relacionarlo directamente.
    let destinationCustomerId: Int?

    // Cuenta interna a la que llegará el dinero, cuando aplique.
    let destinationAccountId: Int?

    // Permite desactivar un beneficiario sin eliminarlo físicamente.
    let isActive: Bool
}
