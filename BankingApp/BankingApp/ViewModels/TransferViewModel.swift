//
//  TransferViewModel.swift
//  BankingApp
//
//  Contiene la lógica necesaria para preparar y validar
//  una transferencia antes de enviarla.
//

import Foundation
import Observation


@Observable
final class TransferViewModel {


    // MARK: - Customer

    // Por ahora seguimos trabajando con Alex (customerId = 1).
    private let customerId: Int


    // MARK: - Available Data

    // Cuentas desde las que el cliente puede transferir.
    private(set) var accounts: [Account] = []

    // Beneficiarios disponibles para el cliente.
    private(set) var beneficiaries: [Beneficiary] = []


    // MARK: - Form Data

    // Cuenta seleccionada por el usuario.
    var selectedAccountId: Int?

    // Beneficiario seleccionado.
    var selectedBeneficiaryId: Int?

    var amountText: String = ""

    // Concepto escrito por el usuario.
    var concept: String = ""


    // MARK: - State

    // Aquí guardaremos un mensaje cuando exista
    // algún problema con el formulario.
    var validationMessage: String?

    // Resultado producido por RiskEngine.
    private(set) var riskResult: RiskResult?

    // Transferencia creada después de una ejecución exitosa.
    //
    // Mientras el usuario solamente está llenando el formulario,
    // su valor será nil.
    private(set) var completedTransfer: Transfer?

    // Mensaje producido si BankingService no puede
    // completar la operación.
    private(set) var executionErrorMessage: String?

    // MARK: - Initialization

    init(customerId: Int) {

        self.customerId = customerId

        loadAccounts()
        loadBeneficiaries()

        // Para mejorar la experiencia,
        // seleccionamos automáticamente la primera
        // cuenta disponible.
        selectedAccountId = accounts.first?.id

        // También seleccionamos el primer beneficiario.
        selectedBeneficiaryId = beneficiaries.first?.id
    }


    // MARK: - Selected Objects

    var selectedAccount: Account? {

        guard let selectedAccountId else {
            return nil
        }

        return accounts.first { account in
            account.id == selectedAccountId
        }
    }


    var selectedBeneficiary: Beneficiary? {

        guard let selectedBeneficiaryId else {
            return nil
        }

        return beneficiaries.first { beneficiary in
            beneficiary.id == selectedBeneficiaryId
        }
    }


    // MARK: - Amount

    var amount: Decimal? {

        let normalizedAmount =
            amountText.replacingOccurrences(
                of: ",",
                with: "."
            )

        return Decimal(
            string: normalizedAmount
        )
    }


    // MARK: - Validation

    // Esta función comprueba que la transferencia
    // tenga datos válidos.
    //
    // Devuelve:
    //
    // true  → podemos continuar.
    // false → existe algún problema.
    func validateTransfer() -> Bool {

        // Antes de validar nuevamente,
        // eliminamos el error anterior.
        validationMessage = nil


        // Debe existir una cuenta seleccionada.
        guard let account = selectedAccount else {

            validationMessage =
                "Selecciona una cuenta de origen."

            return false
        }


        // La cuenta debe estar activa.
        guard account.isActive else {

            validationMessage =
                "La cuenta seleccionada no está activa."

            return false
        }


        // Debe existir un beneficiario.
        guard let beneficiary = selectedBeneficiary else {

            validationMessage =
                "Selecciona un beneficiario."

            return false
        }


        // El beneficiario también debe estar activo.
        guard beneficiary.isActive else {

            validationMessage =
                "El beneficiario seleccionado no está activo."

            return false
        }


        // Debemos poder convertir el texto a Decimal.
        guard let amount else {

            validationMessage =
                "Ingresa un monto válido."

            return false
        }


        // No permitimos cero ni cantidades negativas.
        guard amount > 0 else {

            validationMessage =
                "El monto debe ser mayor que cero."

            return false
        }


        // El cliente no puede transferir más dinero
        // del que tiene disponible.
        guard amount <= account.balance else {

            validationMessage =
                "Saldo insuficiente para realizar la transferencia."

            return false
        }


        // El concepto será obligatorio.
        //
        // trimmingCharacters elimina espacios al principio
        // y al final.
        let cleanConcept =
            concept.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanConcept.isEmpty else {

            validationMessage =
                "Ingresa un concepto para la transferencia."

            return false
        }


        // Todas las validaciones fueron superadas.
        return true
    }


    // MARK: - Risk Evaluation

    // Esta función solamente debe ejecutarse después
    // de que validateTransfer() haya regresado true.
    func evaluateRisk() {

        guard let amount else {
            return
        }


        // Por ahora utilizaremos datos simulados
        // para algunas características de riesgo.
        let context = RiskContext(

            amount: amount,

            isNewBeneficiary: false,

            isNewDevice: false,

            // Todavía no tenemos historial persistente
            // de transferencias recientes.
            recentTransferCount: 0,

            // Utilizamos la hora real del dispositivo.
            hour: Calendar.current.component(
                .hour,
                from: Date()
            )
        )


        riskResult = RiskEngine.evaluate(
            context: context
        )
    }


    // MARK: - Continue

    // La vista llamará esta función cuando el usuario
    // pulse el botón "Continuar".
    //
    // Así evitamos que TransferView tenga que conocer
    // todos los detalles de validación.
    func prepareTransfer() -> Bool {

        // Primero validamos.
        guard validateTransfer() else {

            riskResult = nil

            return false
        }


        // Si los datos son válidos,
        // evaluamos el riesgo.
        evaluateRisk()

        return true
    }

    // MARK: - Execute Transfer

    // 1. validaba los datos,
    // 2. calculaba el riesgo.

    func executeTransfer() -> Bool {

        // Eliminamos cualquier error anterior.
        executionErrorMessage = nil


        // Necesitamos todos estos datos para ejecutar
        // la operación.
        guard let account = selectedAccount else {

            executionErrorMessage =
                "No se encontró la cuenta de origen."

            return false
        }


        guard let beneficiary = selectedBeneficiary else {

            executionErrorMessage =
                "No se encontró el beneficiario."

            return false
        }


        guard let amount else {

            executionErrorMessage =
                "El monto de la transferencia no es válido."

            return false
        }


        // Como medida adicional de seguridad,
        // no ejecutamos operaciones que RiskEngine
        // haya marcado para verificación.
        if riskResult?.requiresVerification == true {

            executionErrorMessage =
                "La operación requiere verificación adicional."

            return false
        }


        // "do" contiene el código que puede lanzar errores.
        do {

            // "try" indica que executeTransfer puede fallar.
            let transfer =
                try BankingService.shared.executeTransfer(
                    sourceAccountId: account.id,
                    beneficiaryId: beneficiary.id,
                    amount: amount,
                    concept: concept
                )


            // Si llegamos aquí, BankingService terminó
            // correctamente.
            completedTransfer = transfer

            return true

        } catch BankingServiceError.insufficientFunds {

            executionErrorMessage =
                "Saldo insuficiente para realizar la transferencia."

            return false

        } catch BankingServiceError.accountNotFound {

            executionErrorMessage =
                "La cuenta de origen ya no está disponible."

            return false

        } catch BankingServiceError.beneficiaryNotFound {

            executionErrorMessage =
                "El beneficiario ya no está disponible."

            return false

        } catch BankingServiceError.invalidAmount {

            executionErrorMessage =
                "El monto de la transferencia no es válido."

            return false

        } catch {

            // Este catch captura cualquier error que
            // no hayamos previsto específicamente.
            executionErrorMessage =
                "Ocurrió un error al procesar la transferencia."

            return false
        }
    }

    // MARK: - Load Data

    private func loadAccounts() {

        accounts = MockData.accounts.filter { account in

            account.customerId == customerId &&
            account.isActive
        }
    }


    private func loadBeneficiaries() {

        beneficiaries =
            MockData.beneficiaries.filter { beneficiary in

                beneficiary.ownerCustomerId == customerId &&
                beneficiary.isActive
            }
    }
}
