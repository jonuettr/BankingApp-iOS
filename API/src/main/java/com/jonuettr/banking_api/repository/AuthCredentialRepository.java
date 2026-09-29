package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.AuthCredential;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;


public interface AuthCredentialRepository
        extends JpaRepository<AuthCredential, Integer> {

    // Solo permite autenticar credenciales activas.
    Optional<AuthCredential>
    findByCustomerIdAndActiveTrue(
            Integer customerId
    );
}
