package com.jonuettr.banking_api.controller;

import com.jonuettr.banking_api.entity.Beneficiary;
import com.jonuettr.banking_api.service.BeneficiaryService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;


// Endpoint utilizado por la aplicación iOS
// para consultar beneficiarios.
//
// El customerId de la URL debe coincidir con
// el customerId contenido en el JWT.
@RestController
@RequestMapping("/api/customers")
public class BeneficiaryController {

    private final BeneficiaryService beneficiaryService;


    public BeneficiaryController(
            BeneficiaryService beneficiaryService) {

        this.beneficiaryService =
                beneficiaryService;
    }


    @GetMapping("/{customerId}/beneficiaries")
    public ResponseEntity<List<Beneficiary>>
    getBeneficiaries(
            @PathVariable Integer customerId,
            Authentication authentication) {

        // JwtAuthenticationFilter guardó el customerId
        // autenticado como principal.
        Integer authenticatedCustomerId =
                (Integer) authentication.getPrincipal();


        // Un cliente autenticado no puede consultar
        // los beneficiarios pertenecientes a otro cliente.
        if (!authenticatedCustomerId.equals(customerId)) {

            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .build();
        }


        return ResponseEntity.ok(
                beneficiaryService
                        .getActiveBeneficiaries(customerId)
        );
    }
}
