//
//  RiskEvaluation.swift
//  BankingApp
//
//  Representa el resultado de una evaluación de riesgo
//  aplicada a una transferencia.
//

import Foundation

// MARK: - Risk Level

// Clasificamos el riesgo en tres niveles.
enum RiskLevel: String, Codable {

    case low
    case medium
    case high
}


// MARK: - Risk Evaluation

struct RiskEvaluation: Codable, Identifiable {

    // Identificador único de la evaluación.
    let id: Int

    // Transferencia que fue evaluada.
    let transferId: Int

    // Puntuación numérica calculada por nuestro motor de riesgo.
    let score: Int

    // Clasificación obtenida a partir del score.
    let level: RiskLevel

    // Indica si la operación requiere una verificación adicional.
    let requiresVerification: Bool

    // Lista de razones que contribuyeron a la puntuación.
    let reasons: [String]

    // Momento en que se realizó la evaluación.
    let evaluatedAt: Date
}
