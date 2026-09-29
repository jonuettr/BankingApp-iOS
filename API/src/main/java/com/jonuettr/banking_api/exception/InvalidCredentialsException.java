package com.jonuettr.banking_api.exception;


// Excepción específica para un intento de autenticación
// con credenciales que no son válidas.
//
// Separarla de IllegalArgumentException permite que
// la API responda con el código HTTP correcto: 401.
public class InvalidCredentialsException
        extends RuntimeException {

    public InvalidCredentialsException() {
        super("Invalid credentials");
    }
}
