package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.Transfer;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TransferRepository
        extends JpaRepository<Transfer, Integer> {

}