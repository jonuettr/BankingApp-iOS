package com.jonuettr.banking_api.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Map;


// Convierte excepciones de autenticación en respuestas HTTP
// adecuadas para el cliente iOS.
@RestControllerAdvice
public class AuthExceptionHandler {

    @ExceptionHandler(InvalidCredentialsException.class)
    public ResponseEntity<Map<String, String>>
    handleInvalidCredentials(
            InvalidCredentialsException exception) {

        // Deliberadamente no indicamos si falló el correo
        // o la contraseña.
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(
                        Map.of(
                                "error",
                                "Invalid credentials"
                        )
                );
    }
@ExceptionHandler(ForbiddenTransferException.class)
public ResponseEntity<Map<String, String>>
handleForbiddenTransfer(
        ForbiddenTransferException exception) {

    return ResponseEntity
            .status(HttpStatus.FORBIDDEN)
            .body(
                    Map.of(
                            "error",
                            "Forbidden operation"
                    )
            );
}
}
