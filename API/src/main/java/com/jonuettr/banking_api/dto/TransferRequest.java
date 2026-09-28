package com.jonuettr.banking_api.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;


public class TransferRequest {

    @NotNull(message = "sourceAccountId is required")
    private Integer sourceAccountId;

    @NotNull(message = "beneficiaryId is required")
    private Integer beneficiaryId;


    @NotNull(message = "amount is required")
    @DecimalMin(
            value = "0.00",
            inclusive = false,
            message = "amount must be greater than 0"
    )
    private BigDecimal amount;


    @NotBlank(message = "concept is required")
    @Size(
            max = 255,
            message = "concept must not exceed 255 characters"
    )
    private String concept;


    @Size(
            max = 100,
            message = "reference must not exceed 100 characters"
    )
    private String reference;


    public TransferRequest() {
    }


    public Integer getSourceAccountId() {
        return sourceAccountId;
    }

    public Integer getBeneficiaryId() {
        return beneficiaryId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public String getConcept() {
        return concept;
    }

    public String getReference() {
        return reference;
    }
}