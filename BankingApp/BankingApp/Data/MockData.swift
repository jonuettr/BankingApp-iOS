//
//  MockData.swift
//  BankingApp
//
//  Datos ficticios utilizados durante el desarrollo.
//
//  IMPORTANTE:
//  Estos datos NO representan información de personas reales.
//

import Foundation


// MARK: - Mock Data

// "enum" también puede utilizarse como contenedor.
enum MockData {

    // MARK: - Customers

    // Creamos tres clientes ficticios.
    static let customers: [Customer] = [

        Customer(
            id: 1,
            firstName: "Alex",
            lastName: "Rivera",
            email: "alex.rivera@example.com"
        ),

        Customer(
            id: 2,
            firstName: "Sofía",
            lastName: "Martínez",
            email: "sofia.martinez@example.com"
        ),

        Customer(
            id: 3,
            firstName: "Diego",
            lastName: "Hernández",
            email: "diego.hernandez@example.com"
        )
    ]

    // MARK: - Accounts

    // Relacionamos las cuentas con sus propietarios
    // mediante customerId.
    static let accounts: [Account] = [

        // Alex - Cuenta principal
        Account(
            id: 101,
            customerId: 1,
            type: .checking,
            name: "Cuenta Digital",
            lastFourDigits: "4821",
            balance: Decimal(string: "48720.35")!,
            currency: "MXN",
            isActive: true
        ),

        // Alex - Cuenta de ahorro
        Account(
            id: 102,
            customerId: 1,
            type: .savings,
            name: "Ahorro",
            lastFourDigits: "7314",
            balance: Decimal(string: "92500.00")!,
            currency: "MXN",
            isActive: true
        ),

        // Sofía - Cuenta principal
        Account(
            id: 201,
            customerId: 2,
            type: .checking,
            name: "Cuenta Digital",
            lastFourDigits: "1647",
            balance: Decimal(string: "28850.90")!,
            currency: "MXN",
            isActive: true
        ),

        // Diego - Cuenta principal
        Account(
            id: 301,
            customerId: 3,
            type: .checking,
            name: "Cuenta Digital",
            lastFourDigits: "9052",
            balance: Decimal(string: "63125.40")!,
            currency: "MXN",
            isActive: true
        ),

        // Diego - Cuenta de ahorro
        Account(
            id: 302,
            customerId: 3,
            type: .savings,
            name: "Ahorro",
            lastFourDigits: "3378",
            balance: Decimal(string: "150000.00")!,
            currency: "MXN",
            isActive: true
        )
    ]


    // MARK: - Credit Cards

    static let creditCards: [CreditCard] = [

        // Tarjeta de Alex
        CreditCard(
            id: 501,
            customerId: 1,
            name: "Tarjeta Platinum",
            lastFourDigits: "5832",
            creditLimit: Decimal(string: "60000.00")!,
            currentBalance: Decimal(string: "13840.20")!,
            minimumPayment: Decimal(string: "850.00")!,
            paymentToAvoidInterest: Decimal(string: "13840.20")!,
            statementDay: 15,
            paymentDueDay: 5,
            isActive: true
        ),

        // Tarjeta de Sofía
        CreditCard(
            id: 502,
            customerId: 2,
            name: "Tarjeta Gold",
            lastFourDigits: "2196",
            creditLimit: Decimal(string: "45000.00")!,
            currentBalance: Decimal(string: "7215.75")!,
            minimumPayment: Decimal(string: "520.00")!,
            paymentToAvoidInterest: Decimal(string: "7215.75")!,
            statementDay: 20,
            paymentDueDay: 10,
            isActive: true
        ),

        // Tarjeta de Diego
        CreditCard(
            id: 503,
            customerId: 3,
            name: "Tarjeta Platinum",
            lastFourDigits: "7741",
            creditLimit: Decimal(string: "100000.00")!,
            currentBalance: Decimal(string: "21480.50")!,
            minimumPayment: Decimal(string: "1250.00")!,
            paymentToAvoidInterest: Decimal(string: "21480.50")!,
            statementDay: 12,
            paymentDueDay: 2,
            isActive: true
        )
    ]


    // MARK: - Beneficiaries


    static let beneficiaries: [Beneficiary] = [

        Beneficiary(
            id: 701,
            ownerCustomerId: 1,
            name: "Sofía Martínez",
            bankName: "BankingApp Bank",
            clabe: "012345678901234567",
            destinationCustomerId: 2,
            destinationAccountId: 201,
            isActive: true
        ),

        Beneficiary(
            id: 702,
            ownerCustomerId: 1,
            name: "Diego Hernández",
            bankName: "BankingApp Bank",
            clabe: "012345678901234568",
            destinationCustomerId: 3,
            destinationAccountId: 301,
            isActive: true
        )
    ]


    // MARK: - Devices

    static let devices: [Device] = [

        // Dispositivo confiable de Alex.
        Device(
            id: 801,
            customerId: 1,
            name: "iPhone principal",
            type: .iPhone,
            deviceIdentifier: "DEVICE-ALEX-001",
            isTrusted: true,
            registeredAt: makeDate(
                year: 2026,
                month: 1,
                day: 10,
                hour: 9,
                minute: 30
            ),
            lastAccessAt: makeDate(
                year: 2026,
                month: 9,
                day: 27,
                hour: 12,
                minute: 15
            )
        ),

        // Ejemplo de dispositivo todavía no confiable.
        Device(
            id: 802,
            customerId: 1,
            name: "iPad nuevo",
            type: .iPad,
            deviceIdentifier: "DEVICE-ALEX-002",
            isTrusted: false,
            registeredAt: makeDate(
                year: 2026,
                month: 9,
                day: 27,
                hour: 11,
                minute: 45
            ),
            lastAccessAt: nil
        )
    ]


    // MARK: - Transactions

    // Estos serán los primeros movimientos que mostraremos
    // en la pantalla principal.
    static let transactions: [Transaction] = [

        Transaction(
            id: 1001,
            accountId: 101,
            creditCardId: nil,
            description: "Nómina",
            amount: Decimal(string: "28500.00")!,
            type: .deposit,
            category: .income,
            status: .completed,
            date: makeDate(
                year: 2026,
                month: 9,
                day: 25,
                hour: 8,
                minute: 30
            ),
            merchant: nil,
            reference: "NOM-SEP-2026"
        ),

        Transaction(
            id: 1002,
            accountId: 101,
            creditCardId: nil,
            description: "Supermercado",
            amount: Decimal(string: "1248.60")!,
            type: .purchase,
            category: .food,
            status: .completed,
            date: makeDate(
                year: 2026,
                month: 9,
                day: 26,
                hour: 18,
                minute: 15
            ),
            merchant: "Mercado Central",
            reference: nil
        ),

        Transaction(
            id: 1003,
            accountId: 101,
            creditCardId: nil,
            description: "Servicio de internet",
            amount: Decimal(string: "670.00")!,
            type: .directDebit,
            category: .services,
            status: .completed,
            date: makeDate(
                year: 2026,
                month: 9,
                day: 26,
                hour: 7,
                minute: 0
            ),
            merchant: "Internet Hogar",
            reference: "SERV-0926"
        ),

        Transaction(
            id: 1004,
            accountId: 101,
            creditCardId: nil,
            description: "Restaurante",
            amount: Decimal(string: "845.50")!,
            type: .purchase,
            category: .food,
            status: .completed,
            date: makeDate(
                year: 2026,
                month: 9,
                day: 24,
                hour: 21,
                minute: 10
            ),
            merchant: "Restaurante Central",
            reference: nil
        ),

        Transaction(
            id: 1005,
            accountId: 101,
            creditCardId: nil,
            description: "Transferencia a ahorro",
            amount: Decimal(string: "5000.00")!,
            type: .transferOut,
            category: .transfers,
            status: .completed,
            date: makeDate(
                year: 2026,
                month: 9,
                day: 23,
                hour: 10,
                minute: 45
            ),
            merchant: nil,
            reference: "TRF-1005"
        ),

        // La contraparte del movimiento anterior aparece
        // en la cuenta de ahorro de Alex.
        Transaction(
            id: 1006,
            accountId: 102,
            creditCardId: nil,
            description: "Transferencia recibida",
            amount: Decimal(string: "5000.00")!,
            type: .transferIn,
            category: .transfers,
            status: .completed,
            date: makeDate(
                year: 2026,
                month: 9,
                day: 23,
                hour: 10,
                minute: 45
            ),
            merchant: nil,
            reference: "TRF-1005"
        ),
      
        // MARK: - Credit Card Transactions

        // Los siguientes movimientos pertenecen a la tarjeta
        // de crédito 501 de Alex.
        // accountId: nil
        // creditCardId: 501
        // Esto indica que el movimiento pertenece a una tarjeta
        // y no a una cuenta bancaria.

        Transaction(
            id: 1007,
            accountId: nil,
            creditCardId: 501,
            description: "Cafetería",
            amount: Decimal(string: "185.00")!,
            type: .purchase,
            category: .food,
            status: .completed,
            date: makeDate(
                year: 2026,
                month: 9,
                day: 27,
                hour: 9,
                minute: 20
            ),
            merchant: "Café Central",
            reference: nil
        ),

        Transaction(
            id: 1008,
            accountId: nil,
            creditCardId: 501,
            description: "Streaming",
            amount: Decimal(string: "299.00")!,
            type: .purchase,
            category: .entertainment,
            status: .completed,
            date: makeDate(
                year: 2026,
                month: 9,
                day: 25,
                hour: 6,
                minute: 0
            ),
            merchant: "Stream+",
            reference: "SUB-0926"
        ),

        Transaction(
            id: 1009,
            accountId: nil,
            creditCardId: 501,
            description: "Gasolina",
            amount: Decimal(string: "950.00")!,
            type: .purchase,
            category: .transportation,
            status: .completed,
            date: makeDate(
                year: 2026,
                month: 9,
                day: 22,
                hour: 19,
                minute: 35
            ),
            merchant: "Estación Central",
            reference: nil
        ),

        // Esta transacción está pendiente.
        //
        // Nos servirá para comprobar visualmente que nuestra
        // interfaz puede representar diferentes estados.
        Transaction(
            id: 1010,
            accountId: nil,
            creditCardId: 501,
            description: "Compra en línea",
            amount: Decimal(string: "2199.00")!,
            type: .purchase,
            category: .shopping,
            status: .pending,
            date: makeDate(
                year: 2026,
                month: 9,
                day: 27,
                hour: 16,
                minute: 40
            ),
            merchant: "Tienda Online",
            reference: "WEB-1010"
        )
    ]


    // MARK: - Helper Functions

    // Esta función nos evita escribir una construcción de Date
    // mucho más larga cada vez que necesitamos una fecha.
    private static func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int
    ) -> Date {

        // DateComponents permite construir una fecha
        // especificando sus componentes.
        var components = DateComponents()

        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(identifier: "America/Mexico_City")

        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute

        // Calendar.date(from:) devuelve Date?,
        // es decir, una fecha opcional.
        guard let date = components.calendar?.date(from: components) else {

            // Si nosotros escribimos una fecha imposible dentro
            // de MockData, significa que existe un error de programación.
            fatalError("Invalid mock date")
        }

        return date
    }
}
