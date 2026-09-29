package com.jonuettr.banking_api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;


// Datos que el iPhone enviará al iniciar sesión.
public record LoginRequest(

        @NotBlank
        @Email
        String email,

        @NotBlank
        String password
) {
}
