package com.jonuettr.banking_api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "BANK_TRANSACTION")
public class BankTransaction {

    @Id
    @Column(name = "id_transaction")
    private Integer id;

    @Column(name = "id_account")
    private Integer accountId;

    @Column(name = "id_credit_card")
    private Integer creditCardId;

    @Column(name = "description", nullable = false)
    private String description;

    @Column(name = "amount", nullable = false)
    private BigDecimal amount;

    @Column(name = "transaction_type", nullable = false)
    private String type;

    @Column(name = "category", nullable = false)
    private String category;

    @Column(name = "transaction_status", nullable = false)
    private String status;

    @Column(name = "transaction_date", nullable = false)
    private LocalDateTime date;

    @Column(name = "merchant")
    private String merchant;

    @Column(name = "reference")
    private String reference;

    public BankTransaction() {
    }

    public Integer getId() {
        return id;
    }

    public Integer getAccountId() {
        return accountId;
    }

    public Integer getCreditCardId() {
        return creditCardId;
    }

    public String getDescription() {
        return description;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public String getType() {
        return type;
    }

    public String getCategory() {
        return category;
    }

    public String getStatus() {
        return status;
    }

    public LocalDateTime getDate() {
        return date;
    }

    public String getMerchant() {
        return merchant;
    }

    public String getReference() {
        return reference;
    }
}