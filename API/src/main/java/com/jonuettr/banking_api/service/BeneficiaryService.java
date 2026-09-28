package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.entity.Beneficiary;
import com.jonuettr.banking_api.repository.BeneficiaryRepository;

import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class BeneficiaryService {

    private final BeneficiaryRepository beneficiaryRepository;

    public BeneficiaryService(
            BeneficiaryRepository beneficiaryRepository) {

        this.beneficiaryRepository = beneficiaryRepository;
    }

    public Optional<Beneficiary> getActiveBeneficiary(
            Integer beneficiaryId,
            Integer ownerCustomerId) {

        return beneficiaryRepository
                .findByIdAndOwnerCustomerIdAndActiveTrue(
                        beneficiaryId,
                        ownerCustomerId);
    }
}