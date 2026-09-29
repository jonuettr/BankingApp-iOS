package com.jonuettr.banking_api.controller;

import com.jonuettr.banking_api.entity.Beneficiary;
import com.jonuettr.banking_api.service.BeneficiaryService;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;


// Endpoint utilizado por la aplicación iOS
// para consultar los beneficiarios del cliente.
@RestController
@RequestMapping("/api/customers")
public class BeneficiaryController {

    private final BeneficiaryService beneficiaryService;


    public BeneficiaryController(
            BeneficiaryService beneficiaryService) {

        this.beneficiaryService =
                beneficiaryService;
    }


    // Ejemplo:
    //
    // GET /api/customers/1/beneficiaries
    @GetMapping("/{customerId}/beneficiaries")
    public List<Beneficiary> getBeneficiaries(
            @PathVariable Integer customerId) {

        return beneficiaryService
                .getActiveBeneficiaries(customerId);
    }
}
