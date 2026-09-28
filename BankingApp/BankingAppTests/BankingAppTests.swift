//
//  BankingAppTests.swift
//  BankingAppTests
//
//  Pruebas unitarias del proyecto BankingApp.
//

import Foundation
import Testing

@testable import BankingApp

// MARK: - Banking App Tests

@Suite(.serialized)
struct BankingAppTests {


    // MARK: - Low Risk

    // ESCENARIO:
    //
    // Transferencia pequeña.
    // Beneficiario conocido.
    // Dispositivo conocido.
    // Sin muchas transferencias recientes.
    // Horario normal.
    //
    // Ninguna regla debería activarse.
    @Test
    func lowRiskTransfer() {

        // ARRANGE
        //
        // Preparamos los datos que necesita la prueba.
        let context = RiskContext(
            amount: Decimal(1_000),
            isNewBeneficiary: false,
            isNewDevice: false,
            recentTransferCount: 0,
            hour: 14
        )


        // ACT
        //
        // Ejecutamos el código que queremos probar.
        let result = RiskEngine.evaluate(
            context: context
        )


        // ASSERT
        //
        // #expect comprueba que el resultado obtenido
        // sea exactamente el esperado.
        #expect(result.score == 0)
        #expect(result.level == .low)
        #expect(result.requiresVerification == false)
        #expect(result.reasons.isEmpty)
    }


    // MARK: - Medium Risk

    // Una transferencia superior a $20,000
    // agrega 30 puntos.
    //
    // 30 puntos = riesgo MEDIUM.
    @Test
    func mediumRiskForHighAmount() {

        let context = RiskContext(
            amount: Decimal(25_000),
            isNewBeneficiary: false,
            isNewDevice: false,
            recentTransferCount: 0,
            hour: 14
        )

        let result = RiskEngine.evaluate(
            context: context
        )

        #expect(result.score == 30)
        #expect(result.level == .medium)
        #expect(result.requiresVerification == false)

        #expect(
            result.reasons.contains(
                "Transfer amount greater than $20,000"
            )
        )
    }


    // MARK: - High Risk

    // Aquí activamos tres reglas:
    //
    // Monto alto            +30
    // Beneficiario nuevo    +20
    // Dispositivo nuevo     +25
    //                       ----
    // TOTAL                  75
    //
    // 75 = HIGH
    @Test
    func highRiskTransfer() {

        let context = RiskContext(
            amount: Decimal(35_000),
            isNewBeneficiary: true,
            isNewDevice: true,
            recentTransferCount: 0,
            hour: 14
        )

        let result = RiskEngine.evaluate(
            context: context
        )

        #expect(result.score == 75)
        #expect(result.level == .high)
        #expect(result.requiresVerification == true)

        #expect(result.reasons.count == 3)
    }


    // MARK: - Transfer Velocity

    // Tres transferencias recientes activan
    // nuestra regla de velocidad.
    //
    // Resultado esperado:
    //
    // +20 puntos
    // LOW
    //
    // Recuerda:
    // LOW = 0...29.
    @Test
    func recentTransfersIncreaseRisk() {

        let context = RiskContext(
            amount: Decimal(1_000),
            isNewBeneficiary: false,
            isNewDevice: false,
            recentTransferCount: 3,
            hour: 14
        )

        let result = RiskEngine.evaluate(
            context: context
        )

        #expect(result.score == 20)
        #expect(result.level == .low)

        #expect(
            result.reasons.contains(
                "Multiple recent transfers"
            )
        )
    }


    // MARK: - Unusual Hour

    // Una transferencia realizada a las 2 AM
    // debe activar la regla de horario inusual.
    //
    // Resultado esperado:
    //
    // +10 puntos
    // LOW
    @Test
    func unusualHourIncreasesRisk() {

        let context = RiskContext(
            amount: Decimal(1_000),
            isNewBeneficiary: false,
            isNewDevice: false,
            recentTransferCount: 0,
            hour: 2
        )

        let result = RiskEngine.evaluate(
            context: context
        )

        #expect(result.score == 10)
        #expect(result.level == .low)

        #expect(
            result.reasons.contains(
                "Transaction at unusual hour"
            )
        )
    }
    
    // MARK: - Banking Service Tests

    @Test
    func internalTransferUpdatesBothAccounts() throws {

        // ARRANGE
        //
        // Reiniciamos el servicio para garantizar
        // que esta prueba siempre empiece igual.
        let service = BankingService.shared

        service.resetForTesting()


        // Cuenta 101 = Alex
        // Saldo inicial = $48,720.35
        let alexBalanceBefore =
            service.accounts.first {
                $0.id == 101
            }!.balance


        // Cuenta 201 = Sofía
        // Saldo inicial = $28,850.90
        let sofiaBalanceBefore =
            service.accounts.first {
                $0.id == 201
            }!.balance


        let transferAmount =
            Decimal(5_000)


        // ACT
        //
        // Beneficiary 701 representa a Sofía
        // y apunta hacia su cuenta 201.
        let transfer =
            try service.executeTransfer(
                sourceAccountId: 101,
                beneficiaryId: 701,
                amount: transferAmount,
                concept: "Prueba interna"
            )


        // Obtenemos nuevamente las cuentas DESPUÉS
        // de ejecutar la transferencia.
        let alexBalanceAfter =
            service.accounts.first {
                $0.id == 101
            }!.balance


        let sofiaBalanceAfter =
            service.accounts.first {
                $0.id == 201
            }!.balance


        // ASSERT
        //
        // Alex debe perder exactamente $5,000.
        #expect(
            alexBalanceAfter ==
            alexBalanceBefore - transferAmount
        )


        // Sofía debe recibir exactamente $5,000.
        #expect(
            sofiaBalanceAfter ==
            sofiaBalanceBefore + transferAmount
        )


        // La transferencia debe quedar registrada.
        #expect(service.transfers.count == 1)

        #expect(
            service.transfers.first?.id ==
            transfer.id
        )


        // Su estado debe ser completed.
        #expect(
            transfer.status == .completed
        )
    }


    @Test
    func internalTransferCreatesLinkedTransactions() throws {

        // ARRANGE

        let service = BankingService.shared

        service.resetForTesting()


        let transactionCountBefore =
            service.transactions.count


        // ACT

        let transfer =
            try service.executeTransfer(
                sourceAccountId: 101,
                beneficiaryId: 701,
                amount: Decimal(5_000),
                concept: "Prueba movimientos"
            )


        // ASSERT
        //
        // Una transferencia interna debe generar:
        //
        // 1 movimiento de salida
        // 1 movimiento de entrada
        //
        // Por eso esperamos +2.
        #expect(
            service.transactions.count ==
            transactionCountBefore + 2
        )


        // Buscamos el movimiento de salida
        // perteneciente a la cuenta 101.
        let outgoingTransaction =
            service.transactions.last {
                transaction in

                transaction.accountId == 101 &&
                transaction.type == .transferOut
            }


        // Buscamos el movimiento de entrada
        // perteneciente a la cuenta 201.
        let incomingTransaction =
            service.transactions.last {
                transaction in

                transaction.accountId == 201 &&
                transaction.type == .transferIn
            }


        // Ambos deben existir.
        #expect(outgoingTransaction != nil)

        #expect(incomingTransaction != nil)


        // Y ambos deben compartir exactamente
        // la misma referencia de transferencia.
        #expect(
            outgoingTransaction?.reference ==
            transfer.reference
        )

        #expect(
            incomingTransaction?.reference ==
            transfer.reference
        )


        #expect(
            outgoingTransaction?.reference ==
            incomingTransaction?.reference
        )
    }
}
