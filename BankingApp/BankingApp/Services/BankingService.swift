//
//  BankingService.swift
//  BankingApp
//
//  Servicio bancario local.
//
//  En esta etapa los datos existen únicamente en memoria.
//  Posteriormente esta implementación será sustituida
//  por comunicación con REST API.
//

import Foundation
import Observation


// MARK: - Banking Service Error

// Errores que pueden producirse durante
// una operación bancaria.
enum BankingServiceError: Error {

    case accountNotFound
    case beneficiaryNotFound
    case invalidAmount
    case insufficientFunds
}


// MARK: - Banking Service

@Observable
final class BankingService {


    // MARK: - Shared Instance

    static let shared = BankingService()


    
// MARK: - Data

// Cliente que actualmente está cargado desde la API.
//
// Lo mantenemos en BankingService para que todas las pantallas
// trabajen con la misma información del usuario.
private(set) var customer: Customer?


// Cuentas obtenidas desde Spring Boot.
//
// Durante las pruebas unitarias podemos seguir cargándolas
// desde MockData mediante resetForTesting().
private(set) var accounts: [Account]


// Tarjetas de crédito obtenidas desde la API.
private(set) var creditCards: [CreditCard]


// Historial de movimientos obtenido desde la API.
private(set) var transactions: [Transaction]


// Transferencias creadas durante la sesión.
//
// Más adelante esta colección también será sincronizada
// con nuestro endpoint POST /api/transfers.
private(set) var transfers: [Transfer]


// MARK: - Loading State

// Indica si estamos esperando una respuesta del servidor.
//
// Las Views podrán utilizar esta propiedad posteriormente
// para mostrar un ProgressView.
private(set) var isLoading = false


// Mensaje que describe el último error de comunicación.
//
// nil significa que actualmente no tenemos un error.
private(set) var errorMessage: String?

    // MARK: - Initialization

private init() {

    // Estos datos permiten que las pruebas existentes
    // continúen funcionando mientras terminamos la
    // migración completa hacia la API.
    //
    // En la ejecución normal de la app, loadCustomerData()
    // sustituirá estos valores por los recibidos de MySQL.

    customer = nil

    accounts = MockData.accounts

    creditCards = MockData.creditCards

    transactions = MockData.transactions

    transfers = []
}
// MARK: - Load Customer Data

// Descarga desde nuestra REST API toda la información
// principal que necesita la aplicación para un cliente.
//
// async:
// La función puede esperar respuestas de red sin bloquear
// la interfaz.
//
// throws:
// Si cualquiera de las peticiones falla, propagamos el error
// para que la capa de interfaz pueda reaccionar.
func loadCustomerData(
    customerId: Int
) async throws {

    // Evitamos mostrar dos estados contradictorios.
    isLoading = true
    errorMessage = nil

    defer {

        // defer se ejecuta tanto si todo salió bien
        // como si ocurrió un error.
        isLoading = false
    }

    do {

        // BankingAPIService es nuestra capa especializada
        // en comunicación con Spring Boot.
        //
        // Por ahora hacemos las peticiones secuencialmente
        // para mantener el flujo fácil de seguir.
        let apiCustomer =
            try await BankingAPIService.shared
                .fetchCustomer(id: customerId)

        let apiAccounts =
            try await BankingAPIService.shared
                .fetchAccounts(customerId: customerId)

        let apiCreditCards =
            try await BankingAPIService.shared
                .fetchCreditCards(customerId: customerId)

        let apiTransactions =
            try await BankingAPIService.shared
                .fetchTransactions(customerId: customerId)


        // IMPORTANTE:
        //
        // Solo sustituimos el estado después de que todas
        // las peticiones terminaron correctamente.
        //
        // Así evitamos dejar la app parcialmente actualizada
        // si, por ejemplo, cuentas funciona pero movimientos falla.

        customer = apiCustomer

        accounts = apiAccounts

        creditCards = apiCreditCards

        transactions = apiTransactions

    } catch {

        // Guardamos una descripción que después podremos
        // presentar de forma amigable en SwiftUI.
        errorMessage = error.localizedDescription

        // Volvemos a lanzar el mismo error para que quien
        // llamó esta función sepa que la carga falló.
        throw error
    }
}

    // MARK: - Execute Transfer

    func executeTransfer(
        sourceAccountId: Int,
        beneficiaryId: Int,
        amount: Decimal,
        concept: String
    ) throws -> Transfer {


        // MARK: Validate Amount

        // No permitimos transferencias de cero
        // ni cantidades negativas.
        guard amount > 0 else {

            throw BankingServiceError.invalidAmount
        }


        // MARK: Find Source Account

        guard let sourceAccountIndex =
            accounts.firstIndex(
                where: { account in

                    account.id == sourceAccountId
                }
            )
        else {

            throw BankingServiceError.accountNotFound
        }


        // MARK: Find Beneficiary

        guard let beneficiary =
            MockData.beneficiaries.first(
                where: { beneficiary in

                    beneficiary.id == beneficiaryId
                }
            )
        else {

            throw BankingServiceError.beneficiaryNotFound
        }


        // MARK: Validate Balance

        let sourceAccount =
            accounts[sourceAccountIndex]

        guard amount <= sourceAccount.balance else {

            throw BankingServiceError.insufficientFunds
        }


        // MARK: Generate IDs

        let newTransferId =
            (transfers.map { $0.id }.max() ?? 0) + 1

        let firstTransactionId =
            (transactions.map { $0.id }.max() ?? 0) + 1

        let secondTransactionId =
            firstTransactionId + 1


        // MARK: Date

        let now = Date()


        // MARK: Create Transfer

        let transfer = Transfer(
            id: newTransferId,
            sourceAccountId: sourceAccountId,
            beneficiaryId: beneficiaryId,
            amount: amount,
            concept: concept,
            reference: "TRF-\(newTransferId)",
            status: .completed,
            createdAt: now,
            completedAt: now
        )


        // MARK: Debit Source Account

        let sourceNewBalance =
            sourceAccount.balance - amount

        let updatedSourceAccount = Account(
            id: sourceAccount.id,
            customerId: sourceAccount.customerId,
            type: sourceAccount.type,
            name: sourceAccount.name,
            lastFourDigits:
                sourceAccount.lastFourDigits,
            balance: sourceNewBalance,
            currency: sourceAccount.currency,
            isActive: sourceAccount.isActive
        )

        accounts[sourceAccountIndex] =
            updatedSourceAccount


        // MARK: Create Outgoing Transaction

        let outgoingTransaction = Transaction(
            id: firstTransactionId,
            accountId: sourceAccountId,
            creditCardId: nil,
            description:
                "Transferencia a \(beneficiary.name)",
            amount: amount,
            type: .transferOut,
            category: .transfers,
            status: .completed,
            date: now,
            merchant: nil,
            reference: transfer.reference
        )


        transactions.append(
            outgoingTransaction
        )


        // MARK: Internal Transfer

        if let destinationAccountId =
            beneficiary.destinationAccountId,

           let destinationAccountIndex =
            accounts.firstIndex(
                where: { account in

                    account.id == destinationAccountId
                }
            ) {


            // MARK: Destination Account

            let destinationAccount =
                accounts[destinationAccountIndex]


            // Sumamos el importe recibido.
            let destinationNewBalance =
                destinationAccount.balance + amount


            let updatedDestinationAccount = Account(
                id: destinationAccount.id,
                customerId:
                    destinationAccount.customerId,
                type: destinationAccount.type,
                name: destinationAccount.name,
                lastFourDigits:
                    destinationAccount.lastFourDigits,
                balance: destinationNewBalance,
                currency: destinationAccount.currency,
                isActive: destinationAccount.isActive
            )


            // Actualizamos la cuenta receptora.
            accounts[destinationAccountIndex] =
                updatedDestinationAccount


            // MARK: Incoming Transaction

            // Ahora creamos el movimiento que verá
            // el cliente que recibió el dinero.
            let incomingTransaction = Transaction(
                id: secondTransactionId,
                accountId: destinationAccountId,
                creditCardId: nil,
                description:
                    "Transferencia recibida",
                amount: amount,
                type: .transferIn,
                category: .transfers,
                status: .completed,
                date: now,
                merchant: nil,
                reference: transfer.reference
            )


            transactions.append(
                incomingTransaction
            )
        }


        // MARK: Save Transfer

        // Finalmente registramos la transferencia.
        transfers.append(
            transfer
        )


        // MARK: Return

        return transfer
    }
    
    // MARK: - Testing Support

    func resetForTesting() {

        accounts = MockData.accounts
        transactions = MockData.transactions
        transfers = []
    }
}
