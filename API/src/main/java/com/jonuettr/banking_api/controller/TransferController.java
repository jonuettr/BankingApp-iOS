package com.jonuettr.banking_api.controller;

import com.jonuettr.banking_api.dto.TransferRequest;
import com.jonuettr.banking_api.dto.TransferResponse;
import com.jonuettr.banking_api.service.TransferService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/api/transfers")
public class TransferController {

    private final TransferService transferService;


    public TransferController(
            TransferService transferService) {

        this.transferService =
                transferService;
    }


    @PostMapping
    public ResponseEntity<TransferResponse>
    createTransfer(
            @Valid @RequestBody TransferRequest request,
            Authentication authentication) {

        // Este ID no viene del iPhone.
        // Proviene del JWT que ya fue verificado
        // criptográficamente por JwtAuthenticationFilter.
        Integer authenticatedCustomerId =
                (Integer) authentication.getPrincipal();


        TransferResponse response =
                transferService.createTransfer(
                        request,
                        authenticatedCustomerId
                );


        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }
}
