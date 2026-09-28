package com.jonuettr.banking_api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;

@Entity
@Table(name = "ACCOUNT")
public class Account {

    @Id
    @Column(name = "id_account")
    private Integer id;

    @Column(name = "id_customer", nullable = false)
    private Integer customerId;

    @Column(name = "account_type", nullable = false)
    private String type;

    @Column(name = "account_name", nullable = false)
    private String name;

    @Column(name = "last_four_digits", nullable = false)
    private String lastFourDigits;

    @Column(name = "balance", nullable = false)
    private BigDecimal balance;

    @Column(name = "currency", nullable = false)
    private String currency;

    @Column(name = "is_active", nullable = false)
    private Boolean active;

    public Account() {
    }

    public Integer getId() {
        return id;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public String getType() {
        return type;
    }

    public String getName() {
        return name;
    }

    public String getLastFourDigits() {
        return lastFourDigits;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public String getCurrency() {
        return currency;
    }

    public Boolean getActive() {
        return active;
    }
}