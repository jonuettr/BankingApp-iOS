//
//  Device.swift
//  BankingApp
//
//  Representa un dispositivo registrado por un cliente.
//
//  Esta información será utilizada por nuestro sistema de riesgo
//  para identificar operaciones realizadas desde dispositivos
//  conocidos o nuevos.
//

import Foundation

// MARK: - Device Type

// Define los tipos de dispositivo que reconocerá nuestra aplicación.
enum DeviceType: String, Codable {

    case iPhone
    case iPad
}


// MARK: - Device

struct Device: Codable, Identifiable {

    // Identificador único del dispositivo dentro de nuestro sistema.
    let id: Int

    // Cliente al que pertenece el dispositivo.
    let customerId: Int

    // Nombre descriptivo del dispositivo.
    let name: String

    // Tipo de dispositivo.
    let type: DeviceType

    // Identificador generado por nuestro sistema para reconocer
    // este registro de dispositivo.
    let deviceIdentifier: String

    // Indica si el dispositivo ya es considerado confiable.
    let isTrusted: Bool

    // Fecha en la que el dispositivo fue registrado.
    let registeredAt: Date

    // Fecha de su último acceso.
    let lastAccessAt: Date?
}
