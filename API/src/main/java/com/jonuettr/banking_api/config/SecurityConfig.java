package com.jonuettr.banking_api.config;

import jakarta.servlet.http.HttpServletResponse;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;


// Define qué endpoints son públicos y cuáles requieren
// una identidad autenticada.
//
// La API será stateless:
// no utilizaremos sesiones HTTP del servidor.
// Cada petición protegida deberá traer su JWT.
@Configuration
public class SecurityConfig {

    private final JwtAuthenticationFilter
            jwtAuthenticationFilter;


    public SecurityConfig(
            JwtAuthenticationFilter jwtAuthenticationFilter) {

        this.jwtAuthenticationFilter =
                jwtAuthenticationFilter;
    }


    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http)
            throws Exception {

        http

                // Para una API REST autenticada mediante
                // Bearer tokens no utilizamos CSRF basado
                // en sesiones/cookies.
                .csrf(csrf ->
                        csrf.disable()
                )

                // Spring no almacenará una sesión entre
                // una petición y otra.
                .sessionManagement(session ->
                        session.sessionCreationPolicy(
                                SessionCreationPolicy.STATELESS
                        )
                )

                .authorizeHttpRequests(auth ->
                        auth

                                // El login debe permanecer público:
                                // todavía no tenemos token aquí.
                                .requestMatchers(
                                        "/api/auth/login"
                                )
                                .permitAll()

                                // Todo lo demás requiere JWT.
                                .anyRequest()
                                .authenticated()
                )

                // Si una petición intenta entrar a una ruta
                // protegida sin autenticarse, respondemos 401.
                .exceptionHandling(exceptions ->
                        exceptions.authenticationEntryPoint(
                                (request,
                                 response,
                                 authException) -> {

                                    response.setStatus(
                                            HttpServletResponse
                                                    .SC_UNAUTHORIZED
                                    );

                                    response.setContentType(
                                            "application/json"
                                    );

                                    response.getWriter().write(
                                            "{\"error\":\"Authentication required\"}"
                                    );
                                }
                        )
                )

                // Nuestro filtro JWT debe ejecutarse antes del
                // mecanismo estándar de usuario/contraseña.
                .addFilterBefore(
                        jwtAuthenticationFilter,
                        UsernamePasswordAuthenticationFilter.class
                );


        return http.build();
    }
}
