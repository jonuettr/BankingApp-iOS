package com.jonuettr.banking_api.config;

import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.jonuettr.banking_api.service.JwtService;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;


// Este filtro se ejecuta una vez por cada petición HTTP.
//
// Busca:
// Authorization: Bearer <token>
//
// Si el JWT es válido, registra al cliente como autenticado
// dentro del SecurityContext de Spring.
@Component
public class JwtAuthenticationFilter
        extends OncePerRequestFilter {

    private final JwtService jwtService;


    public JwtAuthenticationFilter(
            JwtService jwtService) {

        this.jwtService = jwtService;
    }


    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain)
            throws ServletException, IOException {

        String authorizationHeader =
                request.getHeader("Authorization");


        // Si no existe un Bearer token, no autenticamos aquí.
        // SecurityConfig decidirá después si esa ruta
        // puede utilizarse sin autenticación.
        if (authorizationHeader == null
                || !authorizationHeader.startsWith("Bearer ")) {

            filterChain.doFilter(
                    request,
                    response
            );

            return;
        }


        String token =
                authorizationHeader.substring(7);


        try {

            // verifyToken comprueba firma, issuer y expiración.
            DecodedJWT decodedJWT =
                    jwtService.verifyToken(token);

            Integer customerId =
                    Integer.valueOf(
                            decodedJWT.getSubject()
                    );


            // El principal será el ID del cliente.
            //
            // Después podremos obtener este valor en los
            // controladores para comprobar que un cliente
            // no intenta consultar datos de otro.
            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(
                            customerId,
                            null,
                            List.of()
                    );


            SecurityContextHolder
                    .getContext()
                    .setAuthentication(authentication);

        } catch (
                JWTVerificationException
                | NumberFormatException exception) {

            // Un token presente pero inválido debe rechazarse
            // inmediatamente con 401.
            SecurityContextHolder.clearContext();

            response.setStatus(
                    HttpServletResponse.SC_UNAUTHORIZED
            );

            response.setContentType(
                    "application/json"
            );

            response.getWriter().write(
                    "{\"error\":\"Invalid or expired token\"}"
            );

            return;
        }


        filterChain.doFilter(
                request,
                response
        );
    }
}
