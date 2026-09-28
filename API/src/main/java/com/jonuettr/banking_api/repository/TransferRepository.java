package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.Transfer;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;


public interface TransferRepository
        extends JpaRepository<Transfer, Integer> {

    // Cuenta cuántas transferencias ha realizado
    // una cuenta desde una fecha/hora determinada.
    //
    // Spring Data JPA interpreta automáticamente:
    //
    // SourceAccountId = cuenta origen
    // CreatedAtAfter  = creadas después de cierta hora
    //
    // Esto nos permitirá preguntar:
    //
    // "¿Cuántas transferencias realizó esta cuenta
    // durante los últimos 10 minutos?"
    long countBySourceAccountIdAndCreatedAtAfter(
            Integer sourceAccountId,
            LocalDateTime createdAfter
    );
}
