package com.jonuettr.banking_api.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class TransferResponse {

    private final Integer id;
    private final Integer sourceAccountId;
    private final Integer beneficiaryId;
    private final BigDecimal amount;
    private final String concept;
    private final String reference;
    private final String status;
    private final LocalDateTime createdAt;


    public TransferResponse(
            Integer id,
            Integer sourceAccountId,
            Integer beneficiaryId,
            BigDecimal amount,
            String concept,
            String reference,
            String status,
            LocalDateTime createdAt) {

        this.id = id;
        this.sourceAccountId = sourceAccountId;
        this.beneficiaryId = beneficiaryId;
        this.amount = amount;
        this.concept = concept;
        this.reference = reference;
        this.status = status;
        this.createdAt = createdAt;
    }


    public Integer getId() {
        return id;
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

    public String getStatus() {
        return status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}