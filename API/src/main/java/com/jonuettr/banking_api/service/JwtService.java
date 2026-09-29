package com.jonuettr.banking_api.service;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.auth0.jwt.interfaces.JWTVerifier;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Date;


// Servicio responsable exclusivamente de los tokens JWT.
//
// AuthService comprueba la contraseña.
// JwtService crea y posteriormente verificará la sesión.
//
// De esta manera cada clase tiene una responsabilidad clara.
@Service
public class JwtService {

    private final Algorithm algorithm;
    private final JWTVerifier verifier;
    private final long expirationMs;


    public JwtService(
            @Value("${security.jwt.secret}")
            String secret,

            @Value("${security.jwt.expiration-ms}")
            long expirationMs) {

        // HMAC256 firma el token utilizando nuestro secreto.
        //
        // Si alguien modifica el contenido del JWT sin conocer
        // el secreto, la firma deja de ser válida.
        this.algorithm =
                Algorithm.HMAC256(secret);

        this.verifier =
                JWT.require(algorithm)
                        .withIssuer("banking-api")
                        .build();

        this.expirationMs =
                expirationMs;
    }


    public String generateToken(
            Integer customerId,
            String email) {

        Instant now =
                Instant.now();

        Instant expiration =
                now.plusMillis(expirationMs);


        return JWT.create()

                // "issuer" identifica quién emitió el token.
                .withIssuer("banking-api")

                // "subject" será el ID del cliente autenticado.
                //
                // Más adelante utilizaremos este dato para impedir
                // que un cliente consulte información de otro.
                .withSubject(
                        customerId.toString()
                )

                // Claim adicional útil para identificar la sesión.
                .withClaim(
                        "email",
                        email
                )

                .withIssuedAt(
                        Date.from(now)
                )

                .withExpiresAt(
                        Date.from(expiration)
                )

                .sign(algorithm);
    }


    public DecodedJWT verifyToken(
            String token) {

        // verify() comprueba:
        //
        // 1. La firma.
        // 2. El issuer.
        // 3. La expiración.
        //
        // Si algo no es válido, Java JWT lanza
        // una excepción y el token no debe aceptarse.
        return verifier.verify(token);
    }


    public Integer getCustomerId(
            String token) {

        DecodedJWT decodedJWT =
                verifyToken(token);

        return Integer.valueOf(
                decodedJWT.getSubject()
        );
    }
}
