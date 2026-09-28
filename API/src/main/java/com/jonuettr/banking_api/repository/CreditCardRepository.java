package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.CreditCard;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CreditCardRepository
        extends JpaRepository<CreditCard, Integer> {

    List<CreditCard> findByCustomerId(Integer customerId);
}