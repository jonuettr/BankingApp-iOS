package com.jonuettr.banking_api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;

@Entity
@Table(name = "CREDIT_CARD")
public class CreditCard {

    @Id
    @Column(name = "id_credit_card")
    private Integer id;

    @Column(name = "id_customer", nullable = false)
    private Integer customerId;

    @Column(name = "card_name", nullable = false)
    private String name;

    @Column(name = "last_four_digits", nullable = false)
    private String lastFourDigits;

    @Column(name = "credit_limit", nullable = false)
    private BigDecimal creditLimit;

    @Column(name = "current_balance", nullable = false)
    private BigDecimal currentBalance;

    @Column(name = "minimum_payment", nullable = false)
    private BigDecimal minimumPayment;

    @Column(name = "payment_to_avoid_interest", nullable = false)
    private BigDecimal paymentToAvoidInterest;

    @Column(name = "statement_day", nullable = false)
    private Integer statementDay;

    @Column(name = "payment_due_day", nullable = false)
    private Integer paymentDueDay;

    @Column(name = "is_active", nullable = false)
    private Boolean active;

    public CreditCard() {
    }

    public Integer getId() {
        return id;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public String getName() {
        return name;
    }

    public String getLastFourDigits() {
        return lastFourDigits;
    }

    public BigDecimal getCreditLimit() {
        return creditLimit;
    }

    public BigDecimal getCurrentBalance() {
        return currentBalance;
    }

    public BigDecimal getMinimumPayment() {
        return minimumPayment;
    }

    public BigDecimal getPaymentToAvoidInterest() {
        return paymentToAvoidInterest;
    }

    public Integer getStatementDay() {
        return statementDay;
    }

    public Integer getPaymentDueDay() {
        return paymentDueDay;
    }

    public Boolean getActive() {
        return active;
    }

    public BigDecimal getAvailableCredit() {
        return creditLimit.subtract(currentBalance);
    }
}