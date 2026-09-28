//
//  RiskEngine.swift
//  BankingApp
//
//  Motor de reglas utilizado para evaluar el riesgo
//  de una transferencia.
//
//  IMPORTANTE:
//  Este motor es una simulación educativa para nuestro proyecto.
//  No representa un sistema antifraude bancario real.
//

import Foundation


// MARK: - Risk Context

// Antes de evaluar una transferencia necesitamos conocer
// ciertas características de la operación.
//
// En lugar de pasar muchos parámetros separados al RiskEngine,
// los agrupamos dentro de un único objeto llamado RiskContext.
struct RiskContext {

    // Importe que el cliente quiere transferir.
    let amount: Decimal

    // Indica si el beneficiario es nuevo.
    let isNewBeneficiary: Bool

    // Indica si el dispositivo desde el que se realiza
    // la transferencia todavía no es confiable.
    let isNewDevice: Bool

    // Cantidad de transferencias realizadas recientemente.
    let recentTransferCount: Int

    // Hora en la que se está intentando realizar la operación.
    //
    let hour: Int
}


// MARK: - Risk Result

struct RiskResult {

    // Puntuación total obtenida.
    let score: Int

    // Nivel correspondiente al score.
    let level: RiskLevel

    // Indica si necesitamos una validación adicional.
    let requiresVerification: Bool

    // Reglas que contribuyeron al resultado.
    let reasons: [String]
}


// MARK: - Risk Engine

enum RiskEngine {


    // MARK: - Evaluate

    static func evaluate(
        context: RiskContext
    ) -> RiskResult {

        // Empezamos con riesgo 0.
        var score = 0

        // Array vacío donde iremos guardando
        // las reglas que se activaron.
        var reasons: [String] = []


        // MARK: Rule 1 - High Amount

        // Si el importe supera $20,000,
        // agregamos 30 puntos.
        if context.amount > Decimal(20_000) {

            score += 30

            reasons.append(
                "Transfer amount greater than $20,000"
            )
        }


        // MARK: Rule 2 - New Beneficiary

        // Un beneficiario nuevo agrega 20 puntos.
        if context.isNewBeneficiary {

            score += 20

            reasons.append(
                "New beneficiary"
            )
        }


        // MARK: Rule 3 - New Device

        // Una operación desde un dispositivo todavía
        // no confiable agrega 25 puntos.
        if context.isNewDevice {

            score += 25

            reasons.append(
                "Untrusted device"
            )
        }


        // MARK: Rule 4 - Transfer Velocity

        // Si ya existen al menos 3 transferencias
        // recientes, agregamos 20 puntos.
        //
        // Esta regla simula un control de velocidad:
        // muchas operaciones dentro de un periodo corto.
        if context.recentTransferCount >= 3 {

            score += 20

            reasons.append(
                "Multiple recent transfers"
            )
        }


        // MARK: Rule 5 - Unusual Hour

        // 00:00 - 04:59
        // Es solamente una regla ficticia para demostrar
        // cómo funciona el motor.
        if context.hour >= 0 && context.hour < 5 {

            score += 10

            reasons.append(
                "Transaction at unusual hour"
            )
        }


        // MARK: - Determine Level

        // Ahora convertimos el score numérico
        // en una clasificación.
        let level: RiskLevel

        if score >= 60 {

            level = .high

        } else if score >= 30 {

            level = .medium

        } else {

            level = .low
        }


        // MARK: - Verification

        // Por ahora solamente las operaciones de riesgo alto
        // requerirán verificación adicional.
        let requiresVerification =
            level == .high


        // MARK: - Result

        return RiskResult(
            score: score,
            level: level,
            requiresVerification: requiresVerification,
            reasons: reasons
        )
    }
}
