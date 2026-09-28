package com.jonuettr.banking_api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "TRANSFER")
public class Transfer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_transfer")
    private Integer id;

    @Column(name = "id_source_account", nullable = false)
    private Integer sourceAccountId;

    @Column(name = "id_beneficiary", nullable = false)
    private Integer beneficiaryId;

    @Column(name = "amount", nullable = false)
    private BigDecimal amount;

    @Column(name = "concept", nullable = false)
    private String concept;

    @Column(name = "reference")
    private String reference;

    @Column(name = "transfer_status", nullable = false)
    private String status;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;


    // Constructor vacío requerido por JPA.
    public Transfer() {
    }

    public Transfer(
            Integer sourceAccountId,
            Integer beneficiaryId,
            BigDecimal amount,
            String concept,
            String reference,
            String status,
            LocalDateTime createdAt,
            LocalDateTime completedAt) {

        this.sourceAccountId = sourceAccountId;
        this.beneficiaryId = beneficiaryId;
        this.amount = amount;
        this.concept = concept;
        this.reference = reference;
        this.status = status;
        this.createdAt = createdAt;
        this.completedAt = completedAt;
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

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }
}