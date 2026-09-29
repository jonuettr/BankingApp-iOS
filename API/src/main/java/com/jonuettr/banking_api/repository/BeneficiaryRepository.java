package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.Beneficiary;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;


public interface BeneficiaryRepository
        extends JpaRepository<Beneficiary, Integer> {

    // Busca un beneficiario activo específico
    // y verifica que pertenezca al cliente.
    Optional<Beneficiary>
    findByIdAndOwnerCustomerIdAndActiveTrue(
            Integer id,
            Integer ownerCustomerId
    );


    // Obtiene todos los beneficiarios activos
    // guardados por un cliente.
    List<Beneficiary>
    findByOwnerCustomerIdAndActiveTrue(
            Integer ownerCustomerId
    );
}
