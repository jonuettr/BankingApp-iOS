//
//  APIModels.swift
//  BankingApp
//
//  Modelos utilizados exclusivamente para representar
//  las respuestas JSON recibidas desde Spring Boot.
//

import Foundation


// MARK: - Customer DTO

nonisolated struct CustomerDTO: Decodable, Sendable {

    let id: Int

    let firstName: String

    let lastName: String

    let email: String

    let active: Bool


    // MARK: Convert to Domain Model

    func toDomain() -> Customer {

        Customer(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email
        )
    }
}


// MARK: - Account DTO

nonisolated struct AccountDTO: Decodable, Sendable {

    let id: Int

    let customerId: Int

    let type: AccountType

    let name: String

    let lastFourDigits: String

    let balance: Decimal

    let currency: String

    let active: Bool


    // MARK: Convert to Domain Model

    func toDomain() -> Account {

        Account(
            id: id,
            customerId: customerId,
            type: type,
            name: name,
            lastFourDigits: lastFourDigits,
            balance: balance,
            currency: currency,
            isActive: active
        )
    }
}


// MARK: - Credit Card DTO

nonisolated struct CreditCardDTO: Decodable, Sendable {

    let id: Int

    let customerId: Int

    let name: String

    let lastFourDigits: String

    let creditLimit: Decimal

    let currentBalance: Decimal

    let minimumPayment: Decimal

    let paymentToAvoidInterest: Decimal

    let statementDay: Int

    let paymentDueDay: Int

    let active: Bool


    // MARK: Convert to Domain Model

    func toDomain() -> CreditCard {

        CreditCard(
            id: id,
            customerId: customerId,
            name: name,
            lastFourDigits: lastFourDigits,
            creditLimit: creditLimit,
            currentBalance: currentBalance,
            minimumPayment: minimumPayment,
            paymentToAvoidInterest:
                paymentToAvoidInterest,
            statementDay: statementDay,
            paymentDueDay: paymentDueDay,
            isActive: active
        )
    }
}


// MARK: - Transaction DTO

nonisolated struct TransactionDTO: Decodable, Sendable {

    let id: Int

    let accountId: Int?

    let creditCardId: Int?

    let description: String

    let amount: Decimal

    let type: TransactionType

    let category: TransactionCategory

    let status: TransactionStatus

    let date: String

    let merchant: String?

    let reference: String?


    // MARK: Convert to Domain Model

    func toDomain() throws -> Transaction {

        // Convertimos el texto procedente de Java
        // a un Date real de Swift.
        let parsedDate =
            try APIDateParser.parse(date)

        return Transaction(
            id: id,
            accountId: accountId,
            creditCardId: creditCardId,
            description: description,
            amount: amount,
            type: type,
            category: category,
            status: status,
            date: parsedDate,
            merchant: merchant,
            reference: reference
        )
    }
}


// MARK: - API Date Parser

enum APIDateParserError: Error {

    case invalidDate(String)
}


nonisolated enum APIDateParser {

    static func parse(
        _ value: String
    ) throws -> Date {

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]


        for format in formats {

            let formatter = DateFormatter()

            formatter.locale =
                Locale(identifier: "en_US_POSIX")

            formatter.timeZone =
                TimeZone(
                    identifier:
                        "America/Mexico_City"
                )

            formatter.dateFormat = format


            if let date =
                formatter.date(from: value) {

                return date
            }
        }


        throw APIDateParserError
            .invalidDate(value)
    }
}

// MARK: - Beneficiary DTO

nonisolated struct BeneficiaryDTO:
    Decodable,
    Sendable {

    let id: Int
    let ownerCustomerId: Int
    let name: String
    let bankName: String
    let clabe: String
    let destinationCustomerId: Int?
    let destinationAccountId: Int?
    let active: Bool

    func toDomain() -> Beneficiary {

        Beneficiary(
            id: id,
            ownerCustomerId: ownerCustomerId,
            name: name,
            bankName: bankName,
            clabe: clabe,
            destinationCustomerId:
                destinationCustomerId,
            destinationAccountId:
                destinationAccountId,
            isActive: active
        )
    }
}


// MARK: - Transfer Request DTO

// Encodable porque Swift lo enviará como JSON
// hacia Spring Boot.
nonisolated struct TransferRequestDTO:
    Encodable,
    Sendable {

    let sourceAccountId: Int
    let beneficiaryId: Int
    let amount: Decimal
    let concept: String
    let reference: String?
    let deviceIdentifier: String
}


// MARK: - Transfer Response DTO

// Esta es exactamente la respuesta que recibiremos
// después de que Spring Boot procese la transferencia.
nonisolated struct TransferResponseDTO:
    Decodable,
    Sendable {

    let id: Int
    let sourceAccountId: Int
    let beneficiaryId: Int
    let amount: Decimal
    let concept: String
    let reference: String?
    let status: TransferStatus
    let createdAt: String

    let riskScore: Int
    let riskLevel: RiskLevel
    let requiresVerification: Bool
    let riskReasons: [String]

    func toDomain() throws -> Transfer {

        Transfer(
            id: id,
            sourceAccountId: sourceAccountId,
            beneficiaryId: beneficiaryId,
            amount: amount,
            concept: concept,
            reference: reference,
            status: status,
            createdAt:
                try APIDateParser.parse(createdAt),
            completedAt: nil
        )
    }
}
