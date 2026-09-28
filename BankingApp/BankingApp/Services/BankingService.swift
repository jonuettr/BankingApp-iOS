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

    private(set) var accounts: [Account]

    private(set) var transactions: [Transaction]

    private(set) var transfers: [Transfer]


    // MARK: - Initialization

    private init() {

        accounts = MockData.accounts

        transactions = MockData.transactions

        transfers = []
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
