package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.entity.Beneficiary;
import com.jonuettr.banking_api.repository.BeneficiaryRepository;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;


@Service
public class BeneficiaryService {

    private final BeneficiaryRepository beneficiaryRepository;


    public BeneficiaryService(
            BeneficiaryRepository beneficiaryRepository) {

        this.beneficiaryRepository =
                beneficiaryRepository;
    }


    // Busca un beneficiario activo concreto.
    // TransferService utiliza este método para validar
    // que el beneficiario realmente pertenece al cliente.
    public Optional<Beneficiary> getActiveBeneficiary(
            Integer beneficiaryId,
            Integer ownerCustomerId) {

        return beneficiaryRepository
                .findByIdAndOwnerCustomerIdAndActiveTrue(
                        beneficiaryId,
                        ownerCustomerId
                );
    }


    // Devuelve los beneficiarios activos de un cliente.
    //
    // Este método será utilizado por la aplicación iOS
    // para llenar el Picker de beneficiarios.
    public List<Beneficiary> getActiveBeneficiaries(
            Integer ownerCustomerId) {

        return beneficiaryRepository
                .findByOwnerCustomerIdAndActiveTrue(
                        ownerCustomerId
                );
    }
}
