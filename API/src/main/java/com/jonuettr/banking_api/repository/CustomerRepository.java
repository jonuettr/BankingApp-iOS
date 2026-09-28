package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerRepository extends JpaRepository<Customer, Integer> {
}