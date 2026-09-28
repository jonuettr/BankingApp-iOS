package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.entity.CreditCard;
import com.jonuettr.banking_api.repository.CreditCardRepository;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CreditCardService {

    private final CreditCardRepository creditCardRepository;

    public CreditCardService(
            CreditCardRepository creditCardRepository) {

        this.creditCardRepository = creditCardRepository;
    }

    public List<CreditCard> getCreditCardsByCustomerId(
            Integer customerId) {

        return creditCardRepository.findByCustomerId(customerId);
    }
}