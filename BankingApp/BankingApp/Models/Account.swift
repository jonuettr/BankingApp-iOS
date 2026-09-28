//
//  Account.swift
//  BankingApp
//
//  Representa una cuenta bancaria perteneciente a un cliente.
//

import Foundation

// MARK: - Account Type
// Un "enum" define un conjunto limitado de valores posibles.
// No queremos que accountType pueda contener cualquier texto.
// En nuestra aplicación una cuenta solamente podrá ser:
// checking → cuenta de débito
// savings  → cuenta de ahorro
// String indica que cada opción tendrá una representación en texto.
// Codable permitirá recibir estos valores desde nuestra API.
enum AccountType: String, Codable {
    // Cuenta de débito.
    case checking
    // Cuenta de ahorro.
    case savings
}

// MARK: - Account
// Representa una cuenta bancaria.
// Igual que Customer:
// Codable     → permite convertir entre JSON y Swift.
// Identifiable → permite identificar cada cuenta de forma única.
struct Account: Codable, Identifiable {
    // Identificador único de la cuenta.
    // Equivalente conceptual en SQL:
    // account_id INT PRIMARY KEY
    let id: Int
    // Identificador del cliente propietario de la cuenta.
    // Esta propiedad crea la relación lógica con Customer.
    // Un cliente puede tener varias cuentas,
    // pero cada cuenta pertenece a un solo cliente.
    let customerId: Int
    // Tipo de cuenta.
    // Solamente acepta los valores definidos en AccountType.
    let type: AccountType
    // Nombre que mostraremos al usuario.
    let name: String
    // Últimos cuatro dígitos visibles de la cuenta.
    // Utilizamos String y no Int porque estos números funcionan
    // como identificadores, no como cantidades matemáticas.
    // Además, String permite conservar ceros iniciales.
    let lastFourDigits: String
    // Saldo disponible de la cuenta.
    // Utilizamos Decimal en lugar de Double porque estamos
    // representando dinero.
    // Double utiliza números de punto flotante y determinadas
    // operaciones pueden producir pequeñas imprecisiones.
    // Decimal es una opción más apropiada para importes monetarios.
    let balance: Decimal
    // Código de la moneda.
    // Por ahora utilizaremos "MXN", pero mantenerlo como propiedad
    // permite que el modelo soporte otras monedas posteriormente.
    let currency: String
    // Indica si la cuenta se encuentra activa.
    // Bool solamente puede tener dos valores:
    let isActive: Bool
}
