package com.jonuettr.banking_api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "BENEFICIARY")
public class Beneficiary {

    @Id
    @Column(name = "id_beneficiary")
    private Integer id;

    @Column(name = "id_owner_customer", nullable = false)
    private Integer ownerCustomerId;


    @Column(name = "beneficiary_name", nullable = false)
    private String name;


    @Column(name = "bank_name", nullable = false)
    private String bankName;

    @Column(name = "clabe", nullable = false)
    private String clabe;

    @Column(name = "id_destination_customer")
    private Integer destinationCustomerId;


    @Column(name = "id_destination_account")
    private Integer destinationAccountId;


    @Column(name = "is_active", nullable = false)
    private Boolean active;


    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    public Beneficiary() {
    }


    public Integer getId() {
        return id;
    }

    public Integer getOwnerCustomerId() {
        return ownerCustomerId;
    }

    public String getName() {
        return name;
    }

    public String getBankName() {
        return bankName;
    }

    public String getClabe() {
        return clabe;
    }

    public Integer getDestinationCustomerId() {
        return destinationCustomerId;
    }

    public Integer getDestinationAccountId() {
        return destinationAccountId;
    }

    public Boolean getActive() {
        return active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public boolean isInternal() {
        return destinationCustomerId != null
                && destinationAccountId != null;
    }
}