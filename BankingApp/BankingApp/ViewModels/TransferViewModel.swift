//
//  TransferViewModel.swift
//  BankingApp
//
//  Coordina el formulario de transferencia con
//  la REST API de Spring Boot.
//

import Foundation
import Observation


@Observable
final class TransferViewModel {


    // MARK: - Dependencies

    private let customerId: Int

    private let bankingService =
        BankingService.shared

    private let apiService =
        BankingAPIService.shared


    // MARK: - Available Data

    // Las cuentas proceden de BankingService,
    // que ya fue cargado desde nuestra API.
    var accounts: [Account] {

        bankingService.accounts.filter { account in

            account.customerId == customerId &&
            account.isActive
        }
    }


    // Los beneficiarios sí se consultan mediante
    // GET /api/customers/{id}/beneficiaries.
    private(set) var beneficiaries: [Beneficiary] = []


    // MARK: - Form Data

    var selectedAccountId: Int?

    var selectedBeneficiaryId: Int?

    var amountText: String = ""

    var concept: String = ""


    // MARK: - State

    var validationMessage: String?

    private(set) var executionErrorMessage: String?

    private(set) var completedTransfer: Transfer?

    private(set) var riskResult: RiskResult?

    private(set) var isLoading = false

    private(set) var isExecuting = false


    // MARK: - Initialization

    init(customerId: Int) {

        self.customerId = customerId

        // Las cuentas ya existen en BankingService
        // porque ContentView carga los datos del cliente.
        selectedAccountId = accounts.first?.id
    }


    // MARK: - Load Data

    func loadData() async {

        // Evitamos lanzar dos cargas simultáneas.
        guard !isLoading else {
            return
        }

        isLoading = true
        executionErrorMessage = nil

        defer {
            isLoading = false
        }

        do {

            let loadedBeneficiaries =
                try await apiService.fetchBeneficiaries(
                    customerId: customerId
                )

            beneficiaries =
                loadedBeneficiaries.filter { beneficiary in

                    beneficiary.isActive
                }

            // Seleccionamos automáticamente el primero
            // solamente si todavía no existe selección.
            if selectedBeneficiaryId == nil {

                selectedBeneficiaryId =
                    beneficiaries.first?.id
            }

            // Hacemos lo mismo con la cuenta.
            if selectedAccountId == nil {

                selectedAccountId =
                    accounts.first?.id
            }

        } catch {

executionErrorMessage =
    APIErrorHandler.handle(error)        }
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

            beneficiary.id ==
                selectedBeneficiaryId
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

    func validateTransfer() -> Bool {

        validationMessage = nil
        executionErrorMessage = nil


        guard let account = selectedAccount else {

            validationMessage =
                "Selecciona una cuenta de origen."

            return false
        }


        guard account.isActive else {

            validationMessage =
                "La cuenta seleccionada no está activa."

            return false
        }


        guard let beneficiary =
                selectedBeneficiary else {

            validationMessage =
                "Selecciona un beneficiario."

            return false
        }


        guard beneficiary.isActive else {

            validationMessage =
                "El beneficiario seleccionado no está activo."

            return false
        }


        guard let amount else {

            validationMessage =
                "Ingresa un monto válido."

            return false
        }


        guard amount > 0 else {

            validationMessage =
                "El monto debe ser mayor que cero."

            return false
        }


        // Esta validación mejora la experiencia,
        // pero NO sustituye la validación del servidor.
        //
        // Spring Boot vuelve a comprobar el saldo
        // dentro de la transacción SQL.
        guard amount <= account.balance else {

            validationMessage =
                "Saldo insuficiente para realizar la transferencia."

            return false
        }


        let cleanConcept =
            concept.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanConcept.isEmpty else {

            validationMessage =
                "Ingresa un concepto para la transferencia."

            return false
        }


        return true
    }


    // MARK: - Prepare Transfer

    func prepareTransfer() -> Bool {

        // Aquí YA NO calculamos el riesgo.
        //
        // El cliente iOS solamente valida el formulario.
        // La decisión de riesgo pertenece al backend.
        riskResult = nil

        return validateTransfer()
    }


    // MARK: - Execute Transfer

    func executeTransfer() async -> Bool {

        executionErrorMessage = nil
        riskResult = nil
        completedTransfer = nil


        // Volvemos a validar porque entre la pantalla
        // de confirmación y este momento los datos
        // podrían haber cambiado.
        guard validateTransfer() else {
            return false
        }


        guard let account = selectedAccount,
              let beneficiary = selectedBeneficiary,
              let amount else {

            executionErrorMessage =
                "No fue posible preparar la transferencia."

            return false
        }


        guard !isExecuting else {
            return false
        }


        isExecuting = true

        defer {
            isExecuting = false
        }


        do {

            // Para esta etapa del proyecto utilizamos
            // el dispositivo principal sembrado en MySQL.
            //
            // Más adelante, el flujo de autenticación
            // registrará y resolverá este identificador.
            let deviceIdentifier =
                "DEVICE-ALEX-001"


            // Esta llamada realiza realmente:
            //
            // iOS
            // ↓
            // POST /api/transfers
            // ↓
            // Spring Boot
            // ↓
            // RiskEngineService
            // ↓
            // MySQL
            let response =
                try await apiService.createTransfer(
                    sourceAccountId: account.id,
                    beneficiaryId: beneficiary.id,
                    amount: amount,
                    concept:
                        concept.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ),
                    reference: nil,
                    deviceIdentifier:
                        deviceIdentifier
                )


            // Convertimos la evaluación realizada
            // por Java al modelo utilizado por SwiftUI.
            riskResult =
                RiskResult(
                    score: response.riskScore,
                    level: response.riskLevel,
                    requiresVerification:
                        response.requiresVerification,
                    reasons: response.riskReasons
                )


            completedTransfer =
                try response.toDomain()


            // El backend pudo modificar:
            //
            // - saldos
            // - movimientos
            // - transferencias
            // - evaluación de riesgo
            //
            // Por eso volvemos a consultar los datos
            // y dejamos BankingService sincronizado
            // con MySQL.
            try await bankingService.loadCustomerData(
                customerId: customerId
            )


            return true

        } catch {

            // Convertimos el error técnico en un mensaje
            // apropiado para la interfaz.
            //
            // Si recibimos un 401, el manejador también
            // invalida la sesión, elimina el JWT y hace
            // que la aplicación vuelva al Login.
            executionErrorMessage =
                APIErrorHandler.handle(error)

            // Durante desarrollo conservamos el error
            // técnico en la consola para poder depurarlo.
            print(
                "TRANSFER ERROR:",
                error
            )

            return false
        }
    }
}
