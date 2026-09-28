package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.Beneficiary;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface BeneficiaryRepository
        extends JpaRepository<Beneficiary, Integer> {

    List<Beneficiary>
    findByOwnerCustomerIdAndActiveTrue(Integer ownerCustomerId);

    Optional<Beneficiary>
    findByIdAndOwnerCustomerIdAndActiveTrue(
            Integer id,
            Integer ownerCustomerId);
}