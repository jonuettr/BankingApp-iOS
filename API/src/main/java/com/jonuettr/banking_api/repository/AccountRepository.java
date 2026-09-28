package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.Account;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AccountRepository extends JpaRepository<Account, Integer> {

    List<Account> findByCustomerId(Integer customerId);
}