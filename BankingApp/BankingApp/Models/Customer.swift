//
//  Customer.swift
//  BankingApp
//
//  Modelo que representa a un cliente.
//

import Foundation

// MARK: - Customer

struct Customer: Codable, Identifiable {
    // Identificador único del cliente.
    // Equivalente conceptual en SQL:
    // customer_id INT PRIMARY KEY
    let id: Int
    // Nombre del cliente.
    // String = texto.
    // let = el valor no puede modificarse después de crear el Customer.
    let firstName: String
    // Apellido del cliente.
    let lastName: String
    // Correo electrónico del cliente.
    let email: String
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
