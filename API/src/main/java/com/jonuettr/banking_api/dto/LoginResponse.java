package com.jonuettr.banking_api.dto;


// Respuesta enviada después de una autenticación correcta.
//
// El iPhone conservará el accessToken de forma segura
// en Keychain y lo enviará en las peticiones protegidas.
public record LoginResponse(

        Integer customerId,
        String firstName,
        String lastName,
        String email,

        String accessToken,

        // Indica cuántos segundos puede utilizarse el token.
        long expiresIn
) {
}
