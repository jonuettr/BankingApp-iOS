package com.jonuettr.banking_api.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;


// Respuesta que recibe el cliente después de
// solicitar una transferencia.
//
// Además de los datos bancarios, devolvemos
// el resultado de la evaluación de riesgo.
public class TransferResponse {

    private final Integer id;
    private final Integer sourceAccountId;
    private final Integer beneficiaryId;

    private final BigDecimal amount;

    private final String concept;
    private final String reference;
    private final String status;

    private final LocalDateTime createdAt;

    private final int riskScore;
    private final String riskLevel;
    private final boolean requiresVerification;
    private final List<String> riskReasons;


    public TransferResponse(
            Integer id,
            Integer sourceAccountId,
            Integer beneficiaryId,
            BigDecimal amount,
            String concept,
            String reference,
            String status,
            LocalDateTime createdAt,
            int riskScore,
            String riskLevel,
            boolean requiresVerification,
            List<String> riskReasons) {

        this.id = id;
        this.sourceAccountId = sourceAccountId;
        this.beneficiaryId = beneficiaryId;
        this.amount = amount;
        this.concept = concept;
        this.reference = reference;
        this.status = status;
        this.createdAt = createdAt;

        this.riskScore = riskScore;
        this.riskLevel = riskLevel;
        this.requiresVerification = requiresVerification;

        // Creamos una copia inmutable para evitar
        // modificaciones externas accidentales.
        this.riskReasons = List.copyOf(riskReasons);
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

    public int getRiskScore() {
        return riskScore;
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public boolean isRequiresVerification() {
        return requiresVerification;
    }

    public List<String> getRiskReasons() {
        return riskReasons;
    }
}

