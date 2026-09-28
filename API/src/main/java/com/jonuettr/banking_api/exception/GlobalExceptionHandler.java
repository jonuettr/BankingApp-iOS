package com.jonuettr.banking_api.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {


    // ---------------------------------------------------------
    // TRANSFERENCIA INVÁLIDA
    // ---------------------------------------------------------

    @ExceptionHandler(InvalidTransferException.class)
    public ResponseEntity<Map<String, Object>> handleInvalidTransfer(
            InvalidTransferException exception) {

        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                exception.getMessage()
        );
    }


    // ---------------------------------------------------------
    // SALDO INSUFICIENTE
    // ---------------------------------------------------------

    @ExceptionHandler(InsufficientFundsException.class)
    public ResponseEntity<Map<String, Object>> handleInsufficientFunds(
            InsufficientFundsException exception) {

        return buildErrorResponse(
                HttpStatus.CONFLICT,
                exception.getMessage()
        );
    }


    // ---------------------------------------------------------
    // ERRORES DE @Valid
    // ---------------------------------------------------------

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationErrors(
            MethodArgumentNotValidException exception) {

        Map<String, String> validationErrors =
                new LinkedHashMap<>();

        exception.getBindingResult()
                .getFieldErrors()
                .forEach(error ->
                        validationErrors.put(
                                error.getField(),
                                error.getDefaultMessage()
                        )
                );


        Map<String, Object> body =
                new LinkedHashMap<>();

        body.put("timestamp", LocalDateTime.now());
        body.put("status", HttpStatus.BAD_REQUEST.value());
        body.put("error", HttpStatus.BAD_REQUEST.getReasonPhrase());
        body.put("message", "Validation failed");
        body.put("fields", validationErrors);


        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(body);
    }


    // ---------------------------------------------------------
    // MÉTODO AUXILIAR
    // ---------------------------------------------------------

    private ResponseEntity<Map<String, Object>> buildErrorResponse(
            HttpStatus status,
            String message) {

        Map<String, Object> body =
                new LinkedHashMap<>();

        body.put("timestamp", LocalDateTime.now());
        body.put("status", status.value());
        body.put("error", status.getReasonPhrase());
        body.put("message", message);


        return ResponseEntity
                .status(status)
                .body(body);
    }
}