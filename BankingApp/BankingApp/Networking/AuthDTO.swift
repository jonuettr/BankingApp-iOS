//
//  AuthDTO.swift
//  BankingApp
//
//  Modelos utilizados exclusivamente para
//  comunicarnos con /api/auth/login.
//

import Foundation


// MARK: - Login Request

nonisolated struct LoginRequestDTO:
    Encodable,
    Sendable {

    let email: String

    let password: String
}


// MARK: - Login Response

nonisolated struct LoginResponseDTO:
    Decodable,
    Sendable {

    let customerId: Int

    let firstName: String

    let lastName: String

    let email: String

    let accessToken: String

    let expiresIn: Int
}
