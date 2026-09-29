package com.jonuettr.banking_api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;


// Centralizamos el algoritmo utilizado para contraseñas.
//
// BCrypt incluye salt automáticamente y está diseñado
// específicamente para almacenar contraseñas.
@Configuration
public class PasswordConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {

        return new BCryptPasswordEncoder();
    }
}
